import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Thin wrapper over the platform Keychain/Keystore. Generic string/JSON secret
/// store; callers own the key namespace (e.g. `komga.cred.<sourceId>`). Keeping
/// this free of domain types lets `core` stay below `data` in the layering.
class SecureStore {
  SecureStore([FlutterSecureStorage? storage])
      : _storage = storage ??
            const FlutterSecureStorage(
              // Keystore-backed encrypted storage on Android (not the legacy
              // plaintext-ish SharedPreferences); device-only Keychain on iOS
              // that survives reboot and never syncs to iCloud.
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
            );

  final FlutterSecureStorage _storage;

  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  Future<String?> read(String key) => _storage.read(key: key);

  Future<void> delete(String key) => _storage.delete(key: key);

  Future<void> writeJson(String key, Map<String, Object?> value) =>
      write(key, jsonEncode(value));

  Future<Map<String, Object?>?> readJson(String key) async {
    final raw = await read(key);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, Object?>;
  }
}
