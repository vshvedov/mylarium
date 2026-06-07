import 'package:drift/drift.dart' show Variable;
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/core/db/database.dart';

import 'generated/schema.dart';
import 'generated/schema_v14.dart' as v14;

void main() {
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('v14 -> v15 adds the home_rail_items table, existing data intact',
      () async {
    final schema = await verifier.schemaAt(14);

    final oldDb = v14.DatabaseAtV14(schema.newConnection());
    await oldDb.customStatement(
      "INSERT INTO app_settings (id, theme_mode) VALUES (1, 'dark')",
    );
    await oldDb.close();

    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 15);

    // Existing settings survive the migration.
    expect((await db.getOrCreateSettings()).themeMode, 'dark');

    // The new table exists and round-trips.
    await db.customStatement(
      'INSERT INTO home_rail_items '
      '(source_id, rail_kind, position, owner_type, owner_id) '
      "VALUES ('s1', 'keepReading', 0, 'book', 'b1')",
    );
    final rows = await db
        .customSelect(
          'SELECT owner_id FROM home_rail_items WHERE source_id = ?1',
          variables: [Variable.withString('s1')],
        )
        .get();
    expect(rows.single.read<String>('owner_id'), 'b1');

    await db.close();
  });

  test('v8 -> v15 chained migration reaches the v15 schema', () async {
    final schema = await verifier.schemaAt(8);
    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 15);
    await db.close();
  });
}
