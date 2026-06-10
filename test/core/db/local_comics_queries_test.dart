import 'dart:typed_data';

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

  test('watchLocalKeepReading joins in-progress BookState, newest first',
      () async {
    await db.insertLocalComic(comic('k1', 'Akira', '1', 1));
    await db.insertLocalComic(comic('k2', 'Akira', '2', 2));
    await db.insertLocalComic(comic('k3', 'Akira', '3', 3));
    await db.insertLocalComic(comic('k4', 'Akira', '4', 4));
    await db.upsertBookState(BookStateCompanion.insert(
      sourceId: 'local-1',
      bookId: 'k1',
      status: const Value('reading'),
      updatedAt: 100,
    ));
    await db.upsertBookState(BookStateCompanion.insert(
      sourceId: 'local-1',
      bookId: 'k2',
      status: const Value('reading'),
      updatedAt: 200,
    ));
    await db.upsertBookState(BookStateCompanion.insert(
      sourceId: 'local-1',
      bookId: 'k3',
      status: const Value('completed'),
      updatedAt: 300,
    ));
    await db.upsertBookState(BookStateCompanion.insert(
      sourceId: 'local-1',
      bookId: 'k4',
      status: const Value('rereading'),
      updatedAt: 400,
    ));

    final reading = await db.watchLocalKeepReading('local-1').first;
    // k4 (rereading, 400) > k2 (reading, 200) > k1 (reading, 100); k3 excluded
    expect(reading.map((c) => c.id), ['k4', 'k2', 'k1']);
  });

  test('watchRecentlyImported orders by importedAt descending', () async {
    await db.insertLocalComic(comic('r1', 'A', '1', 1));
    await db.insertLocalComic(comic('r2', 'B', '1', 1));
    // comic() helper stamps importedAt: 0; bump one row.
    await (db.update(db.localComics)
          ..where((t) => t.id.equals('r2')))
        .write(const LocalComicsCompanion(importedAt: Value(999)));

    final recent = await db.watchRecentlyImported('local-1').first;
    expect(recent.map((c) => c.id), ['r2', 'r1']);
  });

  test('deleteLocalComic and deleteThumbnail remove the rows', () async {
    await db.insertLocalComic(comic('d9', 'Dorohedoro', '9', 9));
    await db.upsertThumbnail(ThumbnailsCompanion.insert(
      sourceId: 'local-1',
      ownerType: 'book',
      ownerId: 'd9',
      bytes: Value(Uint8List.fromList([1])),
      fetchedAt: 0,
    ));
    await db.deleteThumbnail('local-1', 'book', 'd9');
    await db.deleteLocalComic('d9');
    expect(await db.getLocalComic('d9'), isNull);
    expect(await db.getThumbnail('local-1', 'book', 'd9'), isNull);
  });
}
