import '../../core/db/database.dart';

/// Pure LRU eviction selection: given all cached [assets] and a [capBytes]
/// budget, returns the assets to evict (least-recently-accessed first) so the
/// remaining total fits the cap. Pinned and permanent assets are never selected,
/// even if that leaves the total over the cap (the caller surfaces a banner).
List<CachedAsset> selectEvictions(List<CachedAsset> assets, int capBytes) {
  var total = assets.fold<int>(0, (sum, a) => sum + a.sizeBytes);
  if (total <= capBytes) return const [];

  final evictable = assets
      .where((a) => !a.pinned && !a.permanent)
      .toList()
    ..sort((a, b) => a.lastAccessedAt.compareTo(b.lastAccessedAt));

  final victims = <CachedAsset>[];
  for (final a in evictable) {
    if (total <= capBytes) break;
    victims.add(a);
    total -= a.sizeBytes;
  }
  return victims;
}
