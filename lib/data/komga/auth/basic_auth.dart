import 'dart:convert';

import 'package:dio/dio.dart';

import 'komga_auth.dart';

/// HTTP Basic auth (the username/password path, and the fallback for servers
/// older than 1.20.0 that predate API keys). Applied statelessly per request.
class BasicAuth implements KomgaAuth {
  const BasicAuth(this.username, this.password);

  final String username;
  final String password;

  @override
  void apply(RequestOptions options) {
    options.headers['Authorization'] = headers()['Authorization'];
  }

  @override
  Map<String, String> headers() {
    final token = base64Encode(utf8.encode('$username:$password'));
    return {'Authorization': 'Basic $token'};
  }

  /// Never reveals the credential (CLAUDE.md: secrets never logged).
  @override
  String toString() => 'BasicAuth(***)';
}
