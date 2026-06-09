import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/theme/theme_controller.dart' show appDatabaseProvider;
import '../../core/archive/archive_extractor.dart';
import '../../core/network/content_exception.dart';
import '../../data/source/models/mappers.dart';
import '../../data/source/models/page_dto.dart';
import '../../data/source/content_api.dart';
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
  final ContentApi api;
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
    required this.seriesTitle,
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

  /// The owning series' display title (null when not cached), shown in the
  /// reader top bar alongside the chapter title.
  final String? seriesTitle;
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
    seriesTitle: seriesTitle,
    settings: settings ?? this.settings,
    source: source,
    initialPage: initialPage,
    colorAdjustments: colorAdjustments,
  );
}

/// The 0-based page to open the reader on for a book.
///
/// Prefers [savedCurrentPage] (the local `BookState`), which is authoritative
/// once the book has been read or reconciled on this device. When there is no
/// local read state yet - e.g. right after a fresh install, before the book has
/// been reconciled - it falls back to the server's last-read page cached on the
/// book ([serverReadPage], Komga's 1-based `readProgress.page`) converted to our
/// 0-based index. Without this fallback a reinstalled app showed the correct
/// "Continue reading" percentage (which already falls back to the cached page)
/// but opened every book at page 1, because the missing `BookState` defaulted
/// the start page to 0.
int resolveInitialReaderPage({
  required int? savedCurrentPage,
  required int? serverReadPage,
}) {
  if (savedCurrentPage != null) return savedCurrentPage;
  final page = (serverReadPage ?? 0) - 1;
  return page < 0 ? 0 : page;
}

/// Loads a book for reading, offline-first: a cached archive is read from disk
/// (no network); otherwise pages stream online (per-page, through the byte
/// cache). The full-chapter offline backfill is NOT started here: the reader
/// starts it a few seconds after open (gated by the auto-cache + Wi-Fi settings)
/// so it never competes with the opening page fetches. Throws only when neither a
/// cache nor a reachable source exists.
@riverpod
class ReaderController extends _$ReaderController {
  @override
  Future<ReaderData> build(
    String sourceId,
    String bookId, [
    bool preview = false,
  ]) async {
    final db = ref.watch(appDatabaseProvider);
    final settingsRepo = ReaderSettingsRepository(db);

    // Resume position: prefer the saved local read state; fall back to the
    // server page cached on the book (resolved per-path below, once the book is
    // known) so a fresh install resumes where the user left off.
    final savedPage = (await db.getBookState(sourceId, bookId))?.currentPage;

    // Offline-first: read a cached archive if available.
    final cache = ref.watch(offlineCacheManagerProvider);
    final archivePath = await cache.archivePath(sourceId, bookId);
    if (archivePath != null) {
      try {
        final entries = await ref
            .watch(archiveExtractorProvider)
            .entries(archivePath);
        final book = await db.getBook(sourceId, bookId);
        final seriesId = book?.seriesId ?? '';
        final title = book?.title ?? '';
        final settings = await settingsRepo.load(sourceId, seriesId);
        final colorAdjustments = await ColorSettingsRepository(
          db,
        ).resolve(sourceId, seriesId, bookId);
        return ReaderData(
          sourceId: sourceId,
          bookId: bookId,
          seriesId: seriesId,
          title: title,
          seriesTitle: await db.seriesTitle(sourceId, seriesId),
          settings: settings,
          source: OfflinePages(archivePath, entries),
          initialPage: resolveInitialReaderPage(
            savedCurrentPage: savedPage,
            serverReadPage: book?.readPage,
          ),
          colorAdjustments: colorAdjustments,
        );
      } on ArchiveException {
        // Corrupt cache: quarantine and fall through to online.
        await cache.delete(sourceId, bookId);
      }
    }

    // Online path.
    final api = await ref.watch(contentApiForProvider(sourceId).future);
    if (api == null) {
      throw StateError('No connected source for this book.');
    }

    final cached = await db.getBook(sourceId, bookId);
    String seriesId;
    String title;
    int? serverReadPage;
    // With no local read state (e.g. right after a reinstall), resume must come
    // from the server's authoritative read-progress, NOT the cached
    // `Books.readPage`: that column is a display denormalization the home rails
    // populate asynchronously, so in the first moments after a fresh install it
    // can lag or be missing for a book - and the reader would then open at page
    // 1 despite the server knowing the position. Fetch the book fresh in that
    // case. When a local saved page exists it wins regardless (see
    // [resolveInitialReaderPage]), so the cached metadata is enough and no
    // network round-trip is needed.
    if (cached == null || savedPage == null) {
      try {
        final dto = await api.getBook(bookId);
        seriesId = dto.seriesId;
        title = dto.title;
        serverReadPage = dto.readPage;
        await db.upsertBook(bookToRow(sourceId, dto));
      } on ContentException {
        if (cached == null) rethrow; // no cache and no server: cannot resolve
        // Server unreachable: fall back to the last-known cached page.
        seriesId = cached.seriesId;
        title = cached.title;
        serverReadPage = cached.readPage;
      }
    } else {
      seriesId = cached.seriesId;
      title = cached.title;
      serverReadPage = cached.readPage;
    }

    final pages = await api.bookPages(bookId);

    String? direction;
    if (!await settingsRepo.has(sourceId, seriesId)) {
      try {
        direction = (await api.getSeries(seriesId)).readingDirection;
      } on ContentException {
        // Fall back to LTR defaults.
      }
    }
    final settings = await settingsRepo.load(
      sourceId,
      seriesId,
      mangaDirection: direction,
    );
    final colorAdjustments = await ColorSettingsRepository(
      db,
    ).resolve(sourceId, seriesId, bookId);

    return ReaderData(
      sourceId: sourceId,
      bookId: bookId,
      seriesId: seriesId,
      title: title,
      seriesTitle: await db.seriesTitle(sourceId, seriesId),
      settings: settings,
      source: OnlinePages(api, pages),
      initialPage: resolveInitialReaderPage(
        savedCurrentPage: savedPage,
        serverReadPage: serverReadPage,
      ),
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
    await ReaderSettingsRepository(
      ref.read(appDatabaseProvider),
    ).save(data.sourceId, data.seriesId, normalized);
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
