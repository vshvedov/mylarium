import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:mylarium/app/theme/theme_controller.dart';
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/core/storage/secure_store.dart';
import 'package:mylarium/data/kavita/auth/kavita_auth.dart';
import 'package:mylarium/data/kavita/kavita_api.dart';
import 'package:mylarium/data/kavita/kavita_providers.dart';
import 'package:mylarium/data/komga/komga_providers.dart';
import 'package:mylarium/data/source/source_providers.dart';
import 'package:mylarium/features/onboarding/connection_result.dart';
import 'package:mylarium/features/onboarding/kavita_connect_controller.dart';

class _InMemorySecureStore extends SecureStore {
  final Map<String, String> values = {};
  @override
  Future<void> write(String key, String value) async => values[key] = value;
  @override
  Future<String?> read(String key) async => values[key];
  @override
  Future<void> delete(String key) async => values.remove(key);
}

String _jwt(List<String> roles) {
  String seg(Map<String, Object?> m) =>
      base64Url.encode(utf8.encode(jsonEncode(m))).replaceAll('=', '');
  return '${seg({'alg': 'HS512'})}.${seg({'role': roles})}.sig';
}

/// A KavitaApi whose handshake returns a token with [roles], or a 401 when
/// [unauthorized].
KavitaApi _fakeApi({List<String> roles = const ['Login'], bool unauthorized = false}) {
  final handshake = Dio(BaseOptions(baseUrl: 'https://kavita.test'));
  final hAdapter = DioAdapter(dio: handshake);
  hAdapter.onPost(
    '/api/Plugin/authenticate',
    (s) => unauthorized ? s.reply(401, '') : s.reply(200, {'token': _jwt(roles)}),
    queryParameters: {'apiKey': 'k', 'pluginName': 'Mylarium'},
  );
  final resource = Dio(BaseOptions(baseUrl: 'https://kavita.test'));
  DioAdapter(dio: resource).onGet('/api/Server/server-info-slim',
      (s) => s.reply(200, {'kavitaVersion': '0.9.0.2'}));
  final auth = KavitaAuth(
    baseUrl: 'https://kavita.test',
    apiKey: 'k',
    handshakeDio: handshake,
  );
  return KavitaApi(resource, auth, 'k');
}

ProviderContainer _container(AppDatabase db, SecureStore store, KavitaApi api) {
  return ProviderContainer(overrides: [
    appDatabaseProvider.overrideWithValue(db),
    secureStoreProvider.overrideWithValue(store),
    kavitaApiFactoryProvider.overrideWithValue(
      ({required String baseUrl, required String apiKey}) => api,
    ),
  ]);
}

void main() {
  test('connect persists a kavita source on success', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final store = _InMemorySecureStore();
    final container = _container(db, store, _fakeApi());
    addTearDown(container.dispose);
    // Keep the autoDispose controller alive across the await.
    container.listen(kavitaConnectControllerProvider, (_, _) {});

    await container
        .read(kavitaConnectControllerProvider.notifier)
        .connect(url: 'kavita.test', apiKey: 'k');

    final result =
        container.read(kavitaConnectControllerProvider).valueOrNull;
    expect(result, isA<ConnSuccess>());
    final sources = await db.allSources();
    expect(sources, hasLength(1));
    expect(sources.single.kind, 'kavita');
    expect(store.values.keys.single, startsWith('kavita.cred.'));
  });

  test('a successful connection becomes the active source without a restart',
      () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = _container(db, _InMemorySecureStore(), _fakeApi());
    addTearDown(container.dispose);
    container.listen(kavitaConnectControllerProvider, (_, _) {});

    // Mirror the running app: the active source is read (and cached null) before
    // onboarding completes.
    expect(await container.read(activeSourceIdProvider.future), isNull);

    await container
        .read(kavitaConnectControllerProvider.notifier)
        .connect(url: 'kavita.test', apiKey: 'k');

    final result = container.read(kavitaConnectControllerProvider).valueOrNull;
    expect(result, isA<ConnSuccess>());
    final sourceId = (result! as ConnSuccess).sourceId;
    expect(container.read(activeSourceIdProvider).valueOrNull, sourceId);
  });

  test('connect reports missing role when the JWT lacks Login', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = _container(db, _InMemorySecureStore(), _fakeApi(roles: const []));
    addTearDown(container.dispose);
    // Keep the autoDispose controller alive across the await.
    container.listen(kavitaConnectControllerProvider, (_, _) {});

    await container
        .read(kavitaConnectControllerProvider.notifier)
        .connect(url: 'kavita.test', apiKey: 'k');

    expect(container.read(kavitaConnectControllerProvider).valueOrNull,
        isA<ConnMissingRoles>());
    expect(await db.allSources(), isEmpty);
  });

  test('connect reports unauthorized when the API key is rejected', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container =
        _container(db, _InMemorySecureStore(), _fakeApi(unauthorized: true));
    addTearDown(container.dispose);
    // Keep the autoDispose controller alive across the await.
    container.listen(kavitaConnectControllerProvider, (_, _) {});

    await container
        .read(kavitaConnectControllerProvider.notifier)
        .connect(url: 'kavita.test', apiKey: 'k');

    expect(container.read(kavitaConnectControllerProvider).valueOrNull,
        isA<ConnUnauthorized>());
    expect(await db.allSources(), isEmpty);
  });
}
