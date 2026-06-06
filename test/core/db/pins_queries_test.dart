import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/core/db/database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> series(
    String id, {
    int booksCount = 1,
    int? ageRating,
    String libraryId = 'lib1',
    String sourceId = 's1',
  }) =>
      db.upsertSeries(SeriesCompanion(
        sourceId: Value(sourceId),
        id: Value(id),
        libraryId: Value(libraryId),
        title: Value(id),
        titleSort: Value(id),
        ageRating: Value(ageRating),
        booksCount: Value(booksCount),
      ));

  Future<void> book(
    String id,
    String seriesId, {
    String number = '1',
    String sourceId = 's1',
    String libraryId = 'lib1',
  }) =>
      db.upsertBook(BooksCompanion.insert(
        sourceId: sourceId,
        id: id,
        seriesId: seriesId,
        libraryId: libraryId,
        title: id,
        number: number,
      ));

  test('setPinned + watchIsPinned round-trip', () async {
    expect(await db.watchIsPinned('s1', 'series', 'serA').first, isFalse);

    await db.setPinned('s1', 'series', 'serA', pinned: true, now: 1000);
    expect(await db.watchIsPinned('s1', 'series', 'serA').first, isTrue);

    await db.setPinned('s1', 'series', 'serA', pinned: false, now: 2000);
    expect(await db.watchIsPinned('s1', 'series', 'serA').first, isFalse);
  });

  test('watchPinnedItems orders newest first, tie-breaking on (type, id)',
      () async {
    await series('serA');
    await series('serB');
    await series('serC');
    // serC is newest; serA and serB tie and fall back to id order (A before B).
    await db.setPinned('s1', 'series', 'serA', pinned: true, now: 100);
    await db.setPinned('s1', 'series', 'serB', pinned: true, now: 100);
    await db.setPinned('s1', 'series', 'serC', pinned: true, now: 200);

    final rows = await db.watchPinnedItems('s1').first;
    expect(rows.map((r) => r.ownerId), ['serC', 'serA', 'serB']);
  });

  test('a pinned series resolves title, booksCount and its library', () async {
    await series('serA', booksCount: 5, libraryId: 'libX');
    await db.setPinned('s1', 'series', 'serA', pinned: true, now: 100);

    final row = (await db.watchPinnedItems('s1').first).single;
    expect(row.ownerType, 'series');
    expect(row.title, 'serA');
    expect(row.booksCount, 5);
    expect(row.number, isNull);
    expect(row.libraryId, 'libX');
    expect(row.resolved, isTrue);
  });

  test('a pinned book resolves from its own row (no series needed)', () async {
    // No series row at all: the book row alone resolves it, with its own library.
    await book('b1', 'serGone', number: '7', libraryId: 'libB');
    await db.setPinned('s1', 'book', 'b1', pinned: true, now: 100);

    final row = (await db.watchPinnedItems('s1').first).single;
    expect(row.ownerType, 'book');
    expect(row.title, 'b1');
    expect(row.number, '7');
    expect(row.booksCount, 0);
    expect(row.libraryId, 'libB', reason: "the book's own library");
    expect(row.resolved, isTrue);
  });

  test('a pinned item whose owner row is evicted is unresolved', () async {
    await db.setPinned('s1', 'series', 'serGone', pinned: true, now: 100);
    final row = (await db.watchPinnedItems('s1').first).single;
    expect(row.title, isNull);
    expect(row.resolved, isFalse);
  });

  test('watchPinnedItems is scoped to the source', () async {
    await series('serA', sourceId: 's1');
    await series('serB', sourceId: 's2');
    await db.setPinned('s1', 'series', 'serA', pinned: true, now: 100);
    await db.setPinned('s2', 'series', 'serB', pinned: true, now: 100);

    final s1 = await db.watchPinnedItems('s1').first;
    expect(s1.map((r) => r.ownerId), ['serA']);
    final s2 = await db.watchPinnedItems('s2').first;
    expect(s2.map((r) => r.ownerId), ['serB']);
  });
}
