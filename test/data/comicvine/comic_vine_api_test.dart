import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:mylarium/data/comicvine/comic_vine_api.dart';

void main() {
  late List<String> logs;
  late ComicVineApi api;
  late DioAdapter adapter;

  setUp(() {
    logs = [];
    final dio = buildComicVineDio('SECRET', log: logs.add);
    adapter = DioAdapter(dio: dio);
    api = ComicVineApi(dio);
  });

  test('searchVolumes sends api_key/format and parses results', () async {
    adapter.onGet(
      'search/',
      (s) => s.reply(200, {
        'status_code': 1,
        'error': 'OK',
        'results': [
          {
            'id': 4050,
            'name': 'Saga',
            'count_of_issues': 60,
            'publisher': {'name': 'Image'},
          },
        ],
      }),
      queryParameters: {
        'api_key': 'SECRET',
        'format': 'json',
        'query': 'Saga',
        'resources': 'volume',
        'field_list': 'id,name,start_year,count_of_issues,publisher,deck',
        'limit': '10',
      },
    );

    final results = await api.searchVolumes('Saga');
    expect(results.single.name, 'Saga');
    expect(results.single.publisherName, 'Image');
  });

  test('a non-OK status_code throws ComicVineApiError', () async {
    adapter.onGet(
      'search/',
      (s) => s.reply(200, {
        'status_code': 107,
        'error': 'Rate limit exceeded',
        'results': [],
      }),
      queryParameters: {
        'api_key': 'SECRET',
        'format': 'json',
        'query': 'X',
        'resources': 'volume',
        'field_list': 'id,name,start_year,count_of_issues,publisher,deck',
        'limit': '10',
      },
    );

    await expectLater(
      api.searchVolumes('X'),
      throwsA(
        isA<ComicVineApiError>()
            .having((e) => e.code, 'code', 107)
            .having((e) => e.isRateLimited, 'isRateLimited', true),
      ),
    );
  });

  test('the User-Agent header is set and the api_key is never logged', () async {
    final dio = buildComicVineDio('SECRET', log: logs.add);
    expect(dio.options.headers['User-Agent'], kComicVineUserAgent);

    adapter = DioAdapter(dio: dio);
    api = ComicVineApi(dio);
    adapter.onGet(
      'search/',
      (s) => s.reply(200, {'status_code': 1, 'error': 'OK', 'results': []}),
      queryParameters: {
        'api_key': 'SECRET',
        'format': 'json',
        'query': 'Saga',
        'resources': 'volume',
        'field_list': 'id,name,start_year,count_of_issues,publisher,deck',
        'limit': '10',
      },
    );
    await api.searchVolumes('Saga');

    expect(logs, isNotEmpty);
    expect(logs.every((l) => !l.contains('SECRET')), isTrue);
    expect(logs.any((l) => l.contains('***')), isTrue);
  });
}
