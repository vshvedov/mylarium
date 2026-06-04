import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/core/fs/app_paths.dart';
import 'package:mylarium/features/offline/eviction.dart';
import 'package:mylarium/features/offline/offline_cache.dart';

CachedAsset asset({
  required String bookId,
  required int size,
  required int accessed,
  bool pinned = false,
  bool permanent = false,
}) =>
    CachedAsset(
      sourceId: 's1',
      bookId: bookId,
      kind: 'archive',
      relativePath: 'media/archives/s1/$bookId.archive',
      sizeBytes: size,
      sha: null,
      lastAccessedAt: accessed,
      pinned: pinned,
      permanent: permanent,
    );

void main() {
  group('selectEvictions (pure)', () {
    test('nothing evicted when under cap', () {
      final a = [asset(bookId: 'a', size: 10, accessed: 1)];
      expect(selectEvictions(a, 100), isEmpty);
    });

    test('evicts least-recently-accessed first until under cap', () {
      final a = [
        asset(bookId: 'old', size: 50, accessed: 1),
        asset(bookId: 'mid', size: 50, accessed: 2),
        asset(bookId: 'new', size: 50, accessed: 3),
      ];
      // total 150, cap 100 -> evict oldest (50) leaves 100.
      final victims = selectEvictions(a, 100).map((e) => e.bookId).toList();
      expect(victims, ['old']);
    });

    test('never evicts pinned or permanent, even if over cap', () {
      final a = [
        asset(bookId: 'pin', size: 100, accessed: 1, pinned: true),
        asset(bookId: 'perm', size: 100, accessed: 2, permanent: true),
      ];
      expect(selectEvictions(a, 10), isEmpty);
    });

    test('evicts evictable but stops at pins', () {
      final a = [
        asset(bookId: 'pin', size: 100, accessed: 1, pinned: true),
        asset(bookId: 'free', size: 100, accessed: 2),
      ];
      // total 200, cap 50; only 'free' is evictable -> evict it, pin stays.
      expect(selectEvictions(a, 50).map((e) => e.bookId), ['free']);
    });
  });

  group('OfflineCacheManager.evictToCap (with files)', () {
    late AppDatabase db;
    late Directory tmp;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      tmp = await Directory.systemTemp.createTemp('evict_test');
      AppPaths.debugOverrideRoot = tmp.path;
      await db.getOrCreateSettings(); // ensure the row exists before updating
      await db.updateCacheCapBytes(100);
    });
    tearDown(() async {
      AppPaths.debugOverrideRoot = null;
      await db.close();
      if (tmp.existsSync()) await tmp.delete(recursive: true);
    });

    Future<void> seed(String bookId, int size, int accessed,
        {bool pinned = false}) async {
      final rel = AppPaths.archiveRelativePath('s1', bookId);
      final file = await AppPaths.prepareFile(rel);
      await file.writeAsBytes(List.filled(size, 0));
      await db.upsertCachedAsset(CachedAssetsCompanion(
        sourceId: const Value('s1'),
        bookId: Value(bookId),
        relativePath: Value(rel),
        sizeBytes: Value(size),
        lastAccessedAt: Value(accessed),
        pinned: Value(pinned),
      ));
    }

    test('cap applies only to the auto pool; pinned is exempt and uncounted',
        () async {
      // A large pinned asset must NOT count toward the cap nor be evicted.
      await seed('pinned', 1000, 0, pinned: true);
      await seed('old', 60, 1);
      await seed('new', 60, 2);

      await OfflineCacheManager(db).evictToCap();

      // Evictable total is 120 (the 1000-byte pin is uncounted); cap 100 ->
      // evict only the oldest auto ('old'). 'new' and 'pinned' remain.
      final remaining =
          (await db.allCachedAssets()).map((a) => a.bookId).toSet();
      expect(remaining, {'new', 'pinned'});
      expect(File('${tmp.path}/media/archives/s1/old.archive').existsSync(),
          isFalse);
      expect(File('${tmp.path}/media/archives/s1/pinned.archive').existsSync(),
          isTrue);
      expect(File('${tmp.path}/media/archives/s1/new.archive').existsSync(),
          isTrue);
    });
  });
}
