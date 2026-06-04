import 'package:drift/drift.dart';

/// A generic JSON cache for resource metadata that has no dedicated typed table
/// yet (collections, read lists). Composite PK `{sourceId, ownerType, ownerId}`.
///
/// [json] holds the raw Komga `content` list (serialized) so browsing works
/// across a restart; on a fresh online fetch it is overwritten. `ownerType` is
/// one of `collections` / `readlists`; `ownerId` is the `sourceId` (one cached
/// list per source).
@DataClassName('CachedMetadataRow')
class CachedMetadata extends Table {
  /// FK to `Sources.id`.
  TextColumn get sourceId => text()();

  /// `collections` or `readlists`.
  TextColumn get ownerType => text()();

  TextColumn get ownerId => text()();

  TextColumn get json => text()();
  IntColumn get fetchedAt => integer()();

  @override
  Set<Column> get primaryKey => {sourceId, ownerType, ownerId};
}
