import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:mylarium/data/komga/komga_api.dart';

/// T3 write/referential endpoints. Each asserts the client hits the path and
/// body confirmed against the Komga OpenAPI spec.
void main() {
  late Dio dio;
  late DioAdapter adapter;
  late KomgaApi api;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://komga.test'));
    adapter = DioAdapter(dio: dio);
    api = KomgaApi(dio);
  });

  test('deleteReadProgress DELETEs the book read-progress', () async {
    adapter.onDelete('/api/v1/books/b1/read-progress', (s) => s.reply(204, null));
    await api.deleteReadProgress('b1');
  });

  test('markSeriesRead POSTs the series read-progress (no body)', () async {
    adapter.onPost('/api/v1/series/s1/read-progress', (s) => s.reply(204, null));
    await api.markSeriesRead('s1');
  });

  test('markSeriesUnread DELETEs the series read-progress', () async {
    adapter.onDelete('/api/v1/series/s1/read-progress', (s) => s.reply(204, null));
    await api.markSeriesUnread('s1');
  });

  test('createCollection POSTs name/ordered/seriesIds and parses the result',
      () async {
    adapter.onPost(
      '/api/v1/collections',
      (s) => s.reply(200, {
        'id': 'c1',
        'name': 'Faves',
        'seriesIds': ['s1', 's2'],
      }),
      data: {
        'name': 'Faves',
        'ordered': false,
        'seriesIds': ['s1', 's2'],
      },
    );

    final dto = await api.createCollection(name: 'Faves', seriesIds: ['s1', 's2']);
    expect(dto.id, 'c1');
    expect(dto.seriesIds, ['s1', 's2']);
  });

  test('updateCollection PATCHes the full object', () async {
    adapter.onPatch(
      '/api/v1/collections/c1',
      (s) => s.reply(204, null),
      data: {
        'name': 'Faves',
        'ordered': false,
        'seriesIds': ['s1'],
      },
    );

    await api.updateCollection('c1',
        name: 'Faves', ordered: false, seriesIds: ['s1']);
  });

  test('createReadList POSTs name/ordered/summary/bookIds', () async {
    adapter.onPost(
      '/api/v1/readlists',
      (s) => s.reply(200, {
        'id': 'r1',
        'name': 'Pull',
        'bookIds': ['b1'],
      }),
      data: {
        'name': 'Pull',
        'ordered': false,
        'summary': '',
        'bookIds': ['b1'],
      },
    );

    final dto = await api.createReadList(name: 'Pull', bookIds: ['b1']);
    expect(dto.id, 'r1');
    expect(dto.bookIds, ['b1']);
  });

  test('updateReadList PATCHes name/ordered/bookIds', () async {
    adapter.onPatch(
      '/api/v1/readlists/r1',
      (s) => s.reply(204, null),
      data: {
        'name': 'Pull',
        'ordered': false,
        'bookIds': ['b1', 'b2'],
      },
    );

    await api.updateReadList('r1',
        name: 'Pull', ordered: false, bookIds: ['b1', 'b2']);
  });

  test('listGenres parses a plain string array', () async {
    adapter.onGet('/api/v1/genres', (s) => s.reply(200, ['Action', 'Comedy']));
    expect(await api.listGenres(), ['Action', 'Comedy']);
  });

  test('listAgeRatings parses the string array to ints, dropping junk',
      () async {
    adapter.onGet(
      '/api/v1/age-ratings',
      (s) => s.reply(200, ['0', '12', '18', 'all']),
    );
    expect(await api.listAgeRatings(), [0, 12, 18]);
  });
}
