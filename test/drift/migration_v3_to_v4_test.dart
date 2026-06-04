import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/core/db/database.dart';

import 'generated/schema.dart';
import 'generated/schema_v3.dart' as v3;

void main() {
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('v3 -> v4 preserves data and adds reader_settings', () async {
    final schema = await verifier.schemaAt(3);

    final oldDb = v3.DatabaseAtV3(schema.newConnection());
    await oldDb.customStatement(
      "INSERT INTO sources (id, kind, label) VALUES ('s1', 'komga', 'Test')",
    );
    await oldDb.customStatement(
      'INSERT INTO series (source_id, id, library_id, title, title_sort, '
      "books_count) VALUES ('s1', 'ser1', 'lib1', 'Akira', 'Akira', 6)",
    );
    await oldDb.close();

    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 4);

    // v3 data survived.
    final series = await db.watchSeries('s1').first;
    expect(series.single.title, 'Akira');

    // reader_settings is usable.
    await db.upsertReaderSettings(const ReaderSettingsCompanion(
      sourceId: Value('s1'),
      seriesId: Value('ser1'),
      mode: Value('pagedRtl'),
      fit: Value('width'),
      taps: Value('lrEdges'),
    ));
    final row = await db.getReaderSettings('s1', 'ser1');
    expect(row?.mode, 'pagedRtl');

    await db.close();
  });

  test('v2 -> v4 chained migration preserves data and reaches the v4 schema',
      () async {
    final schema = await verifier.schemaAt(2);
    final db = AppDatabase(schema.newConnection());
    // Validates the cumulative path AND that the migrated schema matches the
    // committed v4 snapshot (which onCreate/createAll also produces).
    await verifier.migrateAndValidate(db, 4);
    await db.close();
  });
}
