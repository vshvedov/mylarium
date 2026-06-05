import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/core/db/database.dart';

/// T3 DB helpers: rating mirrors that survive server re-syncs, and the series
/// read-state writes / join.
void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> addBook(String id, String series, {int pages = 0}) =>
      db.upsertBook(BooksCompanion.insert(
        sourceId: 's',
        id: id,
        seriesId: series,
        libraryId: 'lib',
        title: id,
        number: '1',
        pagesCount: Value(pages),
      ));

  test('setBookRating creates a row for a never-read book and survives progress',
      () async {
    await db.setBookRating('s', 'b1', 4, 1000);
    expect((await db.getBookState('s', 'b1'))!.rating, 4);

    // A later progress write must not clear the rating.
    await db.upsertBookState(BookStateCompanion(
      sourceId: const Value('s'),
      bookId: const Value('b1'),
      status: const Value('reading'),
      currentPage: const Value(10),
      updatedAt: const Value(2000),
    ));
    final st = await db.getBookState('s', 'b1');
    expect(st!.rating, 4, reason: 'rating preserved across a progress write');
    expect(st.currentPage, 10);

    // Clearing.
    await db.setBookRating('s', 'b1', null, 3000);
    expect((await db.getBookState('s', 'b1'))!.rating, isNull);
  });

  test('setSeriesRating survives a series re-sync that omits rating', () async {
    await db.setSeriesRating('s', 'ser1', 5);
    expect((await db.getSeriesMeta('s', 'ser1'))!.rating, 5);

    // A series sync writes publisher/genres but not rating.
    await db.upsertSeriesMeta(SeriesMetaCompanion(
      sourceId: const Value('s'),
      seriesId: const Value('ser1'),
      publisher: const Value('Acme'),
    ));
    final m = await db.getSeriesMeta('s', 'ser1');
    expect(m!.rating, 5, reason: 'rating preserved across a re-sync');
    expect(m.publisher, 'Acme');
  });

  test('setSeriesBooksReadStates writes a state row for every book', () async {
    await addBook('b1', 'ser1', pages: 20);
    await addBook('b2', 'ser1'); // pagesCount 0

    await db.setSeriesBooksReadStates('s', 'ser1', read: true, now: 1000);
    expect((await db.getBookState('s', 'b1'))!.status, 'completed');
    expect((await db.getBookState('s', 'b1'))!.currentPage, 19);
    expect((await db.getBookState('s', 'b2'))!.status, 'completed');
    expect((await db.getBookState('s', 'b2'))!.currentPage, 0);

    await db.setSeriesBooksReadStates('s', 'ser1', read: false, now: 2000);
    expect((await db.getBookState('s', 'b1'))!.status, isNull);
    expect((await db.getBookState('s', 'b1'))!.currentPage, 0);
  });

  test('watchSeriesReadStates returns only books that have a state row',
      () async {
    await addBook('b1', 'ser1');
    await addBook('b2', 'ser1');
    // Only b1 gets a state row.
    await db.setBookRating('s', 'b1', 3, 1000);

    final states = await db.watchSeriesReadStates('s', 'ser1').first;
    expect(states.map((e) => e.bookId).toSet(), {'b1'});
  });

  test('deletePendingSyncForSeries drops only the series books rows', () async {
    await addBook('b1', 'ser1');
    await db.enqueueSync(SyncQueueCompanion.insert(
        sourceId: 's', bookId: 'b1', page: 3, queuedAt: 1));
    await db.enqueueSync(SyncQueueCompanion.insert(
        sourceId: 's', bookId: 'other', page: 3, queuedAt: 1));

    await db.deletePendingSyncForSeries('s', 'ser1');

    final pending = await db.pendingSync();
    expect(pending.map((e) => e.bookId), ['other']);
  });
}
