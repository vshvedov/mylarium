import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:mylarium/core/network/content_exception.dart';
import 'package:mylarium/data/komga/komga_api.dart';
import 'package:mylarium/features/onboarding/connection_result.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late KomgaApi api;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://komga.test'));
    adapter = DioAdapter(dio: dio);
    api = KomgaApi(dio);
  });

  final usersMe = jsonDecode(
    File('test/data/komga/fixtures/users_me.json').readAsStringSync(),
  ) as Map<String, dynamic>;

  void mockVersion(String v) => adapter.onGet(
        '/api/v1/actuator/info',
        (s) => s.reply(200, {
          'build': {'version': v}
        }),
      );

  test('validate parses version and roles from a real users/me payload',
      () async {
    mockVersion('1.21.0');
    adapter.onGet('/api/v2/users/me', (s) => s.reply(200, usersMe));

    final info = await api.validate();

    expect(info.version, '1.21.0');
    expect(info.roles, containsAll(requiredKomgaRoles));
    expect(requiredKomgaRoles.difference(info.roles), isEmpty);
  });

  test('a missing FILE_DOWNLOAD role is detectable and named', () async {
    mockVersion('1.21.0');
    adapter.onGet('/api/v2/users/me', (s) => s.reply(200, {
          'roles': ['PAGE_STREAMING']
        }));

    final info = await api.validate();

    expect(requiredKomgaRoles.difference(info.roles), {'FILE_DOWNLOAD'});
  });

  test('401 surfaces as an unauthorized ContentException', () async {
    mockVersion('1.21.0');
    adapter.onGet('/api/v2/users/me', (s) => s.reply(401, {'error': 'no'}));

    await expectLater(
      api.validate(),
      throwsA(isA<ContentException>()
          .having((e) => e.kind, 'kind', ContentErrorKind.unauthorized)),
    );
  });

  test('version is null when the actuator endpoint is unavailable', () async {
    adapter.onGet('/api/v1/actuator/info', (s) => s.reply(404, {}));
    adapter.onGet('/api/v2/users/me', (s) => s.reply(200, usersMe));

    final info = await api.validate();

    expect(info.version, isNull);
    expect(info.roles, containsAll(requiredKomgaRoles));
  });

  group('versionSupportsApiKeys', () {
    test('1.20.0 and newer support API keys', () {
      expect(versionSupportsApiKeys('1.20.0'), isTrue);
      expect(versionSupportsApiKeys('1.21.3'), isTrue);
      expect(versionSupportsApiKeys('2.0.0'), isTrue);
    });

    test('older than 1.20.0 does not', () {
      expect(versionSupportsApiKeys('1.19.9'), isFalse);
      expect(versionSupportsApiKeys('1.0.0'), isFalse);
    });

    test('null or unparseable never blocks (auth is authoritative)', () {
      expect(versionSupportsApiKeys(null), isTrue);
      expect(versionSupportsApiKeys('unstable'), isTrue);
    });

    test('qualifier and build suffixes are ignored', () {
      expect(versionSupportsApiKeys('1.21.0-SNAPSHOT'), isTrue);
      expect(versionSupportsApiKeys('1.19.0+build7'), isFalse);
    });
  });
}
