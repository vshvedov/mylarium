import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/theme/theme_controller.dart' show appDatabaseProvider;
import '../../core/db/database.dart';
import '../../core/fs/app_paths.dart';
import '../../core/fs/backup_exclusion.dart';
import '../../core/network/content_exception.dart';
import '../../data/source/content_api.dart';
import '../../data/source/source_providers.dart';

part 'thumbnail_cache.g.dart';

/// Inline-vs-disk threshold for cached thumbnails (PRD: < 256KB as BLOB).
const _inlineMaxBytes = 256 * 1024;

/// Resolves cover thumbnails for series/books, caching on first display. Small
/// images live inline as a Drift BLOB; larger spill to disk (relative path,
/// excluded from iCloud backup). The "exactly one of bytes/diskPath" invariant
/// is maintained on every upsert by nulling the sibling column.
///
/// When [_api] is null the cache operates in cache-only mode: hits from the
/// Thumbnails table are returned, and cache misses yield null (no network
/// fetch). This allows local sources (which have no [ContentApi]) to render
/// covers that were stored at import time.
class ThumbnailCache {
  const ThumbnailCache(this._db, this._api, this._sourceId);

  final AppDatabase _db;
  final ContentApi? _api;
  final String _sourceId;

  Future<ImageProvider?> provider(String ownerType, String ownerId) async {
    final cached = await _db.getThumbnail(_sourceId, ownerType, ownerId);
    if (cached != null) {
      final hit = await _fromRow(cached);
      if (hit != null) return hit;
    }
    return _fetchAndStore(ownerType, ownerId);
  }

  Future<ImageProvider?> _fromRow(Thumbnail row) async {
    if (row.bytes != null) return MemoryImage(row.bytes!);
    final rel = row.diskPath;
    if (rel != null) {
      final file = File(await AppPaths.resolve(rel));
      if (await file.exists()) return FileImage(file);
    }
    return null;
  }

  Future<ImageProvider?> _fetchAndStore(
      String ownerType, String ownerId) async {
    final api = _api;
    if (api == null) return null; // cache-only source (local); no fetch path
    final List<int> bytes;
    final String? etag;
    try {
      final (b, e) = ownerType == 'series'
          ? await api.seriesThumbnail(ownerId)
          : await api.bookThumbnail(ownerId);
      bytes = b;
      etag = e;
    } on ContentException {
      return null; // Cover falls back to a placeholder; never throws.
    }
    if (bytes.isEmpty) return null;

    final now = DateTime.now().millisecondsSinceEpoch;
    final data = Uint8List.fromList(bytes);
    if (data.length < _inlineMaxBytes) {
      await _db.upsertThumbnail(ThumbnailsCompanion(
        sourceId: Value(_sourceId),
        ownerType: Value(ownerType),
        ownerId: Value(ownerId),
        bytes: Value(data),
        diskPath: const Value(null),
        etag: Value(etag),
        fetchedAt: Value(now),
      ));
      return MemoryImage(data);
    }

    final rel = AppPaths.thumbnailRelativePath(_sourceId, ownerType, ownerId);
    final file = await AppPaths.prepareFile(rel);
    await file.writeAsBytes(data, flush: true);
    await BackupExclusion.exclude(file.path);
    await _db.upsertThumbnail(ThumbnailsCompanion(
      sourceId: Value(_sourceId),
      ownerType: Value(ownerType),
      ownerId: Value(ownerId),
      bytes: const Value(null),
      diskPath: Value(rel),
      etag: Value(etag),
      fetchedAt: Value(now),
    ));
    return FileImage(file);
  }
}

/// Resolves a cover [ImageProvider] for an owner under [sourceId]. Returns a
/// cached image if one exists (always), fetches via the network api when
/// available, or returns null (caller renders a placeholder). Null api means
/// cache-only mode (local sources store covers at import time).
@riverpod
Future<ImageProvider?> coverImage(
  Ref ref,
  String sourceId,
  String ownerType,
  String ownerId,
) async {
  final api = await ref.watch(contentApiForProvider(sourceId).future);
  final db = ref.watch(appDatabaseProvider);
  return ThumbnailCache(db, api, sourceId).provider(ownerType, ownerId);
}
