import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/network/dio_client.dart';
import '../../core/storage/secure_store.dart';
import 'auth/komga_auth.dart';
import 'auth/komga_credential.dart';
import 'komga_api.dart';

part 'komga_providers.g.dart';

/// Platform secret store. Overridable in tests with a fake.
@Riverpod(keepAlive: true)
SecureStore secureStore(Ref ref) => SecureStore();

/// Komga credential store layered over [secureStore].
@Riverpod(keepAlive: true)
KomgaCredentialStore komgaCredentialStore(Ref ref) =>
    KomgaCredentialStore(ref.watch(secureStoreProvider));

/// Builds a [KomgaApi] for a given server. A provider so tests can inject a
/// client backed by a mock HTTP adapter.
typedef KomgaApiFactory = KomgaApi Function({
  required String baseUrl,
  required KomgaAuth auth,
});

@riverpod
KomgaApiFactory komgaApiFactory(Ref ref) =>
    ({required String baseUrl, required KomgaAuth auth}) =>
        KomgaApi(buildKomgaDio(baseUrl: baseUrl, auth: auth));
