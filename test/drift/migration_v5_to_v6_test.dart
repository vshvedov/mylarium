import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/core/db/database.dart';

import 'generated/schema.dart';
import 'generated/schema_v5.dart' as v5;

void main() {
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('v5 -> v6 preserves data and adds the auto-cache settings columns',
      () async {
    final schema = await verifier.schemaAt(5);

    final oldDb = v5.DatabaseAtV5(schema.newConnection());
    await oldDb.customStatement(
      'INSERT INTO app_settings (id, theme_mode, reduce_motion_override, '
      "cache_cap_bytes) VALUES (1, 'dark', 0, 999)",
    );
    await oldDb.close();

    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 6);

    // Old settings survived; new columns default correctly.
    final settings = await db.getOrCreateSettings();
    expect(settings.themeMode, 'dark');
    expect(settings.cacheCapBytes, 999);
    expect(settings.autoCacheEnabled, isTrue);
    expect(settings.downloadWifiOnly, isTrue);

    await db.updateAutoCacheEnabled(false);
    expect((await db.getOrCreateSettings()).autoCacheEnabled, isFalse);

    await db.close();
  });

  test('v2 -> v6 chained migration reaches the v6 schema', () async {
    final schema = await verifier.schemaAt(2);
    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 6);
    await db.close();
  });
}
