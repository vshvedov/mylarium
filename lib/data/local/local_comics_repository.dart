import '../../core/db/database.dart';

/// Read-side access to local comics for the T2 browse providers. A thin seam
/// over [AppDatabase] (local content is database-backed, not API-backed, so
/// unlike the server repositories there is no transport underneath).
class LocalComicsRepository {
  const LocalComicsRepository(this._db);
  final AppDatabase _db;

  /// One row per series on [sourceId], sorted, with counts and cover book id.
  Stream<List<LocalSeriesRaw>> watchSeries(String sourceId) =>
      _db.watchLocalSeries(sourceId);

  /// Books of one series, ordered by numberSort then title.
  Stream<List<LocalComic>> watchBooks(String sourceId, String series) =>
      _db.watchLocalBooks(sourceId, series);

  Future<LocalComic?> book(String id) => _db.getLocalComic(id);
}
