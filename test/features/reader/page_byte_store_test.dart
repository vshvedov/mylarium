import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/core/fs/app_paths.dart';
import 'package:mylarium/features/reader/page_byte_store.dart';

void main() {
  late Directory tmp;

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('page_byte_store_test');
    AppPaths.debugOverrideRoot = tmp.path;
  });

  tearDown(() {
    AppPaths.debugOverrideRoot = null;
    if (tmp.existsSync()) tmp.deleteSync(recursive: true);
  });

  group('selectPageEvictions', () {
    test('returns nothing when under cap', () {
      final entries = [
        const PageCacheEntry(path: 'a', sizeBytes: 10, lastAccessedAt: 1),
        const PageCacheEntry(path: 'b', sizeBytes: 10, lastAccessedAt: 2),
      ];
      expect(selectPageEvictions(entries, 100), isEmpty);
    });

    test('evicts least-recently-accessed first until under cap', () {
      final entries = [
        const PageCacheEntry(path: 'old', sizeBytes: 40, lastAccessedAt: 1),
        const PageCacheEntry(path: 'mid', sizeBytes: 40, lastAccessedAt: 2),
        const PageCacheEntry(path: 'new', sizeBytes: 40, lastAccessedAt: 3),
      ];
      // total 120, cap 100 -> must drop 20+, so the single oldest (40) suffices.
      expect(selectPageEvictions(entries, 100), ['old']);
    });
  });

  group('PageByteStore', () {
    test('miss fetches once and writes the page to disk', () async {
      final store = PageByteStore();
      var calls = 0;
      final bytes = await store.bytes('s', 'b', 1, () async {
        calls++;
        return Uint8List.fromList([1, 2, 3]);
      });
      expect(bytes, [1, 2, 3]);
      expect(calls, 1);
      final abs = await AppPaths.resolve(store.relativePath('s', 'b', 1));
      expect(File(abs).existsSync(), isTrue);
    });

    test('hit reads from disk without calling fetch again', () async {
      final store = PageByteStore();
      var calls = 0;
      Future<Uint8List> fetch() async {
        calls++;
        return Uint8List.fromList([9]);
      }

      await store.bytes('s', 'b', 1, fetch);
      final second = await store.bytes('s', 'b', 1, fetch);
      expect(second, [9]);
      expect(calls, 1);
    });

    test('single-flight: concurrent calls share one fetch', () async {
      final store = PageByteStore();
      var calls = 0;
      final gate = Completer<Uint8List>();
      Future<Uint8List> fetch() {
        calls++;
        return gate.future;
      }

      final f1 = store.bytes('s', 'b', 2, fetch);
      final f2 = store.bytes('s', 'b', 2, fetch);
      gate.complete(Uint8List.fromList([7]));
      await Future.wait([f1, f2]);
      expect(calls, 1);
    });

    test('empty fetch result is not written to disk', () async {
      final store = PageByteStore();
      final bytes = await store.bytes('s', 'b', 3, () async => Uint8List(0));
      expect(bytes, isEmpty);
      final abs = await AppPaths.resolve(store.relativePath('s', 'b', 3));
      expect(File(abs).existsSync(), isFalse);
    });

    test('sweep evicts least-recently-used pages over the cap', () async {
      final store = PageByteStore(capBytes: 6, sweepThresholdBytes: 1);
      // Write page 1, then age it so it is unambiguously the LRU victim.
      await store.bytes(
        's',
        'b',
        1,
        () async => Uint8List.fromList([1, 2, 3, 4]),
      );
      final p1 = File(await AppPaths.resolve(store.relativePath('s', 'b', 1)));
      p1.setLastModifiedSync(DateTime.fromMillisecondsSinceEpoch(1000));
      // Writing page 2 crosses the tiny sweep threshold; total 8 > cap 6, so the
      // oldest page (1) is evicted while the just-written page (2) survives.
      await store.bytes(
        's',
        'b',
        2,
        () async => Uint8List.fromList([5, 6, 7, 8]),
      );
      final p2 = File(await AppPaths.resolve(store.relativePath('s', 'b', 2)));
      expect(p1.existsSync(), isFalse);
      expect(p2.existsSync(), isTrue);
    });
  });
}
