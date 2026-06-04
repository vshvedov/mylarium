import '../../../core/storage/secure_store.dart';
import 'api_key_auth.dart';
import 'basic_auth.dart';
import 'komga_auth.dart';

/// A serializable Komga credential, persisted as JSON in secure storage and
/// reconstructed into the matching [KomgaAuth] strategy on load via [authKind].
sealed class KomgaCredential {
  const KomgaCredential();

  /// Stable enum NAME string; mirrors `Sources.authKind`.
  String get authKind;

  KomgaAuth toAuth();

  Map<String, Object?> toJson();

  factory KomgaCredential.fromJson(Map<String, Object?> json) {
    switch (json['authKind']) {
      case 'apiKey':
        return ApiKeyCredential(json['key']! as String);
      case 'basic':
        return BasicCredential(
          json['username']! as String,
          json['password']! as String,
        );
      default:
        throw FormatException('Unknown authKind: ${json['authKind']}');
    }
  }
}

class ApiKeyCredential extends KomgaCredential {
  const ApiKeyCredential(this.key);

  final String key;

  @override
  String get authKind => 'apiKey';

  @override
  KomgaAuth toAuth() => ApiKeyAuth(key);

  @override
  Map<String, Object?> toJson() => {'authKind': authKind, 'key': key};
}

class BasicCredential extends KomgaCredential {
  const BasicCredential(this.username, this.password);

  final String username;
  final String password;

  @override
  String get authKind => 'basic';

  @override
  KomgaAuth toAuth() => BasicAuth(username, password);

  @override
  Map<String, Object?> toJson() =>
      {'authKind': authKind, 'username': username, 'password': password};
}

/// Stores [KomgaCredential]s in [SecureStore] under `komga.cred.<sourceId>`.
class KomgaCredentialStore {
  const KomgaCredentialStore(this._store);

  final SecureStore _store;

  String _key(String sourceId) => 'komga.cred.$sourceId';

  Future<void> write(String sourceId, KomgaCredential credential) =>
      _store.writeJson(_key(sourceId), credential.toJson());

  Future<KomgaCredential?> read(String sourceId) async {
    final json = await _store.readJson(_key(sourceId));
    if (json == null) return null;
    return KomgaCredential.fromJson(json);
  }

  Future<void> delete(String sourceId) => _store.delete(_key(sourceId));
}
