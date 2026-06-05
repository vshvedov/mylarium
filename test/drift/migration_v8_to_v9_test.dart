import 'package:drift/drift.dart' show Value;
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/core/db/database.dart';

import 'generated/schema.dart';
import 'generated/schema_v8.dart' as v8;

void main() {
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('v8 -> v9 preserves data and adds the color_settings table', () async {
    final schema = await verifier.schemaAt(8);

    final oldDb = v8.DatabaseAtV8(schema.newConnection());
    await oldDb.customStatement(
      'INSERT INTO app_settings (id, theme_mode, reduce_motion_override, '
      'cache_cap_bytes, auto_cache_enabled, download_wifi_only, device_id, '
      'image_quality_smart, image_quality_manual_level) '
      "VALUES (1, 'dark', 0, 999, 1, 0, 'dev-123', 1, 2)",
    );
    await oldDb.customStatement(
      'INSERT INTO reader_settings (source_id, series_id, mode, fit, taps, '
      'invert_taps, double_tap_zoom, animate_page_turn) '
      "VALUES ('s1', 'ser1', 'pagedRtl', 'width', 'lrEdges', 0, 1, 1)",
    );
    await oldDb.close();

    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 9);

    // Pre-existing rows survived untouched.
    final s = await db.getOrCreateSettings();
    expect(s.themeMode, 'dark');
    expect(s.cacheCapBytes, 999);
    expect(s.imageQualityManualLevel, 2);
    // Read via a raw select (not the head getReaderSettings, which expects the
    // v11 `direction` column this v9-validated db does not have yet).
    final rs = await db
        .customSelect("SELECT mode FROM reader_settings WHERE series_id = 'ser1'")
        .getSingle();
    expect(rs.data['mode'], 'pagedRtl');

    // The new table is usable.
    await db.upsertColorSettings(ColorSettingsCompanion(
      sourceId: const Value(''),
      scope: const Value('global'),
      scopeId: const Value(''),
      brightness: const Value(0.3),
      gamma: const Value(1.8),
      mode: const Value('sepia'),
      autoLevels: const Value(true),
    ));
    final row = await db.getColorSettings('', 'global', '');
    expect(row, isNotNull);
    expect(row!.brightness, 0.3);
    expect(row.gamma, 1.8);
    expect(row.mode, 'sepia');
    expect(row.autoLevels, isTrue);

    await db.close();
  });

  // Validated at head (v10): a from<7 chain createTable's sync_queue / series_meta
  // in their current (v10) shape (with op / rating), so this chain matches the
  // v10 snapshot, not the v9 one. See migration_v9_to_v10_test for the v9->v10
  // step and the T3 op/rating assertions.
  test('v2 -> head chained migration reaches the head schema', () async {
    final schema = await verifier.schemaAt(2);
    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 11);
    await db.close();
  });
}
