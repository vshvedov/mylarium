import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/theme/theme_controller.dart' show appDatabaseProvider;
import '../../data/komga/komga_api.dart';
import '../../data/komga/models/mappers.dart';
import '../../data/komga/models/page_dto.dart';
import '../../data/source/source_providers.dart';
import 'reader_models.dart';
import 'reader_settings_repository.dart';

part 'reader_controller.g.dart';

/// Everything the reader needs for one book: the transport, the page list, the
/// resolved series id, and the per-series settings. The current page index is
/// view state (read-position write-back is T6), not held here.
class ReaderData {
  const ReaderData({
    required this.sourceId,
    required this.bookId,
    required this.seriesId,
    required this.api,
    required this.pages,
    required this.settings,
  });

  final String sourceId;
  final String bookId;
  final String seriesId;
  final KomgaApi api;
  final List<PageDto> pages;
  final ReaderSettings settings;

  ReaderData copyWith({ReaderSettings? settings}) => ReaderData(
        sourceId: sourceId,
        bookId: bookId,
        seriesId: seriesId,
        api: api,
        pages: pages,
        settings: settings ?? this.settings,
      );
}

/// Loads a book for reading (online-first). Throws when there is no source/api
/// or the page list cannot be fetched; the screen renders an error state.
@riverpod
class ReaderController extends _$ReaderController {
  @override
  Future<ReaderData> build(String sourceId, String bookId) async {
    final api = await ref.watch(komgaApiForProvider(sourceId).future);
    if (api == null) {
      throw StateError('No connected source for this book.');
    }
    final db = ref.watch(appDatabaseProvider);

    // Resolve the series id (needed to key reader settings). Prefer the cached
    // book row; fall back to fetching the book online.
    final cached = await db.getBook(sourceId, bookId);
    String seriesId;
    if (cached != null) {
      seriesId = cached.seriesId;
    } else {
      final dto = await api.getBook(bookId);
      seriesId = dto.seriesId;
      await db.upsertBook(bookToRow(sourceId, dto));
    }

    final pages = await api.bookPages(bookId);
    final settings = await ReaderSettingsRepository(db).load(sourceId, seriesId);

    return ReaderData(
      sourceId: sourceId,
      bookId: bookId,
      seriesId: seriesId,
      api: api,
      pages: pages,
      settings: settings,
    );
  }

  /// Persists and applies new reader settings for this book's series.
  Future<void> updateSettings(ReaderSettings settings) async {
    final data = state.valueOrNull;
    if (data == null) return;
    await ReaderSettingsRepository(ref.read(appDatabaseProvider))
        .save(data.sourceId, data.seriesId, settings);
    state = AsyncData(data.copyWith(settings: settings));
  }
}
