import '../../core/db/database.dart';
import '../komga/komga_api.dart';
import '../komga/models/mappers.dart';

/// Fetches libraries for a source and upserts them with [sourceId] attached.
class LibraryRepository {
  const LibraryRepository(this._db, this._api);

  final AppDatabase _db;
  final KomgaApi _api;

  /// Refreshes all libraries for [sourceId]; returns the count fetched.
  Future<int> refresh(String sourceId) async {
    final dtos = await _api.listLibraries();
    for (final dto in dtos) {
      await _db.upsertLibrary(libraryToRow(sourceId, dto));
    }
    return dtos.length;
  }

  Stream<List<Library>> watch(String sourceId) => _db.watchLibraries(sourceId);
}
