import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:mylarium/core/network/dio_client.dart';
import 'package:mylarium/data/komga/auth/api_key_auth.dart';
import 'package:mylarium/data/komga/auth/basic_auth.dart';

void main() {
  test('auth interceptor injects the API key on outgoing requests', () async {
    final dio = buildKomgaDio(
      baseUrl: 'https://komga.test',
      auth: const ApiKeyAuth('sek'),
      log: (_) {},
    );
    final adapter = DioAdapter(dio: dio);
    adapter.onGet('/api/v2/users/me', (s) => s.reply(200, {'roles': []}));

    final res = await dio.get<Object?>('/api/v2/users/me');

    expect(res.requestOptions.headers['X-API-Key'], 'sek');
  });

  group('redaction', () {
    test('redactHeaders masks X-API-Key and Authorization (case-insensitive)',
        () {
      final out = RedactingLogInterceptor.redactHeaders({
        'X-API-Key': 'sek',
        'authorization': 'Basic abc',
        'Accept': 'application/json',
      });
      expect(out['X-API-Key'], '***');
      expect(out['authorization'], '***');
      expect(out['Accept'], 'application/json');
    });

    test('redactBody masks the password field', () {
      final out = RedactingLogInterceptor.redactBody(
          {'username': 'alice', 'password': 'p'}) as Map;
      expect(out['password'], '***');
      expect(out['username'], 'alice');
    });

    test('no log line ever contains the secret', () async {
      final logs = <String>[];
      final dio = buildKomgaDio(
        baseUrl: 'https://komga.test',
        auth: const BasicAuth('alice', 'topsecret'),
        log: logs.add,
      );
      final adapter = DioAdapter(dio: dio);
      adapter.onGet(
        '/api/v1/series',
        (s) => s.reply(
            200, {'content': [], 'totalElements': 0, 'number': 0, 'last': true}),
      );

      await dio.get<Object?>('/api/v1/series');

      final joined = logs.join('\n');
      expect(joined, contains('***'));
      expect(joined, isNot(contains('topsecret')));
      // The base64 of the credential must not leak either.
      final b64 = base64Encode(utf8.encode('alice:topsecret'));
      expect(joined.contains(b64), isFalse);
    });
  });
}
