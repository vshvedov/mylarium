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
          {
            'id': r.id,
            'name': r.name,
            'ordered': r.ordered,
            'bookIds': r.bookIds,
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

  Future<List<ReadListDto>> _cached() async {
    final row = await _db.getCachedMetadata(_sourceId, _ownerType, _sourceId);
    if (row == null) return const [];
    final list = jsonDecode(row.json) as List;
    return [
      for (final e in list) ReadListDto.fromJson(e as Map<String, Object?>),
    ];
  }

  /// Creates a read list (optionally seeding it with a book). Callers invalidate
  /// the list provider, which re-runs [list] to refresh the cache, so create
  /// does not fetch the list again itself.
  Future<ReadListDto> create(
    String name, {
    List<String> bookIds = const [],
  }) =>
      _api.createReadList(name: name, bookIds: bookIds);

  Future<void> addBook(String readListId, String bookId) => _mutate(
      readListId, (ids) => ids.contains(bookId) ? ids : [...ids, bookId]);

  Future<void> removeBook(String readListId, String bookId) =>
      _mutate(readListId, (ids) => [for (final e in ids) if (e != bookId) e]);

  /// Applies [transform] to a read list's books, online-first with an optimistic
  /// cache rewrite and revert-on-failure; a FRESH [getReadList] avoids a stale
  /// lost-update.
  Future<void> _mutate(
    String readListId,
    List<String> Function(List<String>) transform,
  ) async {
    final fresh = await _api.getReadList(readListId);
    final next = transform(fresh.bookIds);
    final original = await _readRaw();
    await _writeCache(readListId, next);
    try {
      await _api.updateReadList(
        readListId,
        name: fresh.name,
        ordered: fresh.ordered,
        bookIds: next,
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

  Future<void> _writeCache(String readListId, List<String> bookIds) async {
    final raw = await _readRaw();
    if (raw == null) return;
    final list = (jsonDecode(raw) as List).cast<Map<String, Object?>>();
    final next = [
      for (final r in list)
        if (r['id'] == readListId) {...r, 'bookIds': bookIds} else r,
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
