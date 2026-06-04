import 'dart:io';

import 'package:drift/drift.dart' show Value;

import '../../core/db/database.dart';
import '../../core/fs/app_paths.dart';
import 'eviction.dart';

/// Storage usage summary for the storage screen.
class CacheUsage {
  const CacheUsage({
    required this.totalBytes,
    required this.pinnedBytes,
    required this.count,
  });

  final int totalBytes;
  final int pinnedBytes;
  final int count;

  static const empty = CacheUsage(totalBytes: 0, pinnedBytes: 0, count: 0);
}

/// Manages the on-disk offline archive cache: availability, LRU eviction to the
/// user cap (never touching pinned/permanent), pinning, and usage.
class OfflineCacheManager {
  const OfflineCacheManager(this._db);

  final AppDatabase _db;

  Future<bool> isAvailable(String sourceId, String bookId) async =>
      (await _db.getCachedAsset(sourceId, bookId)) != null;

  /// Absolute path to the cached archive, or null when not cached. Touches
  /// `lastAccessedAt` (LRU) as a side effect of opening.
  Future<String?> archivePath(String sourceId, String bookId) async {
    final asset = await _db.getCachedAsset(sourceId, bookId);
    if (asset == null) return null;
    await _db.touchCachedAsset(
        sourceId, bookId, DateTime.now().millisecondsSinceEpoch);
    return AppPaths.resolve(asset.relativePath);
  }

  Future<void> evictToCap() async {
    final settings = await _db.getOrCreateSettings();
    final assets = await _db.allCachedAssets();
    for (final victim in selectEvictions(assets, settings.cacheCapBytes)) {
      await _delete(victim);
    }
  }

  Future<void> pin(String sourceId, String bookId, bool pinned) async {
    final asset = await _db.getCachedAsset(sourceId, bookId);
    if (asset == null) return;
    await _db.upsertCachedAsset(CachedAssetsCompanion(
      sourceId: Value(asset.sourceId),
      bookId: Value(asset.bookId),
      kind: Value(asset.kind),
      relativePath: Value(asset.relativePath),
      sizeBytes: Value(asset.sizeBytes),
      sha: Value(asset.sha),
      lastAccessedAt: Value(asset.lastAccessedAt),
      pinned: Value(pinned),
      permanent: Value(asset.permanent),
    ));
  }

  Future<void> delete(String sourceId, String bookId) async {
    final asset = await _db.getCachedAsset(sourceId, bookId);
    if (asset != null) await _delete(asset);
  }

  Future<CacheUsage> usage() async {
    final assets = await _db.allCachedAssets();
    var total = 0, pinned = 0;
    for (final a in assets) {
      total += a.sizeBytes;
      if (a.pinned || a.permanent) pinned += a.sizeBytes;
    }
    return CacheUsage(
        totalBytes: total, pinnedBytes: pinned, count: assets.length);
  }

  Future<void> _delete(CachedAsset asset) async {
    final file = File(await AppPaths.resolve(asset.relativePath));
    if (file.existsSync()) await file.delete();
    await _db.deleteCachedAsset(asset.sourceId, asset.bookId);
    await _db.deleteDownloadTask(asset.sourceId, asset.bookId);
  }
}
