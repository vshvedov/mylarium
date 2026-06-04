import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/core/db/database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> seed(String id, String title, {int? ageRating}) =>
      db.upsertSeries(SeriesCompanion(
        sourceId: const Value('s1'),
        id: Value(id),
        libraryId: const Value('lib1'),
        title: Value(title),
        titleSort: Value(title),
        ageRating: Value(ageRating),
      ));

  test('seriesPage hides ageRating >= 18 by default, NULL is allowed', () async {
    await seed('a', 'Aaa'); // null rating
    await seed('b', 'Bbb', ageRating: 12);
    await seed('c', 'Ccc', ageRating: 18);
    await seed('d', 'Ddd', ageRating: 21);

    final hidden = await db.seriesPage(
      sourceId: 's1',
      limit: 50,
      includeRestricted: false,
    );
    expect(hidden.map((s) => s.id), ['a', 'b']);

    final shown = await db.seriesPage(
      sourceId: 's1',
      limit: 50,
      includeRestricted: true,
    );
    expect(shown.map((s) => s.id), ['a', 'b', 'c', 'd']);
  });
}
