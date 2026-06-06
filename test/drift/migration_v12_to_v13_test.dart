import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/core/db/database.dart';

import 'generated/schema.dart';
import 'generated/schema_v12.dart' as v12;

void main() {
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('v12 -> v13 adds home_layout and preserves settings', () async {
    final schema = await verifier.schemaAt(12);

    final oldDb = v12.DatabaseAtV12(schema.newConnection());
    await oldDb.customStatement(
      "INSERT INTO app_settings (id, theme_mode) VALUES (1, 'dark')",
    );
    await oldDb.close();

    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 13);

    final settings = await (db.select(db.appSettings)
          ..where((t) => t.id.equals(1)))
        .getSingle();
    expect(settings.themeMode, 'dark', reason: 'existing settings intact');
    expect(settings.homeLayout, isNull, reason: 'new column defaults to null');

    // The column is writable post-migration.
    await db.updateHomeLayout('[]');
    final after = await (db.select(db.appSettings)
          ..where((t) => t.id.equals(1)))
        .getSingle();
    expect(after.homeLayout, '[]');

    await db.close();
  });

  test('v8 -> v13 chained migration reaches the v13 schema', () async {
    final schema = await verifier.schemaAt(8);
    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 13);
    await db.close();
  });
}
