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
          {
            'id': c.id,
            'name': c.name,
            'ordered': c.ordered,
            'seriesIds': c.seriesIds,
          },
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

  /// Creates a collection (optionally seeding it with a series). Callers
  /// invalidate the list provider, which re-runs [list] to refresh the cache,
  /// so create does not fetch the list again itself.
  Future<CollectionDto> create(
    String name, {
    List<String> seriesIds = const [],
  }) =>
      _api.createCollection(name: name, seriesIds: seriesIds);

  Future<void> addSeries(String collectionId, String seriesId) =>
      _mutate(collectionId,
          (ids) => ids.contains(seriesId) ? ids : [...ids, seriesId]);

  Future<void> removeSeries(String collectionId, String seriesId) => _mutate(
      collectionId, (ids) => [for (final e in ids) if (e != seriesId) e]);

  /// Applies [transform] to a collection's series, online-first with an
  /// optimistic cache rewrite and revert-on-failure. A FRESH [getCollection]
  /// avoids overwriting the server with a stale cached list (lost update).
  Future<void> _mutate(
    String collectionId,
    List<String> Function(List<String>) transform,
  ) async {
    final fresh = await _api.getCollection(collectionId);
    final next = transform(fresh.seriesIds);
    final original = await _readRaw();
    await _writeCache(collectionId, next);
    try {
      await _api.updateCollection(
        collectionId,
        name: fresh.name,
        ordered: fresh.ordered,
        seriesIds: next,
      );
    } on KomgaException {
      await _restore(original);
      rethrow;
    }
  }

  Future<String?> _readRaw() async {
    final row = await _db.getCachedMetadata(_sourceId, _ownerType, _sourceId);
    return row?.json;
  }

  /// Rewrites the cached collection list, replacing [collectionId]'s seriesIds.
  Future<void> _writeCache(String collectionId, List<String> seriesIds) async {
    final raw = await _readRaw();
    if (raw == null) return;
    final list = (jsonDecode(raw) as List).cast<Map<String, Object?>>();
    final next = [
      for (final c in list)
        if (c['id'] == collectionId) {...c, 'seriesIds': seriesIds} else c,
    ];
    await _db.upsertCachedMetadata(CachedMetadataCompanion(
      sourceId: Value(_sourceId),
      ownerType: const Value(_ownerType),
      ownerId: Value(_sourceId),
      json: Value(jsonEncode(next)),
      fetchedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));
  }

  Future<void> _restore(String? original) async {
    if (original == null) return;
    await _db.upsertCachedMetadata(CachedMetadataCompanion(
      sourceId: Value(_sourceId),
      ownerType: const Value(_ownerType),
      ownerId: Value(_sourceId),
      json: Value(original),
      fetchedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));
  }
}
