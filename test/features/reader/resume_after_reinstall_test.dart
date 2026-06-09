import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/theme/theme_controller.dart'
    show appDatabaseProvider;
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/data/source/content_api.dart';
import 'package:mylarium/data/source/models/book_dto.dart';
import 'package:mylarium/data/source/models/page_dto.dart';
import 'package:mylarium/data/source/source_providers.dart';
import 'package:mylarium/features/offline/offline_cache.dart';
import 'package:mylarium/features/offline/offline_providers.dart';
import 'package:mylarium/features/reader/reader_controller.dart';
import 'package:mylarium/features/reader/reader_models.dart';
import 'package:mylarium/features/reader/reader_settings_repository.dart';

/// A minimal online source: only [getBook] and [bookPages] are exercised here
/// (the reader skips the series direction probe because we seed reader settings).
class _FakeApi implements ContentApi {
  _FakeApi({required this.serverReadPage, required this.pageCount});

  final int serverReadPage;
  final int pageCount;

  @override
  Future<BookDto> getBook(String id) async => BookDto(
        id: id,
        seriesId: 'ser',
        libraryId: 'lib',
        name: id,
        title: 'Title',
        number: '1',
        pagesCount: pageCount,
        readPage: serverReadPage,
      );

  @override
  Future<List<PageDto>> bookPages(String id) async => [
        for (var i = 1; i <= pageCount; i++) PageDto(number: i, fileName: 'p$i'),
      ];

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test(
      'reinstall resume: with no local read state, the reader uses the '
      'authoritative server page even when the cached Books.readPage is stale',
      () async {
    // Simulate the post-reinstall race: a cached Books row whose denormalized
    // readPage is stale/clobbered (1), no BookState row, but the server knows
    // the real resume position (page 9).
    await db.upsertBook(BooksCompanion.insert(
      sourceId: 's',
      id: 'b',
      seriesId: 'ser',
      libraryId: 'lib',
      title: 'Title',
      number: '1',
      readPage: const Value(1),
    ));
    // Seed reader settings so build() skips the getSeries direction probe.
    await ReaderSettingsRepository(db)
        .save('s', 'ser', ReaderSettings.defaults());

    final c = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
      offlineCacheManagerProvider.overrideWithValue(OfflineCacheManager(db)),
      contentApiForProvider('s').overrideWith(
        (ref) async => _FakeApi(serverReadPage: 9, pageCount: 12),
      ),
    ]);
    addTearDown(c.dispose);

    final data = await c.read(readerControllerProvider('s', 'b').future);

    // Server page 9 (1-based) -> 0-based 8. The old code trusted the stale
    // cached readPage (1) and opened at page 1 (index 0).
    expect(data.initialPage, 8);
  });

  test('a local saved page still wins and needs no server round-trip', () async {
    await db.upsertBook(BooksCompanion.insert(
      sourceId: 's',
      id: 'b',
      seriesId: 'ser',
      libraryId: 'lib',
      title: 'Title',
      number: '1',
      readPage: const Value(9),
    ));
    await db.upsertBookState(BookStateCompanion.insert(
      sourceId: 's',
      bookId: 'b',
      currentPage: const Value(4),
      updatedAt: 0,
    ));
    await ReaderSettingsRepository(db)
        .save('s', 'ser', ReaderSettings.defaults());

    final c = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
      offlineCacheManagerProvider.overrideWithValue(OfflineCacheManager(db)),
      contentApiForProvider('s').overrideWith(
        (ref) async => _FakeApi(serverReadPage: 9, pageCount: 12),
      ),
    ]);
    addTearDown(c.dispose);

    final data = await c.read(readerControllerProvider('s', 'b').future);
    expect(data.initialPage, 4); // local state wins
  });
}
