import '../../core/db/database.dart';
import '../komga/komga_api.dart';
import '../komga/models/mappers.dart';
import '../komga/models/series_search.dart';

/// Fetches series for a source and upserts them with [sourceId] attached.
class SeriesRepository {
  const SeriesRepository(this._db, this._api);

  final AppDatabase _db;
  final KomgaApi _api;

  /// Refreshes one page of series for [sourceId]; returns the server's total
  /// element count (so callers know how many exist beyond this page).
  ///
  /// The demand-driven grid sync pins a STABLE server sort
  /// (`metadata.titleSort,asc`) so OFFSET paging covers every row exactly once.
  /// When [libraryId] is set the page is scoped to that library.
  Future<int> refresh(
    String sourceId, {
    int page = 0,
    int size = 50,
    String? sort = 'metadata.titleSort,asc',
    String? libraryId,
    SeriesSearch? search,
  }) async {
    final effectiveSearch = libraryId == null
        ? search
        : SeriesSearch(
            fullText: search?.fullText,
            libraryIds: [libraryId],
            status: search?.status,
            readStatus: search?.readStatus,
            genres: search?.genres,
            tags: search?.tags,
            publishers: search?.publishers,
            ageRatings: search?.ageRatings,
          );
    final result = await _api.listSeries(
      page: page,
      size: size,
      sort: sort,
      search: effectiveSearch,
    );
    for (final dto in result.content) {
      await _db.upsertSeries(seriesToRow(sourceId, dto));
      await _db.upsertSeriesMeta(seriesMetaToRow(sourceId, dto));
    }
    return result.totalElements;
  }

  Stream<List<SeriesRow>> watch(String sourceId) => _db.watchSeries(sourceId);

  /// Fetches one series by id from the server and upserts it, returning the
  /// stored row. Used by the detail screen when a series was opened without its
  /// row already in the local cache (so the real title shows, not a fallback).
  Future<SeriesRow?> fetchSeries(String sourceId, String seriesId) async {
    final dto = await _api.getSeries(seriesId);
    await _db.upsertSeries(seriesToRow(sourceId, dto));
    await _db.upsertSeriesMeta(seriesMetaToRow(sourceId, dto));
    return _db.getSeries(sourceId, seriesId);
  }
}
