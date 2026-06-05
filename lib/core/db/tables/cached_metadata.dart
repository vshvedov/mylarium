import 'package:drift/drift.dart';

/// A generic JSON cache for resource metadata that has no dedicated typed table
/// yet. Composite PK `{sourceId, ownerType, ownerId}`.
///
/// [json] holds a serialized payload whose shape depends on `ownerType`; it is
/// overwritten on a fresh fetch. Current owners:
/// - `collections` / `readlists`: the raw Komga `content` list; `ownerId` is the
///   `sourceId` (one cached list per source).
/// - `comicvine.volume` (`ownerId` = seriesId) / `comicvine.issue`
///   (`ownerId` = bookId): the structured Comic Vine display payload, or
///   `{"v":1,"noMatch":true}` for a cached no-match.
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
