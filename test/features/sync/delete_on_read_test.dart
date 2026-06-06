import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/core/fs/app_paths.dart';
import 'package:mylarium/features/sync/sync_engine.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    // The settings row (id = 1) is created at app boot in production; create it
    // here so updateDeleteOnRead() has a row to update.
    await db.getOrCreateSettings();
    // delete() resolves a path before unlinking; no real file exists, so it just
    // drops the row, but the resolver still needs a root.
    AppPaths.debugOverrideRoot = '/tmp';
  });
  tearDown(() async {
    AppPaths.debugOverrideRoot = null;
    await db.close();
  });

  // A local source so recordProgress never reaches the Komga write-back path.
  SyncEngine engine() =>
      SyncEngine(db, (_) async => null, deviceId: 'dev', now: () => 1000);

  Future<void> source() => db.upsertSource(const SourcesCompanion(
        id: Value('src'),
        kind: Value('localCopy'),
        label: Value('S'),
      ));

  Future<void> cache(String bookId, {bool permanent = false}) =>
      db.upsertCachedAsset(CachedAssetsCompanion.insert(
        sourceId: 'src',
        bookId: bookId,
        relativePath: 'media/$bookId.cbz',
        lastAccessedAt: 1,
        permanent: Value(permanent),
      ));

  test('maybeDeleteOnRead removes an auto-cached chapter when the toggle is on',
      () async {
    await cache('b1');
    await db.updateDeleteOnRead(true);

    await engine().maybeDeleteOnRead('src', 'b1');

    expect(await db.getCachedAsset('src', 'b1'), isNull);
  });

  test('maybeDeleteOnRead keeps the cache when the toggle is off (default)',
      () async {
    await cache('b1');

    await engine().maybeDeleteOnRead('src', 'b1');

    expect(await db.getCachedAsset('src', 'b1'), isNotNull);
  });

  test('maybeDeleteOnRead keeps a manual (permanent) download even when on',
      () async {
    await cache('b1', permanent: true);
    await db.updateDeleteOnRead(true);

    await engine().maybeDeleteOnRead('src', 'b1');

    expect(await db.getCachedAsset('src', 'b1'), isNotNull,
        reason: 'explicit downloads are exempt');
  });

  test('markRead deletes the auto-cache when the toggle is on', () async {
    await source();
    await cache('b1');
    await db.updateDeleteOnRead(true);

    await engine().markRead('src', 'b1', 0);

    expect(await db.getCachedAsset('src', 'b1'), isNull);
  });

  test('recordProgress alone never deletes mid-session (the reader does it on '
      'teardown)', () async {
    await source();
    await cache('b1');
    await db.updateDeleteOnRead(true);

    await engine().recordProgress('src', 'b1', 0, true); // completes the book

    expect(await db.getCachedAsset('src', 'b1'), isNotNull,
        reason: 'deleting while the reader still holds the archive open would '
            'break in-flight decodes');
  });
}
