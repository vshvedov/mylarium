import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/core/db/database.dart';

import 'generated/schema.dart';
import 'generated/schema_v1.dart' as v1;

void main() {
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('v1 -> v2 preserves settings and adds the source/metadata tables',
      () async {
    final schema = await verifier.schemaAt(1);

    // Seed a NON-default settings row against the v1 schema, BEFORE migrating.
    final oldDb = v1.DatabaseAtV1(schema.newConnection());
    await oldDb.customStatement(
      'INSERT INTO app_settings '
      '(id, theme_mode, reduce_motion_override, cache_cap_bytes) '
      "VALUES (1, 'dark', 0, 999)",
    );
    await oldDb.close();

    // Open the real database (schemaVersion 2): triggers onUpgrade + validates
    // the resulting schema matches the committed v2 snapshot.
    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 2);

    // The v1 row survived the upgrade unchanged (no data loss). Read it via
    // raw SQL: the typed mapper expects current (v6) columns that the v2 schema
    // does not have.
    final row = await db
        .customSelect('SELECT theme_mode, cache_cap_bytes FROM app_settings '
            'WHERE id = 1')
        .getSingle();
    expect(row.data['theme_mode'], 'dark');
    expect(row.data['cache_cap_bytes'], 999);

    // The new tables are usable post-migration.
    await db.upsertSource(const SourcesCompanion(
      id: Value('s1'),
      kind: Value('komga'),
      label: Value('Test'),
    ));
    await db.upsertSeries(const SeriesCompanion(
      sourceId: Value('s1'),
      id: Value('ser1'),
      libraryId: Value('lib1'),
      title: Value('Akira'),
      titleSort: Value('Akira'),
    ));
    final rows = await db.watchSeries('s1').first;
    expect(rows.single.title, 'Akira');

    await db.close();
  });
}
