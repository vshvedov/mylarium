import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../data/komga/auth/komga_auth.dart';

const _redactedHeaderKeys = {'x-api-key', 'authorization'};
const _redactedQueryKeys = {'x-api-key'};
const _redactedBodyKeys = {'password'};
const _redactionMask = '***';

/// Builds a Dio configured for a Komga server. [baseUrl] is the server origin
/// (no `/api/v1`); call sites append the versioned path. Interceptors, in order:
/// auth injection, redacting logger, error -> [DioException] (callers convert to
/// `ContentException`).
Dio buildKomgaDio({
  required String baseUrl,
  required KomgaAuth auth,
  void Function(String)? log,
}) {
  final dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    followRedirects: true,
    maxRedirects: 5,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
    // Spring accepts repeated `sort` params; emit repeated keys, never joined.
    listFormat: ListFormat.multiCompatible,
  ));
  dio.interceptors.add(_AuthInterceptor(auth));
  // Request logging is debug-only: debugPrint is not stripped in release, so
  // default to a no-op there even though secrets are already redacted.
  dio.interceptors
      .add(RedactingLogInterceptor(log: log ?? (kDebugMode ? _debugLog : _noLog)));
  return dio;
}

void _debugLog(String line) => debugPrint(line);
void _noLog(String _) {}

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._auth);

  final KomgaAuth _auth;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _auth.apply(options);
    handler.next(options);
  }
}

/// Logs a compact request/response/error line with all secrets masked. The
/// secret never appears in any log channel (CLAUDE.md: secrets never logged).
class RedactingLogInterceptor extends Interceptor {
  RedactingLogInterceptor({required this.log});

  final void Function(String) log;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    log('-> ${options.method} ${_redactUri(options.uri)} '
        'headers=${redactHeaders(options.headers)} '
        'body=${redactBody(options.data)}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    log('<- ${response.statusCode} ${_redactUri(response.requestOptions.uri)}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    log('xx ${err.type} ${err.response?.statusCode ?? ''} '
        '${_redactUri(err.requestOptions.uri)}');
    handler.next(err);
  }

  /// Masks redacted header values (case-insensitive on the key).
  static Map<String, Object?> redactHeaders(Map<String, Object?> headers) {
    return headers.map((key, value) =>
        MapEntry(key, _redactedHeaderKeys.contains(key.toLowerCase())
            ? _redactionMask
            : value));
  }

  /// Masks redacted body fields when the body is a JSON map.
  static Object? redactBody(Object? body) {
    if (body is Map) {
      return body.map((key, value) =>
          MapEntry(key, _redactedBodyKeys.contains('$key'.toLowerCase())
              ? _redactionMask
              : value));
    }
    return body;
  }

  static String _redactUri(Uri uri) {
    // Never log credentials embedded in the authority (user:pass@host).
    if (uri.userInfo.isNotEmpty) {
      uri = uri.replace(userInfo: '');
    }
    if (uri.queryParameters.keys
        .any((k) => _redactedQueryKeys.contains(k.toLowerCase()))) {
      final masked = {
        for (final e in uri.queryParameters.entries)
          e.key: _redactedQueryKeys.contains(e.key.toLowerCase())
              ? _redactionMask
              : e.value,
      };
      return uri.replace(queryParameters: masked).toString();
    }
    return uri.toString();
  }
}
