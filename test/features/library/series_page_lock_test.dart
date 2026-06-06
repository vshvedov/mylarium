import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/core/db/database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> seed(String id, String library) =>
      db.upsertSeries(SeriesCompanion(
        sourceId: const Value('s1'),
        id: Value(id),
        libraryId: Value(library),
        title: Value(id),
        titleSort: Value(id),
      ));

  test('seriesPage excludes series in hidden (locked) libraries', () async {
    await seed('a', 'comics');
    await seed('b', 'manga');
    await seed('c', 'comics');

    final all = await db.seriesPage(sourceId: 's1', limit: 50);
    expect(all.map((s) => s.id), ['a', 'b', 'c']);

    final visible = await db.seriesPage(
      sourceId: 's1',
      limit: 50,
      hiddenLibraryIds: const {'manga'},
    );
    expect(visible.map((s) => s.id), ['a', 'c'],
        reason: 'the locked manga library is excluded');
  });
}
