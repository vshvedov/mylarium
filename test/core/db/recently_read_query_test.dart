import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/core/db/database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> book(String id, {String number = '1', String sourceId = 's1'}) =>
      db.upsertBook(BooksCompanion.insert(
        sourceId: sourceId,
        id: id,
        seriesId: 'ser1',
        libraryId: 'lib1',
        title: id,
        number: number,
      ));

  Future<void> state(
    String id, {
    String? status,
    int? finishedAt,
    String sourceId = 's1',
  }) =>
      db.upsertBookState(BookStateCompanion.insert(
        sourceId: sourceId,
        bookId: id,
        status: Value(status),
        finishedAt: Value(finishedAt),
        updatedAt: finishedAt ?? 0,
      ));

  test('returns only completed books, most-recently-finished first', () async {
    await book('b1');
    await book('b2');
    await book('b3');
    await state('b1', status: 'completed', finishedAt: 100);
    await state('b2', status: 'completed', finishedAt: 300); // newest
    await state('b3', status: null, finishedAt: null); // in progress / unread

    final rows = await db.watchRecentlyReadBooks('s1').first;
    expect(rows.map((b) => b.id), ['b2', 'b1'],
        reason: 'completed only, finishedAt desc; b3 (not completed) excluded');
  });

  test('is scoped to the source', () async {
    await book('b1', sourceId: 's1');
    await book('b2', sourceId: 's2');
    await state('b1', status: 'completed', finishedAt: 10, sourceId: 's1');
    await state('b2', status: 'completed', finishedAt: 20, sourceId: 's2');

    expect((await db.watchRecentlyReadBooks('s1').first).map((b) => b.id),
        ['b1']);
    expect((await db.watchRecentlyReadBooks('s2').first).map((b) => b.id),
        ['b2']);
  });
}
