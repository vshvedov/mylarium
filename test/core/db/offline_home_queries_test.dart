import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/core/fs/app_paths.dart';
import 'package:mylarium/features/offline/offline_cache.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> book(String id, String series, {String number = '1'}) =>
      db.upsertBook(BooksCompanion.insert(
        sourceId: 's',
        id: id,
        seriesId: series,
        libraryId: 'l',
        title: id,
        number: number,
      ));

  Future<void> asset(String id, {required int at}) => db.upsertCachedAsset(
        CachedAssetsCompanion.insert(
          sourceId: 's',
          bookId: id,
          relativePath: 'media/$id.cbz',
          lastAccessedAt: at,
        ),
      );

  test('watchDownloadedBooks returns cached books, most-recent first', () async {
    await book('b1', 'ser1');
    await book('b2', 'ser1');
    await book('b3', 'ser2'); // not cached
    await asset('b1', at: 100);
    await asset('b2', at: 200); // more recent

    final rows = await db.watchDownloadedBooks('s').first;
    expect(rows.map((b) => b.id), ['b2', 'b1'],
        reason: 'lastAccessedAt desc; uncached b3 excluded');
  });

  test('watchCachedAssetsWithTitles pairs assets with book titles', () async {
    await book('b1', 'ser1'); // the helper sets title == id
    await asset('b1', at: 1);
    await asset('orphan', at: 2); // no book row

    final rows = await db.watchCachedAssetsWithTitles().first;
    final byId = {for (final r in rows) r.asset.bookId: r.title};
    expect(byId['b1'], 'b1', reason: 'title resolved from the book row');
    expect(byId['orphan'], isNull,
        reason: 'no book row -> null so the screen falls back to the id');
  });

  test('watchSeriesDownloadCounts reports total and downloaded', () async {
    await book('b1', 'ser1');
    await book('b2', 'ser1');
    await book('b3', 'ser1');
    await asset('b1', at: 1);
    await asset('b2', at: 2);

    final counts = await db.watchSeriesDownloadCounts('s', 'ser1').first;
    expect(counts.total, 3);
    expect(counts.downloaded, 2);
  });

  test('OfflineCacheManager.deleteSeries removes every cached book of a series',
      () async {
    // No real files; deleteSeries resolves the path (root needed) then drops the
    // row whether or not a file exists.
    AppPaths.debugOverrideRoot = '/tmp';
    addTearDown(() => AppPaths.debugOverrideRoot = null);
    await book('b1', 'ser1');
    await book('b2', 'ser1');
    await asset('b1', at: 1);
    await asset('b2', at: 2);

    await OfflineCacheManager(db).deleteSeries('s', 'ser1');

    final counts = await db.watchSeriesDownloadCounts('s', 'ser1').first;
    expect(counts.downloaded, 0);
  });
}
