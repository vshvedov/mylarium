import '../../core/db/database.dart';

/// Pure LRU eviction selection for the AUTO-CACHE pool. The [capBytes] budget
/// applies ONLY to evictable (non-pinned, non-permanent) assets - manual
/// downloads (permanent) live in a separate, uncapped pool and never count
/// toward the cap or get evicted. Returns the assets to evict
/// (least-recently-accessed first) so the auto-cache total fits the cap.
List<CachedAsset> selectEvictions(List<CachedAsset> assets, int capBytes) {
  final evictable = assets
      .where((a) => !a.pinned && !a.permanent)
      .toList()
    ..sort((a, b) => a.lastAccessedAt.compareTo(b.lastAccessedAt));

  var total = evictable.fold<int>(0, (sum, a) => sum + a.sizeBytes);
  if (total <= capBytes) return const [];

  final victims = <CachedAsset>[];
  for (final a in evictable) {
    if (total <= capBytes) break;
    victims.add(a);
    total -= a.sizeBytes;
  }
  return victims;
}
