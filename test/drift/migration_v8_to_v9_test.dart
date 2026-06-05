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
    final rs = await db.getReaderSettings('s1', 'ser1');
    expect(rs, isNotNull);
    expect(rs!.mode, 'pagedRtl');

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

  test('v2 -> v9 chained migration reaches the v9 schema', () async {
    final schema = await verifier.schemaAt(2);
    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 9);
    await db.close();
  });
}
