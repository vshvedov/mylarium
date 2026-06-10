import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/theme/theme_controller.dart'
    show appDatabaseProvider;
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/data/source/source_providers.dart';
import 'package:mylarium/features/library/thumbnail_cache.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  ProviderContainer container() {
    final c = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
      // A local source has no ContentApi; covers must still resolve from the
      // Thumbnails cache.
      contentApiForProvider('local-1').overrideWith((ref) async => null),
    ]);
    addTearDown(c.dispose);
    return c;
  }

  test('cover resolves from the cache when the source has no api', () async {
    await db.upsertThumbnail(ThumbnailsCompanion.insert(
      sourceId: 'local-1',
      ownerType: 'book',
      ownerId: 'lc1',
      bytes: Value(Uint8List.fromList([1, 2, 3])),
      fetchedAt: 0,
    ));
    final image = await container()
        .read(coverImageProvider('local-1', 'book', 'lc1').future);
    expect(image, isA<MemoryImage>());
  });

  test('cover is null when uncached and no api can fetch it', () async {
    final image = await container()
        .read(coverImageProvider('local-1', 'book', 'missing').future);
    expect(image, isNull);
  });
}
