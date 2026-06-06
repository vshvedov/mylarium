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

/// A `books/latest` page carrying one book in [libraryId].
Map<String, Object?> _booksPage(String bookId, String libraryId) => {
      'content': [
        {
          'id': bookId,
          'seriesId': 'ser1',
          'libraryId': libraryId,
          'name': bookId,
          'metadata': {'title': bookId, 'number': '1'},
          'media': {'pagesCount': 20},
        },
      ],
      'totalElements': 1,
      'number': 0,
      'last': true,
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

  Future<void> lockLibrary(String libraryId) =>
      db.upsertLibraryPref(LibraryPrefsCompanion(
        sourceId: const Value('s1'),
        libraryId: Value(libraryId),
        locked: const Value(true),
      ));

  void stubLatest(String bookId, {String libraryId = 'lib1'}) => adapter.onGet(
        '/api/v1/books/latest',
        (s) => s.reply(200, _booksPage(bookId, libraryId)),
        queryParameters: {'page': 0, 'size': 20},
      );

  ProviderContainer container() {
    final c = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
      contentApiForProvider('s1').overrideWith((ref) async => api),
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

  test('a chapter in an unlocked library shows', () async {
    await seedSource();
    stubLatest('b1');

    final result = await container().read(recentlyAddedBooksProvider('s1').future);
    expect(result.map((b) => b.id), ['b1']);
  });

  test('a chapter in a locked library is hidden', () async {
    await seedSource();
    await lockLibrary('lib1');
    stubLatest('b1');

    final result = await container().read(recentlyAddedBooksProvider('s1').future);
    expect(result, isEmpty);
  });

  test('a Komga error on books/latest degrades to empty', () async {
    await seedSource();
    adapter.onGet(
      '/api/v1/books/latest',
      (s) => s.reply(500, {'error': 'boom'}),
      queryParameters: {'page': 0, 'size': 20},
    );

    final result = await container().read(recentlyAddedBooksProvider('s1').future);
    expect(result, isEmpty);
  });
}
