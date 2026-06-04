import 'package:flutter/widgets.dart';

import 'page_source.dart';

/// Drives precache-ahead / evict-behind for the page pipeline. The precache and
/// evict callbacks are injected so the policy is unit-testable without a render
/// tree; [PagePrefetcher.forContext] wires the real Flutter calls.
class PagePrefetcher {
  PagePrefetcher({
    required this.source,
    required this.precache,
    required this.evict,
    this.ahead = 3,
  });

  /// Wires `precacheImage` / `imageCache.evict` for a live widget.
  factory PagePrefetcher.forContext(
    PageSource source,
    BuildContext context, {
    int ahead = 3,
  }) =>
      PagePrefetcher(
        source: source,
        ahead: ahead,
        precache: (p) => precacheImage(p, context),
        evict: (p) => p.evict(),
      );

  final PageSource source;
  final Future<void> Function(ImageProvider) precache;
  final void Function(ImageProvider) evict;

  /// Window precached ahead of the current page (PRD: precache 3-5).
  final int ahead;

  final Set<int> _live = {};

  /// Visible-for-tests view of the currently-precached page indices.
  @visibleForTesting
  Set<int> get live => _live;

  /// Max pages decoded concurrently while warming the window. Two is fast
  /// enough to stay ahead of reading without a decode/isolate burst on weak
  /// devices after a seek (where the whole window is cold at once).
  static const int _concurrency = 2;

  /// Precache the window `[index, index+ahead]` (plus one behind) and evict
  /// everything outside it. The keep-set's iteration order prioritizes the
  /// current page, then the pages ahead, then the one behind, so the immediate
  /// next page warms first.
  Future<void> onPage(int index) async {
    final keep = <int>{};
    for (var i = index; i <= index + ahead && i < source.pageCount; i++) {
      keep.add(i);
    }
    if (index - 1 >= 0) keep.add(index - 1);

    final toLoad = [
      for (final i in keep)
        if (!_live.contains(i)) i,
    ];
    for (var start = 0; start < toLoad.length; start += _concurrency) {
      await Future.wait([
        for (final i in toLoad.skip(start).take(_concurrency))
          source.page(i).then((p) async {
            await precache(p);
            _live.add(i);
          }),
      ]);
    }

    for (final i in _live.toList()) {
      if (!keep.contains(i)) {
        evict(await source.page(i));
        _live.remove(i);
      }
    }
  }
}
