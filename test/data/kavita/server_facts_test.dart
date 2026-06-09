import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:mylarium/core/network/content_exception.dart';
import 'package:mylarium/data/kavita/auth/kavita_auth.dart';
import 'package:mylarium/data/kavita/kavita_api.dart';

void main() {
  // header {"alg":"none"} . payload {"name":"reader","role":["Admin"]} . sig
  const jwt =
      'eyJhbGciOiJub25lIn0.eyJuYW1lIjoicmVhZGVyIiwicm9sZSI6WyJBZG1pbiJdfQ.sig';

  late Dio dio;
  late DioAdapter adapter;
  late KavitaApi api;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://kavita.test'));
    adapter = DioAdapter(dio: dio);
    api = KavitaApi(dio, KavitaAuth.forTest(jwt), 'apikey');
  });

  void mockLibraries() => adapter.onGet(
        '/api/Library/libraries',
        (s) => s.reply(200, [
          {'id': 1, 'name': 'Manga', 'type': 0},
          {'id': 2, 'name': 'Comics', 'type': 1},
        ]),
      );

  test('decodes username + roles from JWT, gathers version, libraries, series',
      () async {
    mockLibraries();
    adapter.onGet('/api/Server/server-info-slim', (s) => s.reply(200, {
          'kavitaVersion': '0.8.2',
          'os': 'linux',
          'dotnetVersion': '9.0.0',
          'isDocker': true,
        }));
    // Kavita series total comes from the Pagination response header.
    // Include content-type so Dio decodes the body as JSON (replacing the
    // default header map requires explicitly re-adding content-type).
    adapter.onPost(
      '/api/Series/all-v2',
      (s) => s.reply(200, [], headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
        'Pagination': [
          '{"currentPage":1,"itemsPerPage":1,"totalItems":42,"totalPages":42}'
        ],
      }),
      queryParameters: {'PageNumber': 1, 'PageSize': 1},
      data: const {},
    );

    final facts = await api.fetchServerFacts();

    expect(facts.account, 'reader');
    expect(facts.roles, contains('Admin'));
    expect(facts.version, '0.8.2');
    expect(facts.libraryNames, ['Manga', 'Comics']);
    expect(facts.totalSeries, 42);
    expect(facts.totalBooks, isNull); // no cheap aggregate for Kavita
    expect(facts.extra.firstWhere((r) => r.label == 'OS').value, 'linux');
    expect(facts.extra.firstWhere((r) => r.label == 'Docker').value, 'Yes');
  });

  test('throws ContentException when libraries is unreachable', () async {
    adapter.onGet('/api/Library/libraries', (s) => s.reply(503, {}));
    await expectLater(api.fetchServerFacts(), throwsA(isA<ContentException>()));
  });
}
