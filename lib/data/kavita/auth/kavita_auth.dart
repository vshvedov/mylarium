import 'dart:convert';

import 'package:dio/dio.dart';

/// Kavita third-party auth. Kavita does not accept the API key directly on
/// resource calls: a client exchanges the key for a short-lived JWT via
/// `POST /api/Plugin/authenticate`, then sends `Authorization: Bearer <jwt>`.
/// The JWT expires, so this caches it and re-handshakes once on a 401.
///
/// Roles live in the JWT `role` claim, not the authenticate response body
/// (which returns an empty `roles` array for plugin auth).
class KavitaAuth {
  KavitaAuth({
    required this.baseUrl,
    required this.apiKey,
    Dio? handshakeDio,
  }) : _handshake = handshakeDio ??
            Dio(BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 30),
            ));

  final String baseUrl;
  final String apiKey;
  final Dio _handshake;

  String? _token;
  // Single-flight: concurrent callers (e.g. several requests that all 401 at
  // once) share one in-flight handshake instead of stampeding the endpoint.
  Future<String>? _inFlight;

  /// A valid bearer token, performing the handshake if none is cached.
  Future<String> token() =>
      _token != null ? Future<String>.value(_token!) : _refresh();

  /// Forces a fresh handshake (used after a 401). Coalesces concurrent callers.
  Future<String> refresh() {
    _token = null;
    return _refresh();
  }

  Future<String> _refresh() =>
      _inFlight ??= _authenticate().whenComplete(() => _inFlight = null);

  Future<String> _authenticate() async {
    final res = await _handshake.post<Object?>(
      '/api/Plugin/authenticate',
      queryParameters: {'apiKey': apiKey, 'pluginName': 'Mylarium'},
    );
    final data = res.data;
    final token = data is Map ? data['token'] as String? : null;
    if (token == null || token.isEmpty) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: Response(
          requestOptions: res.requestOptions,
          statusCode: 401,
        ),
        type: DioExceptionType.badResponse,
        error: 'Kavita authentication returned no token.',
      );
    }
    _token = token;
    return token;
  }

  /// Decodes the roles from a Kavita JWT `role` claim. Returns an empty set when
  /// the token is malformed.
  static Set<String> rolesFromJwt(String token) {
    final parts = token.split('.');
    if (parts.length < 2) return const {};
    var payload = parts[1].replaceAll('-', '+').replaceAll('_', '/');
    payload = payload.padRight(payload.length + (4 - payload.length % 4) % 4, '=');
    try {
      final decoded = jsonDecode(utf8.decode(base64.decode(payload)));
      if (decoded is Map) {
        final role = decoded['role'];
        if (role is List) return role.whereType<String>().toSet();
        if (role is String) return {role};
      }
    } catch (_) {
      // Malformed token: no roles.
    }
    return const {};
  }
}

/// Injects the bearer token onto every request and, on a 401, performs a single
/// re-handshake and replays the original request. Queued so the token refresh is
/// serialized across concurrent requests.
class KavitaAuthInterceptor extends QueuedInterceptor {
  KavitaAuthInterceptor(this._auth, this._dio);

  final KavitaAuth _auth;
  final Dio _dio;

  static const _retriedFlag = 'kavitaRetried';

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      options.headers['Authorization'] = 'Bearer ${await _auth.token()}';
    } catch (_) {
      // Let the request proceed; it will 401 and surface a clean error.
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final is401 = err.response?.statusCode == 401;
    final alreadyRetried = err.requestOptions.extra[_retriedFlag] == true;
    if (is401 && !alreadyRetried) {
      try {
        final token = await _auth.refresh();
        final opts = err.requestOptions;
        opts.extra[_retriedFlag] = true;
        opts.headers['Authorization'] = 'Bearer $token';
        final response = await _dio.fetch<Object?>(opts);
        return handler.resolve(response);
      } catch (_) {
        // Re-auth failed: fall through to the original error.
      }
    }
    handler.next(err);
  }
}
