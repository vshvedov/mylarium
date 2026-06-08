import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../app/theme/theme_controller.dart' show appDatabaseProvider;
import '../../core/db/database.dart';
import '../../core/network/content_exception.dart';
import '../../data/kavita/auth/kavita_credential.dart';
import '../../data/kavita/kavita_providers.dart';
import '../../data/source/content_source.dart';
import '../../data/source/source_providers.dart';
import 'connection_result.dart';
import 'onboarding_controller.dart' show normalizeServerUrl;

part 'kavita_connect_controller.g.dart';

/// The Kavita role required for the app to read content. Kavita issues this in
/// the JWT `role` claim for any login-capable account.
const requiredKavitaRoles = {'Login'};

/// Drives the Kavita connect screen. State is the latest [ConnectionResult]
/// (null before the first attempt); [AsyncLoading] while a connection is in
/// flight. Mirrors [OnboardingController] but for the Kavita API-key flow.
@riverpod
class KavitaConnectController extends _$KavitaConnectController {
  @override
  AsyncValue<ConnectionResult?> build() => const AsyncData(null);

  Future<void> connect({required String url, required String apiKey}) async {
    state = const AsyncLoading();
    state = AsyncData(await _attempt(url: url, apiKey: apiKey));
  }

  Future<ConnectionResult> _attempt({
    required String url,
    required String apiKey,
  }) async {
    final uri = normalizeServerUrl(url);
    if (uri == null) return const ConnInvalidUrl();
    final baseUrl = uri.toString();

    final key = apiKey.trim();
    if (key.isEmpty) return const ConnUnauthorized();

    final api =
        ref.read(kavitaApiFactoryProvider)(baseUrl: baseUrl, apiKey: key);

    try {
      final info = await api.validate();
      final missing = requiredKavitaRoles.difference(info.roles);
      if (missing.isNotEmpty) return ConnMissingRoles(missing);

      return _persist(baseUrl: baseUrl, label: uri.host, apiKey: key);
    } on ContentException catch (e) {
      return switch (e.kind) {
        ContentErrorKind.unauthorized => const ConnUnauthorized(),
        ContentErrorKind.forbidden => const ConnUnauthorized(),
        ContentErrorKind.unreachable => const ConnUnreachable(),
        ContentErrorKind.tls => const ConnTlsError(),
        _ => ConnUnknown(e.message),
      };
    } catch (e, st) {
      if (kDebugMode) debugPrint('Kavita onboarding failed: $e\n$st');
      return const ConnUnknown('Unexpected error.');
    }
  }

  /// Persists the source, then the secret. On secret-write failure the source
  /// row is rolled back so no orphan row points at no secret.
  Future<ConnectionResult> _persist({
    required String baseUrl,
    required String label,
    required String apiKey,
  }) async {
    final db = ref.read(appDatabaseProvider);
    final credentials = ref.read(kavitaCredentialStoreProvider);
    final sourceId = const Uuid().v4();

    await db.upsertSource(SourcesCompanion(
      id: Value(sourceId),
      kind: Value(SourceKind.kavita.name),
      baseUrl: Value(baseUrl),
      authKind: const Value('apiKey'),
      label: Value(label),
    ));
    try {
      await credentials.write(sourceId, KavitaCredential(apiKey));
    } catch (_) {
      await db.deleteSource(sourceId);
      return const ConnUnknown('Could not store credentials securely.');
    }
    // Make the freshly connected source active immediately. ActiveSourceId is a
    // keepAlive one-shot read of the sources table, so it does not observe this
    // insert on its own; without this the home screen shows "No source
    // connected" until the next app launch rebuilds the provider.
    ref.read(activeSourceIdProvider.notifier).select(sourceId);
    return ConnSuccess(sourceId);
  }
}
