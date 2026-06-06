import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/theme/theme_controller.dart';
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/features/library/library_browse_controllers.dart';
import 'package:mylarium/features/offline/offline_providers.dart';

/// A locked library is hidden from the cache-backed rails (Recently read,
/// Downloaded), not just the API ones.
void main() {
  late AppDatabase db;

  Future<void> seedSource() => db.upsertSource(const SourcesCompanion(
        id: Value('s1'),
        kind: Value('komga'),
        label: Value('T'),
      ));

  Future<void> book(String id, {required String library}) =>
      db.upsertBook(BooksCompanion.insert(
        sourceId: 's1',
        id: id,
        seriesId: 'ser1',
        libraryId: library,
        title: id,
        number: '1',
      ));

  Future<void> complete(String id, int finishedAt) =>
      db.upsertBookState(BookStateCompanion.insert(
        sourceId: 's1',
        bookId: id,
        status: const Value('completed'),
        finishedAt: Value(finishedAt),
        updatedAt: finishedAt,
      ));

  Future<void> cache(String id, int at) => db.upsertCachedAsset(
        CachedAssetsCompanion.insert(
          sourceId: 's1',
          bookId: id,
          relativePath: 'media/$id.cbz',
          lastAccessedAt: at,
        ),
      );

  Future<void> lockLibrary(String library) =>
      db.upsertLibraryPref(LibraryPrefsCompanion(
        sourceId: const Value('s1'),
        libraryId: Value(library),
        locked: const Value(true),
      ));

  ProviderContainer container() {
    final c = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
    ]);
    addTearDown(c.dispose);
    return c;
  }

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('Recently read hides books in a locked library', () async {
    await seedSource();
    await book('comic', library: 'comics');
    await book('manga', library: 'manga');
    await complete('comic', 100);
    await complete('manga', 200);
    await lockLibrary('manga');

    final items = await container().read(recentlyReadProvider.future);
    expect(items.map((b) => b.id), ['comic'],
        reason: 'the locked manga library is hidden');
  });

  test('Downloaded hides books in a locked library', () async {
    await seedSource();
    await book('comic', library: 'comics');
    await book('manga', library: 'manga');
    await cache('comic', 100);
    await cache('manga', 200);
    await lockLibrary('manga');

    final items = await container().read(downloadedBooksProvider.future);
    expect(items.map((b) => b.id), ['comic']);
  });
}
