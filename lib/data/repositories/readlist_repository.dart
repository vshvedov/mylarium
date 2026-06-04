import 'dart:convert';

import 'package:drift/drift.dart' show Value;

import '../../core/db/database.dart';
import '../../core/network/komga_exception.dart';
import '../komga/komga_api.dart';
import '../komga/models/readlist_dto.dart';

/// Read lists (curated ordered sets of books). Fetches online and caches the
/// list as JSON in `CachedMetadata`; on a network failure returns the cached
/// list (empty when never fetched).
class ReadListRepository {
  const ReadListRepository(this._api, this._db, this._sourceId);

  final KomgaApi _api;
  final AppDatabase _db;
  final String _sourceId;

  static const _ownerType = 'readlists';

  Future<List<ReadListDto>> list({int page = 0, int size = 200}) async {
    try {
      final result = await _api.listReadLists(page: page, size: size);
      final raw = [
        for (final r in result.content)
          {'id': r.id, 'name': r.name, 'bookIds': r.bookIds},
      ];
      await _db.upsertCachedMetadata(CachedMetadataCompanion(
        sourceId: Value(_sourceId),
        ownerType: const Value(_ownerType),
        ownerId: Value(_sourceId),
        json: Value(jsonEncode(raw)),
        fetchedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ));
      return result.content;
    } on KomgaException {
      return _cached();
    }
  }

  Future<List<ReadListDto>> _cached() async {
    final row = await _db.getCachedMetadata(_sourceId, _ownerType, _sourceId);
    if (row == null) return const [];
    final list = jsonDecode(row.json) as List;
    return [
      for (final e in list) ReadListDto.fromJson(e as Map<String, Object?>),
    ];
  }
}
