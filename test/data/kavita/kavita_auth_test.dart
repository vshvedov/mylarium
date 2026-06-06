import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:mylarium/data/kavita/auth/kavita_auth.dart';

/// Builds a JWT-shaped token (header.payload.sig) carrying [roles] in the
/// `role` claim. Only the payload segment matters to [KavitaAuth.rolesFromJwt].
String _jwt(List<String> roles) {
  String seg(Map<String, Object?> m) =>
      base64Url.encode(utf8.encode(jsonEncode(m))).replaceAll('=', '');
  return '${seg({'alg': 'HS512'})}.${seg({'role': roles})}.sig';
}

/// Returns 401 on the first call, 200 thereafter - to exercise the
/// re-handshake-and-retry path.
class _SequenceAdapter implements HttpClientAdapter {
  int calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    if (calls == 1) {
      return ResponseBody.fromString('', 401);
    }
    return ResponseBody.fromString('OK', 200, headers: {
      Headers.contentTypeHeader: ['text/plain'],
    });
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('rolesFromJwt', () {
    test('decodes the role claim', () {
      expect(KavitaAuth.rolesFromJwt(_jwt(['Admin', 'Login'])),
          {'Admin', 'Login'});
    });

    test('returns empty for a malformed token', () {
      expect(KavitaAuth.rolesFromJwt('not-a-jwt'), isEmpty);
    });
  });

  test('token() handshakes once and caches', () async {
    final handshake = Dio(BaseOptions(baseUrl: 'https://kavita.test'));
    final hAdapter = DioAdapter(dio: handshake);
    hAdapter.onPost(
      '/api/Plugin/authenticate',
      (s) => s.reply(200, {'token': _jwt(['Login'])}),
      queryParameters: {'apiKey': 'k', 'pluginName': 'Mylarium'},
    );
    final auth = KavitaAuth(
      baseUrl: 'https://kavita.test',
      apiKey: 'k',
      handshakeDio: handshake,
    );

    final t1 = await auth.token();
    final t2 = await auth.token();
    expect(t1, isNotEmpty);
    expect(identical(t1, t2) || t1 == t2, isTrue);
    expect(KavitaAuth.rolesFromJwt(t1), {'Login'});
  });

  test('interceptor re-handshakes and retries on a 401', () async {
    final handshake = Dio(BaseOptions(baseUrl: 'https://kavita.test'));
    final hAdapter = DioAdapter(dio: handshake);
    hAdapter.onPost(
      '/api/Plugin/authenticate',
      (s) => s.reply(200, {'token': _jwt(['Login'])}),
      queryParameters: {'apiKey': 'k', 'pluginName': 'Mylarium'},
    );
    final auth = KavitaAuth(
      baseUrl: 'https://kavita.test',
      apiKey: 'k',
      handshakeDio: handshake,
    );

    final resource = Dio(BaseOptions(baseUrl: 'https://kavita.test'));
    final seq = _SequenceAdapter();
    resource.httpClientAdapter = seq;
    resource.interceptors.add(KavitaAuthInterceptor(auth, resource));

    final res = await resource.get<Object?>('/api/Series/all-v2');
    expect(res.statusCode, 200);
    // 1st call 401, retry is the 2nd.
    expect(seq.calls, 2);
  });
}
