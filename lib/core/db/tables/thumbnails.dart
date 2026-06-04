import 'package:drift/drift.dart';

/// Cached cover thumbnail for a series or book. Composite PK
/// `{sourceId, ownerType, ownerId}`.
///
/// Exactly one of [bytes]/[diskPath] is non-null: small images (< 256KB) live
/// inline as a BLOB to avoid a second file read on the hot grid path; larger
/// ones spill to disk and [diskPath] holds a path RELATIVE to applicationSupport
/// (CLAUDE.md: store relative paths only). [etag] is captured from the response
/// when present; conditional revalidation is a later phase.
@DataClassName('Thumbnail')
class Thumbnails extends Table {
  /// FK to `Sources.id`.
  TextColumn get sourceId => text()();

  /// `series` or `book`.
  TextColumn get ownerType => text()();

  /// Komga id of the owning series/book.
  TextColumn get ownerId => text()();

  BlobColumn get bytes => blob().nullable()();

  /// Path RELATIVE to applicationSupport when the image spilled to disk.
  TextColumn get diskPath => text().nullable()();

  TextColumn get etag => text().nullable()();
  IntColumn get fetchedAt => integer()();

  @override
  Set<Column> get primaryKey => {sourceId, ownerType, ownerId};
}
