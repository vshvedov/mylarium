import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/core/db/database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> cacheSeries(String id, {required int booksCount}) =>
      db.upsertSeries(SeriesCompanion(
        sourceId: const Value('s1'),
        id: Value(id),
        libraryId: const Value('lib1'),
        title: Value('Title $id'),
        titleSort: Value('Title $id'),
        booksCount: Value(booksCount),
      ));

  test('no snapshot returns empty (cold)', () async {
    expect(await db.getRailSnapshot('s1', 'recentlyAddedSeries'), isEmpty);
  });

  test('replace then read round-trips in order and resolves titles', () async {
    await cacheSeries('a', booksCount: 3);
    await cacheSeries('b', booksCount: 1);
    await db.replaceRailSnapshot('s1', 'recentlyAddedSeries', const [
      (ownerType: 'series', ownerId: 'b'),
      (ownerType: 'series', ownerId: 'a'),
    ]);

    final rows = await db.getRailSnapshot('s1', 'recentlyAddedSeries');
    expect(rows.map((r) => r.ownerId), ['b', 'a'], reason: 'position order');
    expect(rows[0].title, 'Title b');
    expect(rows[1].booksCount, 3);
    expect(rows[0].libraryId, 'lib1');
  });

  test('replace overwrites the previous snapshot for that rail', () async {
    await cacheSeries('a', booksCount: 1);
    await db.replaceRailSnapshot('s1', 'recentlyAddedSeries',
        const [(ownerType: 'series', ownerId: 'a')]);
    await db.replaceRailSnapshot('s1', 'recentlyAddedSeries', const []);
    expect(await db.getRailSnapshot('s1', 'recentlyAddedSeries'), isEmpty);
  });

  test('a pointer whose owner is not cached resolves with a null title',
      () async {
    await db.replaceRailSnapshot('s1', 'keepReading',
        const [(ownerType: 'book', ownerId: 'ghost')]);
    final rows = await db.getRailSnapshot('s1', 'keepReading');
    expect(rows.single.title, isNull);
  });

  test('replacing one rail leaves another rail on the same source untouched',
      () async {
    await cacheSeries('a', booksCount: 1);
    await db.replaceRailSnapshot('s1', 'recentlyAddedSeries',
        const [(ownerType: 'series', ownerId: 'a')]);
    // A replace on a different rail must not disturb the first rail's snapshot.
    await db.replaceRailSnapshot('s1', 'recentlyUpdatedSeries',
        const [(ownerType: 'series', ownerId: 'a')]);

    expect((await db.getRailSnapshot('s1', 'recentlyAddedSeries')).map((r) => r.ownerId),
        ['a']);
    expect((await db.getRailSnapshot('s1', 'recentlyUpdatedSeries')).map((r) => r.ownerId),
        ['a']);
  });
}
