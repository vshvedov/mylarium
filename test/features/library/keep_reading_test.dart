import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:mylarium/data/komga/komga_api.dart';
import 'package:mylarium/data/source/source_providers.dart';
import 'package:mylarium/features/library/library_browse_controllers.dart';

Map<String, Object?> _page(List<String> ids) => {
      'content': [
        for (final id in ids)
          {
            'id': id,
            'seriesId': 'ser1',
            'libraryId': 'lib',
            'name': id,
            'metadata': {'title': id, 'number': '1'},
            'media': {'pagesCount': 20},
          },
      ],
      'totalElements': ids.length,
      'number': 0,
      'last': true,
    };

void main() {
  test('keepReading lists in-progress first, then on-deck, de-duplicated',
      () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://komga.test'));
    final adapter = DioAdapter(dio: dio);
    final api = KomgaApi(dio);

    // In-progress books (POST /books/list with the readStatus condition).
    adapter.onPost(
      '/api/v1/books/list',
      (s) => s.reply(200, _page(['b1', 'b2'])),
      data: {
        'condition': {
          'allOf': [
            {
              'anyOf': [
                {
                  'readStatus': {'operator': 'is', 'value': 'IN_PROGRESS'}
                }
              ]
            }
          ]
        }
      },
      queryParameters: {'page': 0, 'size': 20, 'sort': 'readDate,desc'},
    );
    // On-deck: b2 is a duplicate, b3 is new.
    adapter.onGet(
      '/api/v1/books/ondeck',
      (s) => s.reply(200, _page(['b2', 'b3'])),
      queryParameters: {'page': 0, 'size': 20},
    );

    final c = ProviderContainer(overrides: [
      activeKomgaApiProvider.overrideWith((ref) async => api),
    ]);
    addTearDown(c.dispose);

    final result = await c.read(keepReadingProvider.future);
    expect(result.map((b) => b.id), ['b1', 'b2', 'b3'],
        reason: 'in-progress first, on-deck appended, b2 de-duplicated');
  });

  test('keepReading degrades to empty on a Komga error', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://komga.test'));
    final adapter = DioAdapter(dio: dio);
    final api = KomgaApi(dio);
    adapter.onPost(
      '/api/v1/books/list',
      (s) => s.reply(500, {'error': 'boom'}),
      data: {
        'condition': {
          'allOf': [
            {
              'anyOf': [
                {
                  'readStatus': {'operator': 'is', 'value': 'IN_PROGRESS'}
                }
              ]
            }
          ]
        }
      },
      queryParameters: {'page': 0, 'size': 20, 'sort': 'readDate,desc'},
    );

    final c = ProviderContainer(overrides: [
      activeKomgaApiProvider.overrideWith((ref) async => api),
    ]);
    addTearDown(c.dispose);

    expect(await c.read(keepReadingProvider.future), isEmpty);
  });
}
