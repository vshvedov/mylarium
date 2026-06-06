import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/core/db/database.dart';

import 'generated/schema.dart';
import 'generated/schema_v10.dart' as v10;

void main() {
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('v10 -> v11 adds direction and backfills pagedRtl rows to rtl', () async {
    final schema = await verifier.schemaAt(10);

    final oldDb = v10.DatabaseAtV10(schema.newConnection());
    // Two v10 reader_settings rows (no `direction` column yet).
    await oldDb.customStatement(
      'INSERT INTO reader_settings (source_id, series_id, mode, fit, taps) '
      "VALUES ('s', 'ser1', 'pagedRtl', 'width', 'lrEdges')",
    );
    await oldDb.customStatement(
      'INSERT INTO reader_settings (source_id, series_id, mode, fit, taps) '
      "VALUES ('s', 'ser2', 'pagedLtr', 'width', 'lrEdges')",
    );
    await oldDb.close();

    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 11);

    // pagedRtl backfills to rtl; pagedLtr keeps the 'ltr' default.
    final r1 = await db.getReaderSettings('s', 'ser1');
    expect(r1, isNotNull);
    expect(r1!.direction, 'rtl');
    final r2 = await db.getReaderSettings('s', 'ser2');
    expect(r2!.direction, 'ltr');

    await db.close();
  });

  test('v8 -> v11 chained migration reaches the v11 schema', () async {
    final schema = await verifier.schemaAt(8);
    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 11);
    await db.close();
  });

  test('v10 -> v11 is idempotent when direction was already half-applied',
      () async {
    // Simulate a process killed mid-migration: the column was added but the
    // version bump never committed (user_version still 10). Re-running the
    // upgrade must NOT throw "duplicate column".
    final schema = await verifier.schemaAt(10);
    final oldDb = v10.DatabaseAtV10(schema.newConnection());
    await oldDb.customStatement(
      "ALTER TABLE reader_settings ADD COLUMN direction TEXT NOT NULL "
      "DEFAULT 'ltr'",
    );
    await oldDb.customStatement(
      'INSERT INTO reader_settings (source_id, series_id, mode, fit, taps) '
      "VALUES ('s', 'ser1', 'pagedRtl', 'width', 'lrEdges')",
    );
    await oldDb.close();

    final db = AppDatabase(schema.newConnection());
    // Reaches head without re-adding the column; the backfill still runs.
    await verifier.migrateAndValidate(db, 11);
    expect((await db.getReaderSettings('s', 'ser1'))!.direction, 'rtl');
    await db.close();
  });
}
