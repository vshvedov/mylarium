import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../app/theme/theme_controller.dart' show appDatabaseProvider;
import '../../core/db/database.dart';
import '../../core/network/content_exception.dart';
import '../../data/komga/auth/api_key_auth.dart';
import '../../data/komga/auth/basic_auth.dart';
import '../../data/komga/auth/komga_auth.dart';
import '../../data/komga/auth/komga_credential.dart';
import '../../data/komga/komga_api.dart';
import '../../data/komga/komga_providers.dart';
import '../../data/source/content_source.dart';
import 'connection_result.dart';

part 'onboarding_controller.g.dart';

/// Normalizes a user-entered server URL into an origin (no `/api/v1`, no
/// trailing slash). Returns null when the input cannot be a valid http(s) URL.
Uri? normalizeServerUrl(String input) {
  var s = input.trim();
  if (s.isEmpty) return null;
  if (!s.contains('://')) s = 'https://$s';
  final Uri uri;
  try {
    uri = Uri.parse(s);
  } catch (_) {
    return null;
  }
  if (uri.host.isEmpty) return null;
  if (uri.scheme != 'http' && uri.scheme != 'https') return null;

  var path = uri.path;
  while (path.endsWith('/')) {
    path = path.substring(0, path.length - 1);
  }
  if (path.toLowerCase().endsWith('/api/v1')) {
    path = path.substring(0, path.length - '/api/v1'.length);
  }
  // Rebuild without query/fragment (avoids trailing `?#` from Uri.replace) and
  // WITHOUT userInfo: an embedded `user:pass@` must never be persisted to the
  // Sources row or reach a log line. Credentials belong in secure storage only.
  return Uri(
    scheme: uri.scheme,
    host: uri.host,
    port: uri.hasPort ? uri.port : null,
    path: path,
  );
}

/// Drives the onboarding screen. State is the latest [ConnectionResult] (null
/// before the first attempt); [AsyncLoading] while a connection is in flight.
@riverpod
class OnboardingController extends _$OnboardingController {
  @override
  AsyncValue<ConnectionResult?> build() => const AsyncData(null);

  Future<void> connect({
    required String url,
    required AuthMethod method,
    String? apiKey,
    String? username,
    String? password,
  }) async {
    state = const AsyncLoading();
    state = AsyncData(await _attempt(
      url: url,
      method: method,
      apiKey: apiKey,
      username: username,
      password: password,
    ));
  }

  Future<ConnectionResult> _attempt({
    required String url,
    required AuthMethod method,
    String? apiKey,
    String? username,
    String? password,
  }) async {
    final uri = normalizeServerUrl(url);
    if (uri == null) return const ConnInvalidUrl();
    final baseUrl = uri.toString();

    final KomgaAuth auth;
    final KomgaCredential credential;
    if (method == AuthMethod.apiKey) {
      final key = apiKey ?? '';
      if (key.isEmpty) return const ConnUnauthorized();
      auth = ApiKeyAuth(key);
      credential = ApiKeyCredential(key);
    } else {
      final user = username ?? '';
      final pass = password ?? '';
      if (user.isEmpty || pass.isEmpty) return const ConnUnauthorized();
      auth = BasicAuth(user, pass);
      credential = BasicCredential(user, pass);
    }

    final api = ref.read(komgaApiFactoryProvider)(baseUrl: baseUrl, auth: auth);

    try {
      // Version gate precedes the auth attempt (clearer message on old servers).
      if (method == AuthMethod.apiKey) {
        final version = await api.fetchVersion();
        if (version != null && !versionSupportsApiKeys(version)) {
          return ConnVersionTooOldForApiKey(version);
        }
      }

      final info = await api.validate();
      final missing = requiredKomgaRoles.difference(info.roles);
      if (missing.isNotEmpty) return ConnMissingRoles(missing);

      return _persist(baseUrl: baseUrl, label: uri.host, credential: credential);
    } on ContentException catch (e) {
      return switch (e.kind) {
        ContentErrorKind.unauthorized => const ConnUnauthorized(),
        ContentErrorKind.forbidden => const ConnUnauthorized(),
        ContentErrorKind.unreachable => const ConnUnreachable(),
        ContentErrorKind.tls => const ConnTlsError(),
        _ => ConnUnknown(e.message),
      };
    } catch (e, st) {
      if (kDebugMode) debugPrint('Onboarding failed: $e\n$st');
      return const ConnUnknown('Unexpected error.');
    }
  }

  /// Persists the source, then the secret. On secret-write failure the source
  /// row is rolled back so we never leave an orphan row pointing at no secret.
  Future<ConnectionResult> _persist({
    required String baseUrl,
    required String label,
    required KomgaCredential credential,
  }) async {
    final db = ref.read(appDatabaseProvider);
    final credentials = ref.read(komgaCredentialStoreProvider);
    final sourceId = const Uuid().v4();

    await db.upsertSource(SourcesCompanion(
      id: Value(sourceId),
      kind: Value(SourceKind.komga.name),
      baseUrl: Value(baseUrl),
      authKind: Value(credential.authKind),
      label: Value(label),
    ));
    try {
      await credentials.write(sourceId, credential);
    } catch (_) {
      await db.deleteSource(sourceId);
      return const ConnUnknown('Could not store credentials securely.');
    }
    return ConnSuccess(sourceId);
  }
}
