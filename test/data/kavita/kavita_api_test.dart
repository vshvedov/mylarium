import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:mylarium/data/kavita/auth/kavita_auth.dart';
import 'package:mylarium/data/kavita/kavita_api.dart';
import 'package:mylarium/data/source/models/series_search.dart';

KavitaApi _api(Dio dio) => KavitaApi(
      dio,
      KavitaAuth(
        baseUrl: 'https://kavita.test',
        apiKey: 'k',
        handshakeDio: Dio(),
      ),
      'k',
    );

void main() {
  test('getPage requests a 0-based page with the apiKey', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://kavita.test'));
    final adapter = DioAdapter(dio: dio);
    adapter.onGet(
      '/api/Reader/image',
      (s) => s.reply(200, [137, 80, 78, 71]),
      queryParameters: {'chapterId': '31', 'page': 0, 'apiKey': 'k'},
    );
    final bytes = await _api(dio).getPage('31', 1);
    expect(bytes, isNotEmpty);
  });

  test('patchReadProgress resolves ids via chapter-info then posts progress',
      () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://kavita.test'));
    final adapter = DioAdapter(dio: dio);
    adapter.onGet(
      '/api/Reader/chapter-info',
      (s) => s.reply(200, {
        'chapterId': null,
        'seriesId': 1,
        'volumeId': 31,
        'libraryId': 1,
        'pages': 219,
      }),
      queryParameters: {'chapterId': '31'},
    );
    adapter.onPost(
      '/api/Reader/progress',
      (s) => s.reply(200, ''),
      data: {
        'libraryId': 1,
        'seriesId': 1,
        'volumeId': 31,
        'chapterId': 31,
        // 1-based page 5 from the ContentApi contract -> 0-based pageNum 4.
        'pageNum': 4,
      },
    );
    // Should complete without throwing (the POST body must match exactly).
    await _api(dio).patchReadProgress('31', page: 5, completed: false);
  });

  test('listSeries full-text routes to the search endpoint', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://kavita.test'));
    final adapter = DioAdapter(dio: dio);
    adapter.onGet(
      '/api/Library/libraries',
      (s) => s.reply(200, [
        {'id': 1, 'name': 'Comics', 'type': 0},
      ]),
    );
    adapter.onGet(
      '/api/Search/search',
      (s) => s.reply(200, {
        'series': [
          {
            'seriesId': 1,
            'name': 'Berserk',
            'sortName': 'Berserk',
            'libraryId': 1,
            'volumeCount': 40,
            'chapterCount': 0,
          },
        ],
      }),
      queryParameters: {'queryString': 'ber'},
    );
    final page = await _api(dio)
        .listSeries(page: 0, search: const SeriesSearch(fullText: 'ber'));
    expect(page.content, hasLength(1));
    expect(page.content.single.id, '1');
    expect(page.content.single.booksCount, 40);
  });

  test('collection mutations throw; reads map titles', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://kavita.test'));
    final adapter = DioAdapter(dio: dio);
    adapter.onGet('/api/Collection',
        (s) => s.reply(200, [
              {'id': 1, 'title': 'Favorites'},
            ]));
    final api = _api(dio);
    expect((await api.listCollections()).content.single.name, 'Favorites');
    expect(() => api.createCollection(name: 'x', seriesIds: const []),
        throwsA(isA<Exception>()));
  });

  test('listAgeRatings drops the Unknown (0) sentinel', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://kavita.test'));
    final adapter = DioAdapter(dio: dio);
    adapter.onGet(
        '/api/Metadata/age-ratings',
        (s) => s.reply(200, [
              {'value': 0, 'title': 'Unknown'},
              {'value': 4, 'title': 'G'},
              {'value': 6, 'title': 'Teen'},
            ]));
    expect(await _api(dio).listAgeRatings(), [4, 6]);
  });

  test('reading lists and their items map through', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://kavita.test'));
    final adapter = DioAdapter(dio: dio);
    adapter.onPost(
      '/api/ReadingList/lists',
      (s) => s.reply(200, [
        {'id': 1, 'title': 'My List'},
      ]),
      data: const {},
      queryParameters: {'pageNumber': 1, 'pageSize': 50},
    );
    adapter.onGet(
      '/api/ReadingList/items',
      (s) => s.reply(200, [
        {
          'chapterId': 31,
          'seriesId': 1,
          'libraryId': 1,
          'title': 'Volume 1',
          'pagesTotal': 219,
          'pagesRead': 0,
          'volumeNumber': 1,
        },
      ]),
      queryParameters: {'readingListId': '1'},
    );
    final api = _api(dio);
    final lists = await api.listReadLists();
    expect(lists.content.single.name, 'My List');
    final books = await api.readListBooks('1');
    expect(books.content.single.id, '31');
  });
}
