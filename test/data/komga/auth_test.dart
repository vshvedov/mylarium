import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/data/komga/auth/api_key_auth.dart';
import 'package:mylarium/data/komga/auth/basic_auth.dart';

void main() {
  test('ApiKeyAuth injects the X-API-Key header', () {
    final options = RequestOptions(path: '/api/v2/users/me');
    const ApiKeyAuth('secret-key-123').apply(options);
    expect(options.headers['X-API-Key'], 'secret-key-123');
  });

  test('ApiKeyAuth.toString never reveals the key', () {
    expect(const ApiKeyAuth('secret-key-123').toString(),
        isNot(contains('secret-key-123')));
  });

  test('BasicAuth injects Authorization: Basic base64(user:pass)', () {
    final options = RequestOptions(path: '/api/v2/users/me');
    const BasicAuth('alice', 'hunter2').apply(options);
    final expected = 'Basic ${base64Encode(utf8.encode('alice:hunter2'))}';
    expect(options.headers['Authorization'], expected);
  });

  test('BasicAuth.toString never reveals the credential', () {
    final s = const BasicAuth('alice', 'hunter2').toString();
    expect(s, isNot(contains('hunter2')));
    expect(s, isNot(contains('alice')));
  });
}
