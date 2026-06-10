import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/core/fs/disk_quota.dart';

void main() {
  group('DiskQuota.enforce', () {
    late Directory tmp;

    setUp(() async {
      tmp = await Directory.systemTemp.createTemp('disk_quota_test');
    });
    tearDown(() async {
      if (tmp.existsSync()) await tmp.delete(recursive: true);
    });

    /// Writes a [size]-byte file whose mtime is [minutes] past a fixed epoch,
    /// so LRU order is fully deterministic.
    File write(String name, int size, int minutes) {
      final file = File('${tmp.path}/$name')
        ..writeAsBytesSync(List.filled(size, 0));
      file.setLastModifiedSync(
          DateTime(2026, 1, 1).add(Duration(minutes: minutes)));
      return file;
    }

    test('a missing directory is a no-op', () async {
      final freed = await DiskQuota.enforce(
        dir: Directory('${tmp.path}/nope'),
        capBytes: 10,
      );
      expect(freed, 0);
    });

    test('nothing is evicted when the total fits the cap', () async {
      final a = write('a', 40, 1);
      final b = write('b', 40, 2);

      final freed = await DiskQuota.enforce(dir: tmp, capBytes: 100);

      expect(freed, 0);
      expect(a.existsSync(), isTrue);
      expect(b.existsSync(), isTrue);
    });

    test('evicts least-recently-modified first until the total fits, and '
        'returns the bytes freed', () async {
      final old = write('old', 50, 1);
      final mid = write('mid', 50, 2);
      final fresh = write('fresh', 50, 3);

      // Total 150, cap 100 -> evict only the oldest (50) to reach 100.
      final freed = await DiskQuota.enforce(dir: tmp, capBytes: 100);

      expect(freed, 50);
      expect(old.existsSync(), isFalse);
      expect(mid.existsSync(), isTrue);
      expect(fresh.existsSync(), isTrue);
    });

    test('keeps evicting in LRU order until the cap fits', () async {
      final old = write('old', 50, 1);
      final mid = write('mid', 50, 2);
      final fresh = write('fresh', 50, 3);

      // Total 150, cap 60 -> evict old and mid (leaves 50).
      final freed = await DiskQuota.enforce(dir: tmp, capBytes: 60);

      expect(freed, 100);
      expect(old.existsSync(), isFalse);
      expect(mid.existsSync(), isFalse);
      expect(fresh.existsSync(), isTrue);
    });

    test('keepPaths are never evicted but still count toward the total',
        () async {
      final kept = write('kept', 50, 1); // oldest, would be evicted first
      final mid = write('mid', 50, 2);
      final fresh = write('fresh', 50, 3);

      // Total 150, cap 100 -> the oldest is kept, so the next-oldest goes.
      final freed = await DiskQuota.enforce(
        dir: tmp,
        capBytes: 100,
        keepPaths: {kept.path},
      );

      expect(freed, 50);
      expect(kept.existsSync(), isTrue);
      expect(mid.existsSync(), isFalse);
      expect(fresh.existsSync(), isTrue);
    });

    test('a kept file can leave the pool over cap', () async {
      final kept = write('kept', 100, 1);

      final freed = await DiskQuota.enforce(
        dir: tmp,
        capBytes: 10,
        keepPaths: {kept.path},
      );

      expect(freed, 0);
      expect(kept.existsSync(), isTrue);
    });

    test('include filter excludes files from the total and from eviction',
        () async {
      final stamp = write('a.src', 90, 1); // oldest AND large, but excluded
      final old = write('old', 50, 2);
      final fresh = write('fresh', 50, 3);

      // Included total is 100 (the 90-byte stamp is uncounted); cap 60 ->
      // evict only 'old'. The excluded stamp is never deleted.
      final freed = await DiskQuota.enforce(
        dir: tmp,
        capBytes: 60,
        include: (f) => !f.path.endsWith('.src'),
      );

      expect(freed, 50);
      expect(stamp.existsSync(), isTrue);
      expect(old.existsSync(), isFalse);
      expect(fresh.existsSync(), isTrue);
    });

    test('onEvict fires once per victim, owns deletion, and freed bytes still '
        'sum the victims', () async {
      final old = write('old', 50, 1);
      final mid = write('mid', 50, 2);
      final fresh = write('fresh', 50, 3);

      final evicted = <String>[];
      final freed = await DiskQuota.enforce(
        dir: tmp,
        capBytes: 60,
        onEvict: (file) async {
          evicted.add(file.path);
          await file.delete();
        },
      );

      expect(evicted, [old.path, mid.path]); // LRU order, one call per victim
      expect(freed, 100);
      expect(old.existsSync(), isFalse);
      expect(mid.existsSync(), isFalse);
      expect(fresh.existsSync(), isTrue);
    });
  });

  group('DiskQuota.selectVictims', () {
    (String, int) entry(String id, int size) => (id, size);

    test('returns nothing when the total fits the cap', () {
      final victims = DiskQuota.selectVictims(
        orderedCandidates: [entry('a', 50), entry('b', 50)],
        capBytes: 100,
        sizeOf: (e) => e.$2,
      );
      expect(victims, isEmpty);
    });

    test('selects the ordered prefix until the total fits', () {
      final victims = DiskQuota.selectVictims(
        orderedCandidates: [
          entry('old', 50),
          entry('mid', 50),
          entry('new', 50),
        ],
        capBytes: 100,
        sizeOf: (e) => e.$2,
      );
      expect(victims.map((e) => e.$1), ['old']);
    });

    test('keep candidates count toward the total but are skipped', () {
      final victims = DiskQuota.selectVictims(
        orderedCandidates: [
          entry('keep', 50),
          entry('mid', 50),
          entry('new', 50),
        ],
        capBytes: 100,
        sizeOf: (e) => e.$2,
        keep: (e) => e.$1 == 'keep',
      );
      expect(victims.map((e) => e.$1), ['mid']);
    });

    test('a kept candidate alone can leave the pool over cap', () {
      final victims = DiskQuota.selectVictims(
        orderedCandidates: [entry('keep', 100)],
        capBytes: 10,
        sizeOf: (e) => e.$2,
        keep: (_) => true,
      );
      expect(victims, isEmpty);
    });
  });
}
