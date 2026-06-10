import '../../core/db/database.dart';
import '../../core/fs/disk_quota.dart';

/// Pure LRU eviction selection for the AUTO-CACHE pool. The [capBytes] budget
/// applies ONLY to evictable (non-pinned, non-permanent) assets - manual
/// downloads (permanent) live in a separate, uncapped pool and never count
/// toward the cap or get evicted. Returns the assets to evict
/// (least-recently-accessed first) so the auto-cache total fits the cap.
///
/// Ordering comes from the DB `lastAccessedAt` (not file mtime); the shared
/// [DiskQuota.selectVictims] core owns the cap walk itself.
List<CachedAsset> selectEvictions(List<CachedAsset> assets, int capBytes) {
  final evictable = assets
      .where((a) => !a.pinned && !a.permanent)
      .toList()
    ..sort((a, b) => a.lastAccessedAt.compareTo(b.lastAccessedAt));
  return DiskQuota.selectVictims(
    orderedCandidates: evictable,
    capBytes: capBytes,
    sizeOf: (a) => a.sizeBytes,
  );
}
