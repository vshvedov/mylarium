import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/core/db/database.dart';

import 'generated/schema.dart';
import 'generated/schema_v6.dart' as v6;

void main() {
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  // Validated at head (v10) rather than v7: the v9->v10 step adds `op` to
  // sync_queue and `rating` to series_meta, both createTable'd in the from<7
  // block, so a fresh ->v7 migration now emits the v10 shape of those tables and
  // can no longer match the frozen v7 snapshot. This mirrors how the v4->v5
  // test validates at v6 after download_tasks.permanent landed there.
  test('v6 -> v10 preserves data and adds sync + stats schema', () async {
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
    await verifier.migrateAndValidate(db, 10);

    // Old settings survived. Read raw: the typed AppSetting mapper expects
    // current (v8) columns the v7 schema lacks. (deviceId generation is a
    // getOrCreateSettings concern, covered by app_database_test and v7->v8.)
    final row = await db
        .customSelect('SELECT theme_mode, cache_cap_bytes FROM app_settings '
            'WHERE id = 1')
        .getSingle();
    expect(row.data['theme_mode'], 'dark');
    expect(row.data['cache_cap_bytes'], 999);

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

  test('v5 -> v10 chained migration reaches the v10 schema', () async {
    final schema = await verifier.schemaAt(5);
    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 10);
    await db.close();
  });

  test('v2 -> head chained migration reaches the head schema', () async {
    final schema = await verifier.schemaAt(2);
    final db = AppDatabase(schema.newConnection());
    // Validates at head (11): the from<4 createTable now emits the v11
    // reader_settings shape (with `direction`).
    await verifier.migrateAndValidate(db, 11);
    await db.close();
  });
}
