import 'package:drift/drift.dart';

/// One row per connected content source (a Komga server today; local sources
/// land in T7). [id] is an app-generated identifier (uuid), never the server's.
///
/// [kind] and [authKind] store enum NAME strings (not indexes) so that adding
/// new [SourceKind] variants later cannot shift the meaning of existing rows.
/// Secrets never live here: only the non-secret [baseUrl]/[authKind]/[label].
/// The credential itself is in flutter_secure_storage, keyed by [id].
class Sources extends Table {
  /// App-generated source id (uuid v4). See SecureStore key `komga.cred.<id>`.
  TextColumn get id => text()();

  /// `SourceKind` name string, e.g. `komga`.
  TextColumn get kind => text()();

  /// Server origin (scheme + host + optional path prefix); no `/api/v1`.
  TextColumn get baseUrl => text().nullable()();

  /// `apiKey` or `basic` for Komga; null for sources without remote auth.
  TextColumn get authKind => text().nullable()();

  /// Reserved for local sources (SAF tree URI / iOS bookmark) in T7; null here.
  TextColumn get handle => text().nullable()();

  /// Human-facing label shown in source lists.
  TextColumn get label => text()();

  @override
  Set<Column> get primaryKey => {id};
}
