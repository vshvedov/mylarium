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
  Future<int> refresh(
    String sourceId, {
    int page = 0,
    int size = 50,
    String? sort,
    SeriesSearch? search,
  }) async {
    final result = await _api.listSeries(
      page: page,
      size: size,
      sort: sort,
      search: search,
    );
    for (final dto in result.content) {
      await _db.upsertSeries(seriesToRow(sourceId, dto));
    }
    return result.totalElements;
  }

  Stream<List<SeriesRow>> watch(String sourceId) => _db.watchSeries(sourceId);
}
