import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/core/db/database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> seed(
    String id, {
    required String libraryId,
    required String title,
    required String titleSort,
  }) =>
      db.upsertSeries(SeriesCompanion(
        sourceId: const Value('s1'),
        id: Value(id),
        libraryId: Value(libraryId),
        title: Value(title),
        titleSort: Value(titleSort),
        booksCount: const Value(1),
      ));

  Future<void> seedAll() async {
    await seed('id-a', libraryId: 'lib1', title: 'Alpha', titleSort: 'alpha');
    await seed('id-b', libraryId: 'lib1', title: 'Bravo', titleSort: 'bravo');
    await seed('id-c', libraryId: 'lib2', title: 'Charlie', titleSort: 'charlie');
    await seed('id-d', libraryId: 'lib2', title: 'Delta', titleSort: 'delta');
  }

  test('ascending order returns all series sorted by titleSort asc', () async {
    await seedAll();
    final rows = await db.watchSeriesSorted('s1').first;
    expect(rows.map((r) => r.titleSort), ['alpha', 'bravo', 'charlie', 'delta']);
  });

  test('descending order returns all series sorted by titleSort desc', () async {
    await seedAll();
    final rows = await db.watchSeriesSorted('s1', descending: true).first;
    expect(rows.map((r) => r.titleSort), ['delta', 'charlie', 'bravo', 'alpha']);
  });

  test('libraryId scope returns only series in that library', () async {
    await seedAll();
    final rows = await db.watchSeriesSorted('s1', libraryId: 'lib1').first;
    expect(rows.map((r) => r.titleSort), ['alpha', 'bravo']);
  });

  test('hiddenLibraryIds excludes the specified libraries', () async {
    await seedAll();
    final rows =
        await db.watchSeriesSorted('s1', hiddenLibraryIds: {'lib2'}).first;
    expect(rows.map((r) => r.titleSort), ['alpha', 'bravo']);
  });

  test('stream is reactive: one subscription re-emits after an upsert',
      () async {
    await seedAll();

    String sorts(List<SeriesRow> rows) =>
        '${rows.map((r) => r.titleSort).toList()}';

    // A single long-lived subscription must re-emit when the table changes -
    // the browse grid relies on this to fill live as the background sync runs.
    final expectation = expectLater(
      db.watchSeriesSorted('s1'),
      emitsInOrder([
        predicate<List<SeriesRow>>(
          (rows) => sorts(rows) == '[alpha, bravo, charlie, delta]',
          'the four seeded series',
        ),
        predicate<List<SeriesRow>>(
          (rows) => sorts(rows) == '[alpha, bravo, bravo z, charlie, delta]',
          'the list including the upserted series',
        ),
      ]),
    );

    // Let the first emission land, then insert a series sorting between bravo
    // and charlie; the same subscription must emit the updated list.
    await Future<void>.delayed(Duration.zero);
    await seed('id-bz',
        libraryId: 'lib1', title: 'Bravo Z', titleSort: 'bravo z');

    await expectation;
  });
}
