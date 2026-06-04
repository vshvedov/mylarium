import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/core/db/database.dart';

import 'generated/schema.dart';
import 'generated/schema_v2.dart' as v2;

void main() {
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('v2 -> v3 preserves source/series data and adds the T3 tables + indexes',
      () async {
    final schema = await verifier.schemaAt(2);

    // Seed source + series rows against the v2 schema, BEFORE migrating.
    final oldDb = v2.DatabaseAtV2(schema.newConnection());
    await oldDb.customStatement(
      "INSERT INTO sources (id, kind, label) VALUES ('s1', 'komga', 'Test')",
    );
    await oldDb.customStatement(
      'INSERT INTO series (source_id, id, library_id, title, title_sort, '
      'books_count) '
      "VALUES ('s1', 'ser1', 'lib1', 'Akira', 'Akira', 6)",
    );
    await oldDb.close();

    // Open the real database (schemaVersion 3): triggers onUpgrade + validates
    // the resulting schema matches the committed v3 snapshot.
    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 3);

    // The v2 series row survived the upgrade unchanged (no data loss).
    final series = await db.watchSeries('s1').first;
    expect(series.single.title, 'Akira');

    // The new tables are usable post-migration.
    await db.upsertThumbnail(ThumbnailsCompanion(
      sourceId: const Value('s1'),
      ownerType: const Value('series'),
      ownerId: const Value('ser1'),
      bytes: Value(Uint8List.fromList([1, 2, 3])),
      fetchedAt: const Value(123),
    ));
    final thumb = await db.getThumbnail('s1', 'series', 'ser1');
    expect(thumb?.bytes, isNot(null));

    await db.upsertLibraryPref(const LibraryPrefsCompanion(
      sourceId: Value('s1'),
      libraryId: Value('lib1'),
      locked: Value(true),
    ));
    final pref = await db.getLibraryPref('s1', 'lib1');
    expect(pref?.locked, isTrue);

    await db.upsertCachedMetadata(const CachedMetadataCompanion(
      sourceId: Value('s1'),
      ownerType: Value('collections'),
      ownerId: Value('s1'),
      json: Value('[]'),
      fetchedAt: Value(1),
    ));
    final meta = await db.getCachedMetadata('s1', 'collections', 's1');
    expect(meta?.json, '[]');

    // The keyset query works post-migration.
    final page = await db.seriesPage(
      sourceId: 's1',
      limit: 10,
      includeRestricted: false,
    );
    expect(page.single.id, 'ser1');

    await db.close();
  });
}
