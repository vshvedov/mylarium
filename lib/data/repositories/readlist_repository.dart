import '../komga/komga_api.dart';
import '../komga/models/page.dart';
import '../komga/models/readlist_dto.dart';

/// Online-only in T2: returns read-list DTOs without persisting (their Drift
/// table lands with the browse UI in T3).
class ReadListRepository {
  const ReadListRepository(this._api);

  final KomgaApi _api;

  Future<Page<ReadListDto>> list({int page = 0, int size = 50}) =>
      _api.listReadLists(page: page, size: size);
}
