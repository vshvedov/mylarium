import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/core/db/database.dart';

import 'generated/schema.dart';
import 'generated/schema_v6.dart' as v6;

void main() {
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('v6 -> v7 preserves data and adds sync + stats schema', () async {
    final schema = await verifier.schemaAt(6);

    final oldDb = v6.DatabaseAtV6(schema.newConnection());
    await oldDb.customStatement(
      'INSERT INTO app_settings (id, theme_mode, reduce_motion_override, '
      'cache_cap_bytes, auto_cache_enabled, download_wifi_only) '
      "VALUES (1, 'dark', 0, 999, 1, 0)",
    );
    await oldDb.customStatement(
      'INSERT INTO series (source_id, id, library_id, title, title_sort, '
      'books_count) '
      "VALUES ('s1', 'ser1', 'lib1', 'Akira', 'akira', 6)",
    );
    await oldDb.close();

    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 7);

    // Old settings survived; deviceId is generated on first read.
    final settings = await db.getOrCreateSettings();
    expect(settings.themeMode, 'dark');
    expect(settings.cacheCapBytes, 999);
    expect(settings.deviceId, isNotNull);
    expect(settings.deviceId, isNotEmpty);

    // Old series row survived; series metadata lives in the new side table and
    // is empty until the series is re-synced.
    final series = await db.getSeries('s1', 'ser1');
    expect(series, isNotNull);
    expect(series!.title, 'Akira');
    expect(await db.getSeriesMeta('s1', 'ser1'), isNull);

    // New tables are usable and the sync-queue unique collapse works.
    await db.enqueueSync(
      SyncQueueCompanion.insert(
        sourceId: 's1',
        bookId: 'b1',
        page: 3,
        queuedAt: 10,
      ),
    );
    await db.enqueueSync(
      SyncQueueCompanion.insert(
        sourceId: 's1',
        bookId: 'b1',
        page: 7,
        queuedAt: 20,
      ),
    );
    final pending = await db.pendingSync();
    expect(
      pending,
      hasLength(1),
      reason: 'enqueue collapses per {source,book}',
    );
    expect(pending.single.page, 7);

    await db.close();
  });

  test('v5 -> v7 chained migration reaches the v7 schema', () async {
    final schema = await verifier.schemaAt(5);
    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 7);
    await db.close();
  });

  test('v2 -> v7 chained migration reaches the v7 schema', () async {
    final schema = await verifier.schemaAt(2);
    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 7);
    await db.close();
  });
}
