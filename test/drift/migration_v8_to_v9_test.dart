import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/core/db/database.dart';

import 'generated/schema.dart';
import 'generated/schema_v8.dart' as v8;

void main() {
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('v8 -> v9 preserves data and adds op + series rating', () async {
    final schema = await verifier.schemaAt(8);

    final oldDb = v8.DatabaseAtV8(schema.newConnection());
    // A v8 sync-queue row (no `op` column yet) and a v8 series-meta row
    // (no `rating` column yet).
    await oldDb.customStatement(
      'INSERT INTO sync_queue (source_id, book_id, page, completed, '
      'queued_at, attempts, state) '
      "VALUES ('s1', 'b1', 5, 0, 10, 0, 'pending')",
    );
    await oldDb.customStatement(
      'INSERT INTO series_meta (source_id, series_id, publisher, genres) '
      "VALUES ('s1', 'ser1', 'Acme', '[\"Action\"]')",
    );
    await oldDb.close();

    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 9);

    // The legacy queue row survived and its new `op` defaults to 'progress'.
    final q = await db
        .customSelect('SELECT book_id, page, op FROM sync_queue WHERE id = 1')
        .getSingle();
    expect(q.data['book_id'], 'b1');
    expect(q.data['page'], 5);
    expect(q.data['op'], 'progress');

    // The legacy series-meta row survived; the new `rating` column is present
    // and NULL until set.
    final meta = await db.getSeriesMeta('s1', 'ser1');
    expect(meta, isNotNull);
    expect(meta!.publisher, 'Acme');
    expect(meta.rating, isNull);

    // The new column is writable.
    await db.setSeriesRating('s1', 'ser1', 4);
    expect((await db.getSeriesMeta('s1', 'ser1'))!.rating, 4);

    await db.close();
  });

  test('v7 -> v9 chained migration reaches the v9 schema', () async {
    final schema = await verifier.schemaAt(7);
    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 9);
    await db.close();
  });

  test('v2 -> v9 chained migration reaches the v9 schema', () async {
    final schema = await verifier.schemaAt(2);
    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 9);
    await db.close();
  });
}
