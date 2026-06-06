import '../../../core/storage/secure_store.dart';

/// A serializable Kavita credential (the API key), persisted as JSON in secure
/// storage. The key is exchanged for a JWT at runtime by [KavitaAuth].
class KavitaCredential {
  const KavitaCredential(this.apiKey);

  final String apiKey;

  /// Mirrors `Sources.authKind`.
  String get authKind => 'apiKey';

  Map<String, Object?> toJson() => {'authKind': authKind, 'apiKey': apiKey};

  factory KavitaCredential.fromJson(Map<String, Object?> json) =>
      KavitaCredential(json['apiKey']! as String);
}

/// Stores [KavitaCredential]s in [SecureStore] under `kavita.cred.<sourceId>`.
class KavitaCredentialStore {
  const KavitaCredentialStore(this._store);

  final SecureStore _store;

  String _key(String sourceId) => 'kavita.cred.$sourceId';

  Future<void> write(String sourceId, KavitaCredential credential) =>
      _store.writeJson(_key(sourceId), credential.toJson());

  Future<KavitaCredential?> read(String sourceId) async {
    final json = await _store.readJson(_key(sourceId));
    if (json == null) return null;
    return KavitaCredential.fromJson(json);
  }

  Future<void> delete(String sourceId) => _store.delete(_key(sourceId));
}
