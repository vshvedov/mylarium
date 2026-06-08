import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/core/db/database.dart';

import '../../drift/generated/schema.dart';
import '../../drift/generated/schema_v1.dart' as v1;

/// Guards the v1 -> v2 migration (T2: the global `auto_advance` setting). v1 is
/// the collapsed alpha baseline; v2 is the first real step migration after it.
/// CLAUDE.md treats data loss across an app update as a release blocker, so this
/// asserts the migrated schema matches the committed v2 snapshot AND that an
/// existing settings row survives with the new column defaulted off.
void main() {
  late SchemaVerifier verifier;
  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('migrates v1 -> v2 to the generated v2 schema', () async {
    final connection = await verifier.startAt(1);
    final db = AppDatabase(connection);
    await verifier.migrateAndValidate(db, 2);
    await db.close();
  });

  test('preserves the settings row and defaults auto_advance off', () async {
    final schema = await verifier.schemaAt(1);
    final old = v1.DatabaseAtV1(schema.newConnection());
    await old.customStatement(
      "INSERT INTO app_settings (id, theme_mode, device_id) "
      "VALUES (1, 'dark', 'dev-1')",
    );
    await old.close();

    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 2);
    final settings = await db.getOrCreateSettings();
    expect(settings.themeMode, 'dark', reason: 'pre-migration data preserved');
    expect(settings.deviceId, 'dev-1');
    expect(settings.autoAdvance, isFalse, reason: 'new column defaults off');
    await db.close();
  });
}
