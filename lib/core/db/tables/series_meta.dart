import 'package:drift/drift.dart';

/// Extended series metadata for the stats breakdowns (publisher, genres), kept
/// in its own table rather than as columns on `Series`.
///
/// Why a side table: `Series` is `createTable`d inside the v1 -> v2 migration
/// step, so adding columns to it would make that historical step emit a shape
/// that no longer matches the committed v2..v6 schema snapshots (the migration
/// goldens validate exact intermediate shapes). A new table introduced at v7
/// changes no historical table, so every prior golden stays green. Migrations
/// are the highest-risk subsystem (CLAUDE.md); this keeps the risk at zero.
///
/// Composite PK `{sourceId, seriesId}`. Rows are written on series sync; a
/// series not yet (re)synced after T6 simply has no row, and stats bucket it
/// under "Unknown".
@DataClassName('SeriesMetaRow')
class SeriesMeta extends Table {
  TextColumn get sourceId => text()();
  TextColumn get seriesId => text()();
  TextColumn get publisher => text().nullable()();

  /// JSON-encoded `List<String>` of genres (tag-overlap breakdown).
  TextColumn get genres => text().nullable()();

  @override
  Set<Column> get primaryKey => {sourceId, seriesId};
}
