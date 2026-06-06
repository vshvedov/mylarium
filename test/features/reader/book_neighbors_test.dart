import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/theme/theme_controller.dart'
    show appDatabaseProvider;
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/data/source/source_providers.dart';
import 'package:mylarium/features/reader/reader_navigation.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> book(String id, {double? sort}) =>
      db.upsertBook(BooksCompanion.insert(
        sourceId: 's',
        id: id,
        seriesId: 'ser',
        libraryId: 'l',
        title: 'Title $id',
        number: id,
        numberSort: Value(sort),
      ));

  // No api -> the provider skips the online refresh and resolves from the cache.
  ProviderContainer container() {
    final c = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
      contentApiForProvider('s').overrideWith((ref) async => null),
    ]);
    addTearDown(c.dispose);
    return c;
  }

  test('neighbors follow numberSort then number; NULL numberSort sorts first',
      () async {
    await book('b1', sort: 1);
    await book('b3', sort: 3);
    await book('b2', sort: 2);
    await book('bn'); // NULL numberSort -> SQLite sorts nulls first (ASC)
    final c = container();
    // Effective order: bn, b1, b2, b3.

    final mid = await c.read(bookNeighborsProvider('s', 'ser', 'b2').future);
    expect(mid.prevId, 'b1');
    expect(mid.prevTitle, 'Title b1');
    expect(mid.nextId, 'b3');

    final first = await c.read(bookNeighborsProvider('s', 'ser', 'bn').future);
    expect(first.hasPrev, isFalse);
    expect(first.nextId, 'b1');

    final last = await c.read(bookNeighborsProvider('s', 'ser', 'b3').future);
    expect(last.nextId, isNull);
    expect(last.prevId, 'b2');
  });

  test('book not in the cached order -> empty neighbors', () async {
    await book('b1', sort: 1);
    final c = container();
    final n = await c.read(bookNeighborsProvider('s', 'ser', 'missing').future);
    expect(n.hasNext, isFalse);
    expect(n.hasPrev, isFalse);
  });
}
