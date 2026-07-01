import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'secret_store.dart';

/// Adapts [FlutterSecureStorage] to the [SecretStore] contract (its own methods
/// take named args). This is the primary, hardware-backed secret store.
class KeychainSecretStore implements SecretStore {
  const KeychainSecretStore(this._storage);

  final FlutterSecureStorage _storage;

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

/// Thin wrapper over the platform Keychain/Keystore. Generic string/JSON secret
/// store; callers own the key namespace (e.g. `komga.cred.<sourceId>`). Keeping
/// this free of domain types lets `core` stay below `data` in the layering.
///
/// Resilience: the platform Keystore is the primary store, but on some devices
/// it is unavailable (a broken hardware Keystore on certain low-end Android 8
/// e-ink readers throws on every write). Rather than fail every connection with
/// "Could not store credentials securely.", a Keystore failure transparently
/// falls back to an app-private, obfuscated on-device store so the app stays
/// usable. iOS Keychain and healthy Android devices never touch the fallback.
class SecureStore {
  SecureStore({SecretStore? primary, SecretStore? fallback})
      : _primary = primary ??
            const KeychainSecretStore(
              // Android: the plugin's DEFAULT backend - values encrypted with a
              // hardware-backed Android Keystore key, stored in SharedPreferences.
              // We deliberately do NOT use `encryptedSharedPreferences: true`
              // (AndroidX Security Crypto / Tink): on this app's devices that
              // backend fails to re-initialize on app restart, and the plugin
              // then SILENTLY falls back to an empty non-encrypted store
              // (FlutterSecureStorage.java: failedToUseEncryptedSharedPreferences).
              // The effect is that a credential written during onboarding reads
              // back null on the next launch, so the app re-prompts for Komga
              // creds every restart (Android-only; iOS Keychain is unaffected).
              // The default backend keeps values Keystore-encrypted without that
              // failure mode. Switching backends means existing creds re-auth
              // once; acceptable.
              FlutterSecureStorage(
                iOptions: IOSOptions(
                  accessibility: KeychainAccessibility.first_unlock_this_device,
                ),
              ),
            ),
        _fallback = fallback ?? FileSecretFallbackStore();

  final SecretStore _primary;
  final SecretStore _fallback;

  Future<void> write(String key, String value) async {
    try {
      await _primary.write(key, value);
    } catch (_) {
      // Hardware Keystore unavailable/broken on this device: keep the app usable
      // by persisting to the obfuscated app-private fallback instead of failing.
      await _fallback.write(key, value);
    }
  }

  Future<String?> read(String key) async {
    try {
      final value = await _primary.read(key);
      if (value != null) return value;
    } catch (_) {
      // Primary unusable; fall through to the fallback below.
    }
    return _fallback.read(key);
  }

  Future<void> delete(String key) async {
    try {
      await _primary.delete(key);
    } catch (_) {
      // Ignore: the value may only exist in the fallback, cleared below.
    }
    await _fallback.delete(key);
  }

  Future<void> writeJson(String key, Map<String, Object?> value) =>
      write(key, jsonEncode(value));

  Future<Map<String, Object?>?> readJson(String key) async {
    final raw = await read(key);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, Object?>;
  }
}
