import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/network/dio_client.dart';
import '../komga/komga_providers.dart' show secureStoreProvider;
import 'auth/kavita_auth.dart';
import 'auth/kavita_credential.dart';
import 'kavita_api.dart';

part 'kavita_providers.g.dart';

/// Kavita credential store layered over the shared secure store.
@Riverpod(keepAlive: true)
KavitaCredentialStore kavitaCredentialStore(Ref ref) =>
    KavitaCredentialStore(ref.watch(secureStoreProvider));

/// Builds a Dio for a Kavita server. [baseUrl] is the server origin (no
/// `/api`). The auth interceptor injects a bearer JWT and re-handshakes once on
/// a 401; the redacting logger keeps secrets out of logs.
Dio buildKavitaDio({
  required String baseUrl,
  required KavitaAuth auth,
  void Function(String)? log,
}) {
  final dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    followRedirects: true,
    maxRedirects: 5,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
    listFormat: ListFormat.multiCompatible,
  ));
  dio.interceptors.add(KavitaAuthInterceptor(auth, dio));
  dio.interceptors.add(
      RedactingLogInterceptor(log: log ?? (kDebugMode ? _debugLog : _noLog)));
  return dio;
}

void _debugLog(String line) => debugPrint(line);
void _noLog(String _) {}

/// Builds a [KavitaApi] for a given server. A provider so tests can inject a
/// client backed by a mock HTTP adapter.
typedef KavitaApiFactory = KavitaApi Function({
  required String baseUrl,
  required String apiKey,
});

@riverpod
KavitaApiFactory kavitaApiFactory(Ref ref) =>
    ({required String baseUrl, required String apiKey}) {
      final auth = KavitaAuth(baseUrl: baseUrl, apiKey: apiKey);
      final dio = buildKavitaDio(baseUrl: baseUrl, auth: auth);
      return KavitaApi(dio, auth, apiKey);
    };
