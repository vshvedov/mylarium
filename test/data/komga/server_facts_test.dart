import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:mylarium/core/network/content_exception.dart';
import 'package:mylarium/data/komga/komga_api.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late KomgaApi api;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://komga.test'));
    adapter = DioAdapter(dio: dio);
    api = KomgaApi(dio);
  });

  // listLibraries is the authoritative online probe; the rest are best-effort.
  void mockLibraries() => adapter.onGet(
        '/api/v1/libraries',
        (s) => s.reply(200, [
          {'id': 'l1', 'name': 'Manga'},
          {'id': 'l2', 'name': 'Comics'},
        ]),
      );

  test('gathers version, account, roles, libraries, counts and disk', () async {
    mockLibraries();
    adapter.onGet('/api/v1/actuator/info',
        (s) => s.reply(200, {'build': {'version': '1.21.0'}}));
    adapter.onGet('/api/v2/users/me', (s) => s.reply(200, {
          'email': 'test@test.local',
          'roles': ['ADMIN', 'PAGE_STREAMING'],
          'sharedAllLibraries': true,
        }));
    adapter.onGet('/api/v1/actuator/health', (s) => s.reply(200, {
          'status': 'UP',
          'components': {
            'diskSpace': {
              'status': 'UP',
              'details': {'total': 1073741824000, 'free': 536870912000},
            }
          }
        }));
    // page totals (size:1) for the counts.
    adapter.onGet('/api/v1/series',
        (s) => s.reply(200, {'content': [], 'totalElements': 1204, 'last': true}),
        queryParameters: {'page': 0, 'size': 1});
    adapter.onGet('/api/v1/books',
        (s) => s.reply(200, {'content': [], 'totalElements': 18732, 'last': true}),
        queryParameters: {'page': 0, 'size': 1});

    final facts = await api.fetchServerFacts();

    expect(facts.version, '1.21.0');
    expect(facts.account, 'test@test.local');
    expect(facts.roles, containsAll(['ADMIN', 'PAGE_STREAMING']));
    expect(facts.libraryNames, ['Manga', 'Comics']);
    expect(facts.totalSeries, 1204);
    expect(facts.totalBooks, 18732);
    expect(facts.extra.map((r) => r.label), contains('Health'));
    expect(facts.extra.firstWhere((r) => r.label == 'Disk').value,
        contains('GB'));
    expect(facts.extra.firstWhere((r) => r.label == 'Library access').value,
        'All libraries');
  });

  test('omits pieces whose endpoints fail, still returns libraries', () async {
    mockLibraries();
    adapter.onGet('/api/v1/actuator/info', (s) => s.reply(404, {}));
    adapter.onGet('/api/v2/users/me', (s) => s.reply(403, {}));
    adapter.onGet('/api/v1/actuator/health', (s) => s.reply(404, {}));
    adapter.onGet('/api/v1/series',
        (s) => s.reply(500, {}), queryParameters: {'page': 0, 'size': 1});
    adapter.onGet('/api/v1/books',
        (s) => s.reply(500, {}), queryParameters: {'page': 0, 'size': 1});

    final facts = await api.fetchServerFacts();

    expect(facts.version, isNull);
    expect(facts.account, isNull);
    expect(facts.roles, isEmpty);
    expect(facts.totalSeries, isNull);
    expect(facts.totalBooks, isNull);
    expect(facts.libraryNames, ['Manga', 'Comics']);
  });

  test('throws ContentException when the server is unreachable (libraries 503)',
      () async {
    adapter.onGet('/api/v1/libraries', (s) => s.reply(503, {}));
    await expectLater(api.fetchServerFacts(), throwsA(isA<ContentException>()));
  });
}
