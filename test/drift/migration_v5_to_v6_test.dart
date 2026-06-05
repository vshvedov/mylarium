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

    // Old settings survived; new columns default correctly. Read via raw SQL:
    // the typed mapper expects current (v7) columns the v6 schema lacks
    // (device_id), and getOrCreateSettings now generates it.
    final row = await db
        .customSelect('SELECT theme_mode, cache_cap_bytes, auto_cache_enabled, '
            'download_wifi_only FROM app_settings WHERE id = 1')
        .getSingle();
    expect(row.data['theme_mode'], 'dark');
    expect(row.data['cache_cap_bytes'], 999);
    expect(row.data['auto_cache_enabled'], 1);
    expect(row.data['download_wifi_only'], 1);

    await db.customStatement(
        'UPDATE app_settings SET auto_cache_enabled = 0 WHERE id = 1');
    final updated = await db
        .customSelect(
            'SELECT auto_cache_enabled FROM app_settings WHERE id = 1')
        .getSingle();
    expect(updated.data['auto_cache_enabled'], 0);

    await db.close();
  });

  test('v2 -> head chained migration reaches the head schema', () async {
    final schema = await verifier.schemaAt(2);
    final db = AppDatabase(schema.newConnection());
    // Validates at head (11): see migration_v3_to_v4_test for the rationale.
    await verifier.migrateAndValidate(db, 11);
    await db.close();
  });
}
