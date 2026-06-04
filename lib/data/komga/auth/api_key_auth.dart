import 'package:dio/dio.dart';

import 'komga_auth.dart';

/// Komga API key auth (server >= 1.20.0). Sends the `X-API-Key` header.
class ApiKeyAuth implements KomgaAuth {
  const ApiKeyAuth(this.key);

  final String key;

  @override
  void apply(RequestOptions options) => options.headers['X-API-Key'] = key;

  @override
  Map<String, String> headers() => {'X-API-Key': key};

  /// Never reveals the key (CLAUDE.md: secrets never logged).
  @override
  String toString() => 'ApiKeyAuth(***)';
}
