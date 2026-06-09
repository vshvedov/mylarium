import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/core/db/database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  LocalComicsCompanion comic(
    String id,
    String series,
    String number,
    double? sort, {
    String sourceId = 'local-1',
  }) =>
      LocalComicsCompanion.insert(
        id: id,
        sourceId: sourceId,
        kind: 'localCopy',
        managedPath: Value('media/local/$sourceId/$id.archive'),
        series: series,
        seriesSort: series.toLowerCase(),
        number: number,
        numberSort: Value(sort),
        title: '$series $number',
        pageOrder: '["p1.jpg"]',
        pagesCount: 1,
        sizeBytes: const Value(100),
        contentHash: Value('hash-$id'),
        importedAt: 0,
      );

  test('watchLocalSeries groups by series, sorted, with counts and cover',
      () async {
    await db.insertLocalComic(comic('b2', 'Berserk', '2', 2));
    await db.insertLocalComic(comic('b1', 'Berserk', '1', 1));
    await db.insertLocalComic(comic('a1', 'Akira', '1', 1));
    await db.insertLocalComic(comic('x1', 'Akira', '1', 1, sourceId: 'other'));

    final groups = await db.watchLocalSeries('local-1').first;
    expect(groups, hasLength(2));
    expect(groups[0].series, 'Akira');
    expect(groups[0].booksCount, 1);
    expect(groups[1].series, 'Berserk');
    expect(groups[1].booksCount, 2);
    // Cover comic is the first book by numberSort, not insertion order.
    expect(groups[1].coverComicId, 'b1');
  });

  test('watchLocalBooks orders by numberSort then title, specials last',
      () async {
    await db.insertLocalComic(comic('c10', 'Naruto', '10', 10));
    await db.insertLocalComic(comic('cs', 'Naruto', 'Special', null));
    await db.insertLocalComic(comic('c2', 'Naruto', '2', 2));
    final books = await db.watchLocalBooks('local-1', 'Naruto').first;
    // NULL numberSort (unnumbered specials) sorts last, not first.
    expect(books.map((b) => b.id), ['c2', 'c10', 'cs']);
  });

  test('findLocalComicByHash matches size + hash within the source', () async {
    await db.insertLocalComic(comic('d1', 'Dorohedoro', '1', 1));
    expect(await db.findLocalComicByHash('local-1', 100, 'hash-d1'), isNotNull);
    expect(await db.findLocalComicByHash('local-1', 999, 'hash-d1'), isNull);
    expect(await db.findLocalComicByHash('other', 100, 'hash-d1'), isNull);
  });

  test('localFilesSource finds the kind=local row', () async {
    expect(await db.localFilesSource(), isNull);
    await db.upsertSource(SourcesCompanion.insert(
      id: 'local-1',
      kind: 'local',
      label: 'Local files',
    ));
    expect((await db.localFilesSource())!.id, 'local-1');
  });
}
