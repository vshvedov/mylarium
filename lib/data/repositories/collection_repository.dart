import 'dart:convert';

import 'package:drift/drift.dart' show Value;

import '../../core/db/database.dart';
import '../../core/network/komga_exception.dart';
import '../komga/komga_api.dart';
import '../komga/models/collection_dto.dart';

/// Collections (curated ordered sets of series). Fetches online and caches the
/// list as JSON in `CachedMetadata` so browsing survives a restart; on a
/// network failure it returns the cached list (empty when never fetched).
class CollectionRepository {
  const CollectionRepository(this._api, this._db, this._sourceId);

  final KomgaApi _api;
  final AppDatabase _db;
  final String _sourceId;

  static const _ownerType = 'collections';

  Future<List<CollectionDto>> list({int page = 0, int size = 200}) async {
    try {
      final result = await _api.listCollections(page: page, size: size);
      final raw = [
        for (final c in result.content)
          {'id': c.id, 'name': c.name, 'seriesIds': c.seriesIds},
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

  Future<List<CollectionDto>> _cached() async {
    final row = await _db.getCachedMetadata(_sourceId, _ownerType, _sourceId);
    if (row == null) return const [];
    final list = jsonDecode(row.json) as List;
    return [
      for (final e in list) CollectionDto.fromJson(e as Map<String, Object?>),
    ];
  }
}
