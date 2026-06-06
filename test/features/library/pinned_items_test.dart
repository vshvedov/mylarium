import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/theme/theme_controller.dart';
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/features/library/pin_controllers.dart';

void main() {
  late AppDatabase db;

  Future<void> seedSource() => db.upsertSource(const SourcesCompanion(
        id: Value('s1'),
        kind: Value('komga'),
        label: Value('T'),
      ));

  Future<void> seedSeries(
    String id, {
    int booksCount = 1,
    String libraryId = 'lib1',
  }) =>
      db.upsertSeries(SeriesCompanion(
        sourceId: const Value('s1'),
        id: Value(id),
        libraryId: Value(libraryId),
        title: Value(id),
        titleSort: Value(id),
        booksCount: Value(booksCount),
      ));

  Future<void> seedBook(
    String id,
    String seriesId, {
    String number = '1',
    String libraryId = 'lib1',
  }) =>
      db.upsertBook(BooksCompanion.insert(
        sourceId: 's1',
        id: id,
        seriesId: seriesId,
        libraryId: libraryId,
        title: id,
        number: number,
      ));

  Future<void> lockLibrary(String libraryId) =>
      db.upsertLibraryPref(LibraryPrefsCompanion(
        sourceId: const Value('s1'),
        libraryId: Value(libraryId),
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

  test('a pinned series shows, decked when multi-book', () async {
    await seedSource();
    await seedSeries('serA', booksCount: 3);
    await db.setPinned('s1', 'series', 'serA', pinned: true, now: 100);

    final items = await container().read(pinnedItemsProvider.future);
    expect(items.map((e) => e.ownerId), ['serA']);
    expect(items.single.stacked, isTrue);
  });

  test('a pinned series in a locked library is hidden', () async {
    await seedSource();
    await seedSeries('serM', libraryId: 'manga');
    await lockLibrary('manga');
    await db.setPinned('s1', 'series', 'serM', pinned: true, now: 100);

    final items = await container().read(pinnedItemsProvider.future);
    expect(items, isEmpty);
  });

  test('a pinned chapter in a locked library is hidden', () async {
    await seedSource();
    await seedBook('b1', 'serM', libraryId: 'manga');
    await lockLibrary('manga');
    await db.setPinned('s1', 'book', 'b1', pinned: true, now: 100);

    final items = await container().read(pinnedItemsProvider.future);
    expect(items, isEmpty);
  });

  test('a pinned chapter in an unlocked library shows with its number', () async {
    await seedSource();
    await seedBook('b1', 'serA', number: '4');
    await db.setPinned('s1', 'book', 'b1', pinned: true, now: 100);

    final items = await container().read(pinnedItemsProvider.future);
    expect(items.single.ownerId, 'b1');
    expect(items.single.subtitle, 'No. 4');
  });

  test('a pinned item whose owner row is uncached is dropped', () async {
    await seedSource();
    await db.setPinned('s1', 'series', 'serGone', pinned: true, now: 100);

    final items = await container().read(pinnedItemsProvider.future);
    expect(items, isEmpty);
  });

  test('items are newest-pinned first', () async {
    await seedSource();
    await seedSeries('serA');
    await seedSeries('serB');
    await db.setPinned('s1', 'series', 'serA', pinned: true, now: 100);
    await db.setPinned('s1', 'series', 'serB', pinned: true, now: 200);

    final items = await container().read(pinnedItemsProvider.future);
    expect(items.map((e) => e.ownerId), ['serB', 'serA']);
  });
}
