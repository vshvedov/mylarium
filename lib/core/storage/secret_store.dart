import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import '../fs/app_paths.dart';
import '../fs/backup_exclusion.dart';

/// A minimal string secret store: the shared contract behind the platform
/// Keychain/Keystore and the on-device fallback used when that is unavailable.
abstract interface class SecretStore {
  Future<void> write(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
}

/// App-private fallback secret store, used only when the hardware-backed
/// Keychain/Keystore throws (observed on some low-end Android 8 e-ink readers
/// whose Keystore provider is broken; without a fallback the app can never save
/// a Komga/Kavita connection there). Values are lightly obfuscated with a
/// per-install random salt so credentials do not sit in readable plaintext, and
/// the file is excluded from iCloud/Android backup. This is deliberately NOT a
/// substitute for the Keystore (the salt lives beside the data, so it defends
/// against casual inspection, not a determined attacker with device access); it
/// is only reached when real secure storage is unavailable.
///
/// The whole store is a single JSON file under the application-support
/// directory: `{ "v": 1, "salt": <base64>, "entries": { <key>: <base64> } }`.
class FileSecretFallbackStore implements SecretStore {
  FileSecretFallbackStore({Future<File> Function()? resolveFile})
      : _resolveFile = resolveFile ?? (() => AppPaths.prepareFile(_fileName));

  static const _fileName = 'secure_fallback.json';

  final Future<File> Function() _resolveFile;
  final Random _random = Random.secure();

  /// In-memory copy of the parsed file (`{salt, entries}`), loaded once. A
  /// healthy device that only ever reads absent keys keeps this empty and never
  /// writes the file to disk.
  Map<String, Object?>? _cache;

  /// Serializes read-modify-write cycles so concurrent writes cannot interleave
  /// and clobber the file.
  Future<void> _lock = Future<void>.value();

  Future<T> _locked<T>(Future<T> Function() action) {
    final previous = _lock;
    final completer = Completer<void>();
    _lock = completer.future;
    return previous.then((_) => action()).whenComplete(completer.complete);
  }

  @override
  Future<void> write(String key, String value) => _locked(() async {
        final file = await _resolveFile();
        final data = await _load(file);
        final salt = base64.decode(data['salt']! as String);
        final entries = data['entries']! as Map<String, Object?>;
        final bytes = utf8.encode(value);
        entries[key] =
            base64.encode(_xor(bytes, _keystream(salt, key, bytes.length)));
        await _persist(file, data);
      });

  @override
  Future<String?> read(String key) => _locked(() async {
        final file = await _resolveFile();
        final data = await _load(file);
        final stored = (data['entries']! as Map<String, Object?>)[key];
        if (stored is! String) return null;
        final salt = base64.decode(data['salt']! as String);
        final cipher = base64.decode(stored);
        return utf8.decode(_xor(cipher, _keystream(salt, key, cipher.length)));
      });

  @override
  Future<void> delete(String key) => _locked(() async {
        final file = await _resolveFile();
        final data = await _load(file);
        final entries = data['entries']! as Map<String, Object?>;
        if (entries.remove(key) != null) {
          await _persist(file, data);
        }
      });

  Future<Map<String, Object?>> _load(File file) async {
    final cached = _cache;
    if (cached != null) return cached;
    if (await file.exists()) {
      try {
        final raw = jsonDecode(await file.readAsString()) as Map<String, Object?>;
        final entries =
            (raw['entries'] as Map?)?.cast<String, Object?>() ?? <String, Object?>{};
        final salt = raw['salt'] is String
            ? raw['salt'] as String
            : base64.encode(_newSalt());
        return _cache = {'v': 1, 'salt': salt, 'entries': entries};
      } catch (_) {
        // Corrupt or unreadable file: start fresh rather than trapping the user
        // in a permanent failure. Any prior fallback secret is lost, so the app
        // re-prompts for the connection once - acceptable for this rare path.
      }
    }
    return _cache = {
      'v': 1,
      'salt': base64.encode(_newSalt()),
      'entries': <String, Object?>{},
    };
  }

  Future<void> _persist(File file, Map<String, Object?> data) async {
    await file.parent.create(recursive: true);
    // Write to a sibling temp file then rename so a crash mid-write cannot leave
    // a truncated store.
    final tmp = File('${file.path}.tmp');
    await tmp.writeAsString(jsonEncode(data), flush: true);
    await tmp.rename(file.path);
    await BackupExclusion.exclude(file.path);
  }

  List<int> _newSalt() => List<int>.generate(32, (_) => _random.nextInt(256));

  /// SHA-256 counter-mode keystream keyed by (salt, entry key). Binding the key
  /// in means identical values under different keys obfuscate differently.
  List<int> _keystream(List<int> salt, String key, int length) {
    final out = <int>[];
    final keyBytes = utf8.encode(key);
    var counter = 0;
    while (out.length < length) {
      final block = ByteData(4)..setUint32(0, counter);
      out.addAll(
        sha256.convert([...salt, ...keyBytes, ...block.buffer.asUint8List()])
            .bytes,
      );
      counter++;
    }
    return out;
  }

  List<int> _xor(List<int> data, List<int> stream) =>
      [for (var i = 0; i < data.length; i++) data[i] ^ stream[i]];
}
