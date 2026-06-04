import '../komga/komga_api.dart';
import '../komga/models/collection_dto.dart';
import '../komga/models/page.dart';

/// Online-only in T2: returns collection DTOs without persisting (their Drift
/// table lands with the browse UI in T3).
class CollectionRepository {
  const CollectionRepository(this._api);

  final KomgaApi _api;

  Future<Page<CollectionDto>> list({int page = 0, int size = 50}) =>
      _api.listCollections(page: page, size: size);
}
