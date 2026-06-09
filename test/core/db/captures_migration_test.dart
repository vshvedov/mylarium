import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/core/db/database.dart';

import '../../drift/generated/schema.dart';
import '../../drift/generated/schema_v16.dart' as v16;

void main() {
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  test('migrates v16 -> v17 to the expected schema', () async {
    final connection = await verifier.startAt(16);
    final db = AppDatabase(connection);
    // Validates that running AppDatabase.migration from 16 to 17 yields exactly
    // the committed v17 schema snapshot (adds the captures table + its index).
    await verifier.migrateAndValidate(db, 17);
    await db.close();
  });

  test('v16 -> v17 preserves existing rows and the captures table works',
      () async {
    // schemaAt + newConnection lets a v16 db and the real db share the same
    // underlying data via separate connections (no multi-open race).
    final schema = await verifier.schemaAt(16);

    final old = v16.DatabaseAtV16(schema.newConnection());
    await old.customStatement(
      "INSERT INTO sources (id, kind, base_url, auth_kind, handle, label) "
      "VALUES ('s1', 'komga', 'http://x', 'basic', 'h', 'Test')",
    );
    await old.close();

    final db = AppDatabase(schema.newConnection());
    // First query opens the db and runs onUpgrade(16 -> 17).
    await db.customStatement('SELECT 1');

    // Existing data survived the additive migration.
    final survived = await db.customSelect('SELECT id FROM sources').get();
    expect(survived, hasLength(1));
    expect(survived.single.read<String>('id'), 's1');

    // The new captures table is usable after the upgrade.
    await db.insertCapture(CapturesCompanion.insert(
      id: 'c1',
      sourceId: 's1',
      seriesId: 'se1',
      bookId: 'b1',
      pageNumber: 3,
      relativePath: 'media/captures/s1/b1/c1.png',
      width: 100,
      height: 200,
      capturedAt: 1700000000000,
    ));
    final caps = await db.watchCaptures().first;
    expect(caps, hasLength(1));
    expect(caps.single.pageNumber, 3);

    await db.close();
  });
}
