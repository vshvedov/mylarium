import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/core/db/database.dart';

import 'generated/schema.dart';
import 'generated/schema_v7.dart' as v7;

void main() {
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('v7 -> v8 preserves settings and adds image-quality defaults', () async {
    final schema = await verifier.schemaAt(7);

    final oldDb = v7.DatabaseAtV7(schema.newConnection());
    await oldDb.customStatement(
      'INSERT INTO app_settings (id, theme_mode, reduce_motion_override, '
      'cache_cap_bytes, auto_cache_enabled, download_wifi_only, device_id) '
      "VALUES (1, 'dark', 0, 999, 1, 0, 'dev-123')",
    );
    await oldDb.close();

    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 8);

    final s = await db.getOrCreateSettings();
    // Old values survived.
    expect(s.themeMode, 'dark');
    expect(s.cacheCapBytes, 999);
    expect(s.deviceId, 'dev-123');
    // New columns default to Smart, middle manual stop.
    expect(s.imageQualitySmart, isTrue);
    expect(s.imageQualityManualLevel, 2);

    await db.updateImageQualitySmart(false);
    await db.updateImageQualityManualLevel(4);
    final s2 = await db.getOrCreateSettings();
    expect(s2.imageQualitySmart, isFalse);
    expect(s2.imageQualityManualLevel, 4);

    await db.close();
  });

  // Validated at head (v9): a from<7 chain createTable's sync_queue / series_meta
  // in their current (v9) shape, so this chain can only match the v9 snapshot.
  test('v2 -> v9 chained migration reaches the v9 schema', () async {
    final schema = await verifier.schemaAt(2);
    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 9);
    await db.close();
  });
}
