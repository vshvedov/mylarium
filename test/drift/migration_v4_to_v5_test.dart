import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/core/db/database.dart';

import 'generated/schema.dart';
import 'generated/schema_v4.dart' as v4;

void main() {
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  // download_tasks gained a column in v6, so the current migrator can only
  // reproduce the head schema; these validate the v4 -> head (v6) path.
  test('v4 -> v6 preserves data and adds the offline tables', () async {
    final schema = await verifier.schemaAt(4);

    final oldDb = v4.DatabaseAtV4(schema.newConnection());
    await oldDb.customStatement(
      "INSERT INTO sources (id, kind, label) VALUES ('s1', 'komga', 'Test')",
    );
    await oldDb.customStatement(
      'INSERT INTO series (source_id, id, library_id, title, title_sort, '
      "books_count) VALUES ('s1', 'ser1', 'lib1', 'Akira', 'Akira', 6)",
    );
    await oldDb.close();

    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 6);

    // v4 data survived.
    final series = await db.watchSeries('s1').first;
    expect(series.single.title, 'Akira');

    // New offline tables are usable.
    await db.upsertCachedAsset(CachedAssetsCompanion(
      sourceId: const Value('s1'),
      bookId: const Value('b1'),
      relativePath: const Value('media/archives/s1/b1.archive'),
      sizeBytes: const Value(123),
      lastAccessedAt: const Value(1000),
    ));
    final asset = await db.getCachedAsset('s1', 'b1');
    expect(asset?.relativePath, 'media/archives/s1/b1.archive');
    expect(asset?.pinned, isFalse);

    await db.upsertDownloadTask(DownloadTasksCompanion(
      sourceId: const Value('s1'),
      bookId: const Value('b1'),
      taskId: const Value('t1'),
      state: const Value('running'),
      updatedAt: const Value(1),
    ));
    final task = await db.getDownloadTask('s1', 'b1');
    expect(task?.state, 'running');

    await db.close();
  });

  test('v2 -> head chained migration reaches the head schema', () async {
    final schema = await verifier.schemaAt(2);
    final db = AppDatabase(schema.newConnection());
    // Validates at head (11): the from<4 createTable now emits reader_settings
    // with the v11 `direction` column, so this path must reach head to match.
    await verifier.migrateAndValidate(db, 11);
    await db.close();
  });
}
