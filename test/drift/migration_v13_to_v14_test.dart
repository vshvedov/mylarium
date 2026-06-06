import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/core/db/database.dart';

import 'generated/schema.dart';
import 'generated/schema_v13.dart' as v13;

void main() {
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('v13 -> v14 adds delete_on_read defaulting to false', () async {
    final schema = await verifier.schemaAt(13);

    final oldDb = v13.DatabaseAtV13(schema.newConnection());
    await oldDb.customStatement(
      "INSERT INTO app_settings (id, theme_mode) VALUES (1, 'dark')",
    );
    await oldDb.close();

    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 14);

    final settings = await db.getOrCreateSettings();
    expect(settings.themeMode, 'dark', reason: 'existing settings intact');
    expect(settings.deleteOnRead ?? false, isFalse, reason: 'off by default');

    await db.updateDeleteOnRead(true);
    expect((await db.getOrCreateSettings()).deleteOnRead, isTrue);

    await db.close();
  });

  test('v8 -> v14 chained migration reaches the v14 schema', () async {
    final schema = await verifier.schemaAt(8);
    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 14);
    await db.close();
  });
}
