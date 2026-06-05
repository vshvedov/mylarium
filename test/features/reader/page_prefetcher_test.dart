import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/features/reader/page_prefetcher.dart';
import 'package:mylarium/features/reader/page_source.dart';

class _IdProvider extends ImageProvider<_IdProvider> {
  const _IdProvider(this.index);
  final int index;

  @override
  Future<_IdProvider> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture(this);

  @override
  ImageStreamCompleter loadImage(_IdProvider key, ImageDecoderCallback decode) =>
      throw UnimplementedError();

  @override
  bool operator ==(Object other) =>
      other is _IdProvider && other.index == index;
  @override
  int get hashCode => index;
}

class _FakeSource implements PageSource {
  _FakeSource(this._count);
  final int _count;

  @override
  int get pageCount => _count;

  @override
  ImageProvider imageProvider(int i) => _IdProvider(i);

  @override
  ImageProvider thumbnail(int i) => _IdProvider(i);

  @override
  Future<ImageProvider> page(int i) async => _IdProvider(i);

  @override
  double? aspectRatio(int i) => null;

  @override
  Set<int> get widePages => const {};
}

void main() {
  test('precaches the ahead window and evicts behind on page change', () async {
    final precached = <int>[];
    final evicted = <int>[];
    final pf = PagePrefetcher(
      source: _FakeSource(20),
      ahead: 3,
      precache: (p) async => precached.add((p as _IdProvider).index),
      evict: (p) => evicted.add((p as _IdProvider).index),
    );

    await pf.onPage(0);
    expect(precached.toSet(), {0, 1, 2, 3});
    expect(evicted, isEmpty);
    expect(pf.live, {0, 1, 2, 3});

    precached.clear();
    await pf.onPage(5);
    // keep = {4,5,6,7,8}; newly precached = those not already live.
    expect(precached.toSet(), {4, 5, 6, 7, 8});
    // Evicted everything that fell outside the new window.
    expect(evicted.toSet(), {0, 1, 2, 3});
    expect(pf.live, {4, 5, 6, 7, 8});
  });

  test('clamps the ahead window at the last page', () async {
    final precached = <int>[];
    final pf = PagePrefetcher(
      source: _FakeSource(3),
      ahead: 3,
      precache: (p) async => precached.add((p as _IdProvider).index),
      evict: (_) {},
    );
    await pf.onPage(1);
    // keep = {0,1,2} (index-1=0, and 1,2 ahead; 3,4 are out of range).
    expect(precached.toSet(), {0, 1, 2});
  });
}
