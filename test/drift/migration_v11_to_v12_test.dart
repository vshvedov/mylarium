import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/core/db/database.dart';

import 'generated/schema.dart';
import 'generated/schema_v11.dart' as v11;

void main() {
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('v11 -> v12 creates an empty pins table and keeps existing rows',
      () async {
    final schema = await verifier.schemaAt(11);

    final oldDb = v11.DatabaseAtV11(schema.newConnection());
    // A pre-existing source row must survive the additive migration.
    await oldDb.customStatement(
      'INSERT INTO sources (id, kind, label) '
      "VALUES ('s1', 'komga', 'My Komga')",
    );
    await oldDb.close();

    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 12);

    // The new table exists and starts empty.
    final pinned = await db.watchPinnedItems('s1').first;
    expect(pinned, isEmpty);

    // The pre-existing source row is intact.
    final source = await db.getSource('s1');
    expect(source, isNotNull);
    expect(source!.label, 'My Komga');

    await db.close();
  });

  test('v11 -> v12 pin round-trips through the new table', () async {
    final schema = await verifier.schemaAt(11);
    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 12);

    await db.setPinned('s1', 'series', 'ser1', pinned: true, now: 1000);
    expect(await db.watchIsPinned('s1', 'series', 'ser1').first, isTrue);

    await db.setPinned('s1', 'series', 'ser1', pinned: false, now: 2000);
    expect(await db.watchIsPinned('s1', 'series', 'ser1').first, isFalse);

    await db.close();
  });

  test('v8 -> v12 chained migration reaches the v12 schema', () async {
    final schema = await verifier.schemaAt(8);
    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 12);
    await db.close();
  });
}
