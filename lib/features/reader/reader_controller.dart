import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/theme/theme_controller.dart' show appDatabaseProvider;
import '../../core/archive/archive_extractor.dart';
import '../../core/network/komga_exception.dart';
import '../../data/komga/komga_api.dart';
import '../../data/komga/models/mappers.dart';
import '../../data/komga/models/page_dto.dart';
import '../../data/source/source_providers.dart';
import '../offline/offline_providers.dart';
import 'color/color_settings.dart';
import 'color/color_settings_repository.dart';
import 'reader_models.dart';
import 'reader_settings_repository.dart';

part 'reader_controller.g.dart';

/// Where the reader's pages come from. The screen turns this into a `PageSource`.
sealed class ReaderPages {
  const ReaderPages();
}

class OnlinePages extends ReaderPages {
  const OnlinePages(this.api, this.pages);
  final KomgaApi api;
  final List<PageDto> pages;
}

class OfflinePages extends ReaderPages {
  const OfflinePages(this.archivePath, this.entries);
  final String archivePath;
  final List<String> entries;
}

/// Everything the reader needs for one book. The live page index is view state
/// held by the screen; [initialPage] seeds it from the saved read position
/// (T6). Per-turn progress write-back is handled by the screen via the
/// SyncEngine.
class ReaderData {
  const ReaderData({
    required this.sourceId,
    required this.bookId,
    required this.seriesId,
    required this.title,
    required this.settings,
    required this.source,
    required this.initialPage,
    required this.colorAdjustments,
  });

  final String sourceId;
  final String bookId;
  final String seriesId;

  /// The current book's display title, shown by the end-of-book seam (T4).
  final String title;
  final ReaderSettings settings;
  final ReaderPages source;

  /// 0-based page to open at, from the saved `BookState` (clamped to the book's
  /// range by the screen). 0 for a never-opened book.
  final int initialPage;

  /// The effective page color correction resolved at open (global/series/book
  /// precedence). The screen seeds its live state from this for a correct
  /// first paint without awaiting the color controller.
  final ColorAdjustments colorAdjustments;

  ReaderData copyWith({ReaderSettings? settings}) => ReaderData(
        sourceId: sourceId,
        bookId: bookId,
        seriesId: seriesId,
        title: title,
        settings: settings ?? this.settings,
        source: source,
        initialPage: initialPage,
        colorAdjustments: colorAdjustments,
      );
}

/// Loads a book for reading, offline-first: a cached archive is read from disk
/// (no network); otherwise pages stream online and a background download is
/// enqueued. Throws only when neither a cache nor a reachable source exists.
@riverpod
class ReaderController extends _$ReaderController {
  @override
  Future<ReaderData> build(String sourceId, String bookId,
      [bool preview = false]) async {
    final db = ref.watch(appDatabaseProvider);
    final settingsRepo = ReaderSettingsRepository(db);

    // Resume position: seed the reader from the saved local read state.
    final initialPage =
        (await db.getBookState(sourceId, bookId))?.currentPage ?? 0;

    // Offline-first: read a cached archive if available.
    final cache = ref.watch(offlineCacheManagerProvider);
    final archivePath = await cache.archivePath(sourceId, bookId);
    if (archivePath != null) {
      try {
        final entries =
            await ref.watch(archiveExtractorProvider).entries(archivePath);
        final book = await db.getBook(sourceId, bookId);
        final seriesId = book?.seriesId ?? '';
        final title = book?.title ?? '';
        final settings = await settingsRepo.load(sourceId, seriesId);
        final colorAdjustments =
            await ColorSettingsRepository(db).resolve(sourceId, seriesId, bookId);
        return ReaderData(
          sourceId: sourceId,
          bookId: bookId,
          seriesId: seriesId,
          title: title,
          settings: settings,
          source: OfflinePages(archivePath, entries),
          initialPage: initialPage,
          colorAdjustments: colorAdjustments,
        );
      } on ArchiveException {
        // Corrupt cache: quarantine and fall through to online.
        await cache.delete(sourceId, bookId);
      }
    }

    // Online path.
    final api = await ref.watch(komgaApiForProvider(sourceId).future);
    if (api == null) {
      throw StateError('No connected source for this book.');
    }

    final cached = await db.getBook(sourceId, bookId);
    String seriesId;
    String title;
    if (cached != null) {
      seriesId = cached.seriesId;
      title = cached.title;
    } else {
      final dto = await api.getBook(bookId);
      seriesId = dto.seriesId;
      title = dto.title;
      await db.upsertBook(bookToRow(sourceId, dto));
    }

    final pages = await api.bookPages(bookId);

    String? direction;
    if (!await settingsRepo.has(sourceId, seriesId)) {
      try {
        direction = (await api.getSeries(seriesId)).readingDirection;
      } on KomgaException {
        // Fall back to LTR defaults.
      }
    }
    final settings =
        await settingsRepo.load(sourceId, seriesId, mangaDirection: direction);
    final colorAdjustments =
        await ColorSettingsRepository(db).resolve(sourceId, seriesId, bookId);

    // Background full-chapter download (idempotent, fire-and-forget). Skipped in
    // preview mode: a peek must not auto-cache the chapter.
    if (!preview) {
      unawaited(ref
          .read(downloadManagerProvider)
          .enqueueBook(sourceId, bookId)
          .catchError((_) {}));
    }

    return ReaderData(
      sourceId: sourceId,
      bookId: bookId,
      seriesId: seriesId,
      title: title,
      settings: settings,
      source: OnlinePages(api, pages),
      initialPage: initialPage,
      colorAdjustments: colorAdjustments,
    );
  }

  /// Persists and applies new reader settings for this book's series. The
  /// direction normalizer keeps the paged-mode suffix and [ReaderSettings.direction]
  /// in lockstep (the single write path; see the T4 design doc).
  Future<void> updateSettings(ReaderSettings settings) async {
    final data = state.valueOrNull;
    if (data == null) return;
    final normalized = _normalizeDirection(settings);
    await ReaderSettingsRepository(ref.read(appDatabaseProvider))
        .save(data.sourceId, data.seriesId, normalized);
    state = AsyncData(data.copyWith(settings: normalized));
  }

  /// Flips horizontal reading direction and persists it (T4). Paged modes flip the
  /// mode suffix (the normalizer mirrors `direction`); double-page flips `direction`
  /// directly; webtoon is a no-op (the toggle is hidden there).
  Future<void> toggleDirection() async {
    final data = state.valueOrNull;
    if (data == null) return;
    final s = data.settings;
    final next = switch (s.mode) {
      ReadingMode.pagedLtr => s.copyWith(mode: ReadingMode.pagedRtl),
      ReadingMode.pagedRtl => s.copyWith(mode: ReadingMode.pagedLtr),
      ReadingMode.doublePage => s.copyWith(
          direction: s.direction == ReadingDirection.rtl
              ? ReadingDirection.ltr
              : ReadingDirection.rtl,
        ),
      ReadingMode.webtoon || ReadingMode.webtoonGaps => s,
    };
    if (identical(next, s)) return;
    await updateSettings(next);
  }

  /// Keeps the paged-mode suffix and [ReaderSettings.direction] coherent: a paged
  /// mode is authoritative for direction (sets it); double-page/webtoon inherit the
  /// current direction unchanged.
  ReaderSettings _normalizeDirection(ReaderSettings s) => switch (s.mode) {
        ReadingMode.pagedLtr => s.copyWith(direction: ReadingDirection.ltr),
        ReadingMode.pagedRtl => s.copyWith(direction: ReadingDirection.rtl),
        _ => s,
      };
}
