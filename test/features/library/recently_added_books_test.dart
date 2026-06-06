import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:mylarium/app/theme/theme_controller.dart';
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/data/komga/komga_api.dart';
import 'package:mylarium/data/source/source_providers.dart';
import 'package:mylarium/features/library/library_browse_controllers.dart';

/// A `books/latest` page carrying one book in [seriesId].
Map<String, Object?> _booksPage(String bookId, String seriesId) => {
      'content': [
        {
          'id': bookId,
          'seriesId': seriesId,
          'libraryId': 'lib1',
          'name': bookId,
          'metadata': {'title': bookId, 'number': '1'},
          'media': {'pagesCount': 20},
        },
      ],
      'totalElements': 1,
      'number': 0,
      'last': true,
    };

/// A single-series response for `getSeries`, with an optional ageRating.
Map<String, Object?> _series(String id, {int? ageRating}) => {
      'id': id,
      'libraryId': 'lib1',
      'name': id,
      'metadata': {
        'title': id,
        'titleSort': id,
        'ageRating': ?ageRating,
      },
      'booksCount': 1,
    };

void main() {
  late AppDatabase db;
  late Dio dio;
  late DioAdapter adapter;
  late KomgaApi api;

  Future<void> seedSource() => db.upsertSource(const SourcesCompanion(
        id: Value('s1'),
        kind: Value('komga'),
        label: Value('T'),
      ));

  Future<void> seedSeries(String id, {int? ageRating}) =>
      db.upsertSeries(SeriesCompanion(
        sourceId: const Value('s1'),
        id: Value(id),
        libraryId: const Value('lib1'),
        title: Value(id),
        titleSort: Value(id),
        ageRating: Value(ageRating),
      ));

  void stubLatest(String bookId, String seriesId) => adapter.onGet(
        '/api/v1/books/latest',
        (s) => s.reply(200, _booksPage(bookId, seriesId)),
        queryParameters: {'page': 0, 'size': 20},
      );

  ProviderContainer container() {
    final c = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
      activeKomgaApiProvider.overrideWith((ref) async => api),
    ]);
    addTearDown(c.dispose);
    return c;
  }

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dio = Dio(BaseOptions(baseUrl: 'https://komga.test'));
    adapter = DioAdapter(dio: dio);
    api = KomgaApi(dio);
  });
  tearDown(() => db.close());

  test('a cached restricted series hides its chapter by default', () async {
    await seedSource();
    await seedSeries('serR', ageRating: 21);
    stubLatest('b1', 'serR');

    final result = await container().read(recentlyAddedBooksProvider.future);
    expect(result, isEmpty);
  });

  test('a cached restricted series shows its chapter when restricted-visible',
      () async {
    await seedSource();
    await seedSeries('serR', ageRating: 21);
    await db.upsertLibraryPref(const LibraryPrefsCompanion(
      sourceId: Value('s1'),
      libraryId: Value('lib1'),
      locked: Value(false),
      showRestricted: Value(true),
    ));
    stubLatest('b1', 'serR');

    final result = await container().read(recentlyAddedBooksProvider.future);
    expect(result.map((b) => b.id), ['b1']);
  });

  test('an uncached series is resolved online; a safe rating shows the chapter',
      () async {
    await seedSource();
    stubLatest('b1', 'serX');
    adapter.onGet('/api/v1/series/serX',
        (s) => s.reply(200, _series('serX'))); // no ageRating -> not restricted

    final result = await container().read(recentlyAddedBooksProvider.future);
    expect(result.map((b) => b.id), ['b1']);
  });

  test('an uncached series resolved as restricted hides the chapter', () async {
    await seedSource();
    stubLatest('b1', 'serX');
    adapter.onGet('/api/v1/series/serX',
        (s) => s.reply(200, _series('serX', ageRating: 21)));

    final result = await container().read(recentlyAddedBooksProvider.future);
    expect(result, isEmpty);
  });

  test('an uncached series that fails to resolve hides the chapter', () async {
    await seedSource();
    stubLatest('b1', 'serX');
    adapter.onGet('/api/v1/series/serX', (s) => s.reply(500, {'error': 'boom'}));

    final result = await container().read(recentlyAddedBooksProvider.future);
    expect(result, isEmpty);
  });

  test('a Komga error on books/latest degrades to empty', () async {
    await seedSource();
    adapter.onGet(
      '/api/v1/books/latest',
      (s) => s.reply(500, {'error': 'boom'}),
      queryParameters: {'page': 0, 'size': 20},
    );

    final result = await container().read(recentlyAddedBooksProvider.future);
    expect(result, isEmpty);
  });
}
