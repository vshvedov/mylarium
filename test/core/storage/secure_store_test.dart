import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/core/fs/app_paths.dart';
import 'package:mylarium/core/storage/secret_store.dart';
import 'package:mylarium/core/storage/secure_store.dart';
import 'package:path/path.dart' as p;

/// In-memory [SecretStore] standing in for a healthy Keychain/Keystore.
class _MemoryStore implements SecretStore {
  final Map<String, String> map = {};

  @override
  Future<void> write(String key, String value) async => map[key] = value;

  @override
  Future<String?> read(String key) async => map[key];

  @override
  Future<void> delete(String key) async => map.remove(key);
}

/// A [SecretStore] that throws on every op, standing in for the broken
/// hardware Keystore seen on some low-end Android 8 e-ink readers.
class _BrokenStore implements SecretStore {
  @override
  Future<void> write(String key, String value) async =>
      throw StateError('keystore unavailable');

  @override
  Future<String?> read(String key) async =>
      throw StateError('keystore unavailable');

  @override
  Future<void> delete(String key) async =>
      throw StateError('keystore unavailable');
}

void main() {
  group('SecureStore', () {
    test('uses the primary store when it is healthy, never the fallback',
        () async {
      final primary = _MemoryStore();
      final fallback = _MemoryStore();
      final store = SecureStore(primary: primary, fallback: fallback);

      await store.write('k', 'v');

      expect(primary.map['k'], 'v');
      expect(fallback.map.containsKey('k'), isFalse);
      expect(await store.read('k'), 'v');
    });

    test('falls back to the app-private store when the primary throws',
        () async {
      final fallback = _MemoryStore();
      final store = SecureStore(primary: _BrokenStore(), fallback: fallback);

      await store.write('komga.cred.s1', '{"password":"hunter2"}');

      // Written to the fallback, and still readable through the facade.
      expect(fallback.map['komga.cred.s1'], '{"password":"hunter2"}');
      expect(await store.read('komga.cred.s1'), '{"password":"hunter2"}');
    });

    test('delete clears both stores', () async {
      final primary = _MemoryStore()..map['k'] = 'v';
      final fallback = _MemoryStore()..map['k'] = 'v';
      final store = SecureStore(primary: primary, fallback: fallback);

      await store.delete('k');

      expect(primary.map.containsKey('k'), isFalse);
      expect(fallback.map.containsKey('k'), isFalse);
    });

    test('writeJson/readJson round-trip through the fallback', () async {
      final store = SecureStore(primary: _BrokenStore(), fallback: _MemoryStore());

      await store.writeJson('key', {'authKind': 'basic', 'username': 'a'});

      expect(await store.readJson('key'), {'authKind': 'basic', 'username': 'a'});
    });
  });

  group('FileSecretFallbackStore', () {
    late Directory tmp;

    setUp(() async {
      tmp = await Directory.systemTemp.createTemp('secure_fallback_test');
      AppPaths.debugOverrideRoot = tmp.path;
    });
    tearDown(() async {
      AppPaths.debugOverrideRoot = null;
      if (tmp.existsSync()) await tmp.delete(recursive: true);
    });

    test('round-trips values and survives a fresh instance (restart)',
        () async {
      await FileSecretFallbackStore().write('komga.cred.s1', 'secret-token');

      // A new instance reads the same on-disk file (simulates app restart).
      expect(await FileSecretFallbackStore().read('komga.cred.s1'),
          'secret-token');
    });

    test('does not persist the secret in plaintext on disk', () async {
      await FileSecretFallbackStore()
          .write('komga.cred.s1', 'super-secret-password');

      final file = File(p.join(tmp.path, 'secure_fallback.json'));
      expect(file.existsSync(), isTrue);
      final contents = file.readAsStringSync();
      expect(contents.contains('super-secret-password'), isFalse);
      // Sanity: it is valid JSON with an entry for the key.
      final json = jsonDecode(contents) as Map<String, Object?>;
      expect((json['entries'] as Map).containsKey('komga.cred.s1'), isTrue);
    });

    test('delete removes an entry', () async {
      final store = FileSecretFallbackStore();
      await store.write('k', 'v');
      await store.delete('k');
      expect(await store.read('k'), isNull);
    });

    test('reading an absent key returns null without creating the file',
        () async {
      expect(await FileSecretFallbackStore().read('nope'), isNull);
      expect(File(p.join(tmp.path, 'secure_fallback.json')).existsSync(),
          isFalse);
    });
  });
}
