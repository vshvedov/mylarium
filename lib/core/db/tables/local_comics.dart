import 'package:drift/drift.dart';

/// One imported or scanned local comic archive. Serves BOTH local source
/// types: rows of the device's "Local files" source (copy-on-import) and rows
/// of an Android folder library (SAF tree, T4), keyed by [sourceId].
///
/// [kind] stores a `SourceKind` NAME string describing provenance
/// (`localCopy` / `urlDownload` for copies, `safTree` for tree rows). Exactly
/// one of [managedPath] (path RELATIVE to applicationSupport, copies) and
/// [treeDocPath] (document path within the source's SAF tree, T4) is non-null,
/// decided by [kind]. [pageOrder] is the JSON-encoded natural-sorted list of
/// page entry names inside the archive. [contentHash] (sha256 hex) plus
/// [sizeBytes] powers duplicate-import detection; [lastModified] (epoch ms)
/// powers the T4 rescan reconcile.
@DataClassName('LocalComic')
@TableIndex(name: 'idx_local_comics_series', columns: {#sourceId, #seriesSort, #id})
@TableIndex(name: 'idx_local_comics_books', columns: {#sourceId, #series, #numberSort})
class LocalComics extends Table {
  /// App-generated comic id (uuid v4).
  TextColumn get id => text()();

  /// FK to `Sources.id` (the Local files source or one folder source).
  TextColumn get sourceId => text()();

  /// Provenance `SourceKind` name: `localCopy` | `urlDownload` | `safTree`.
  TextColumn get kind => text()();

  /// Path RELATIVE to applicationSupport for copied imports; null for tree rows.
  TextColumn get managedPath => text().nullable()();

  /// Document path within the owning SAF tree (T4); null for copied imports.
  TextColumn get treeDocPath => text().nullable()();

  TextColumn get series => text()();

  /// Lowercased, article-stripped series sort key (groups the series grid).
  TextColumn get seriesSort => text()();

  /// Issue/chapter number as a display string (e.g. "1", "7.5", "Special").
  TextColumn get number => text()();
  RealColumn get numberSort => real().nullable()();
  IntColumn get volume => integer().nullable()();
  TextColumn get title => text()();

  /// Minimum age in years from ComicInfo, or NULL when unrated (never coerced
  /// to 0: age-gating distinguishes "unset" from a real rating of 0).
  IntColumn get ageRating => integer().nullable()();

  /// `ltr` | `rtl` (from ComicInfo `Manga=YesAndRightToLeft`).
  TextColumn get readingDirection =>
      text().withDefault(const Constant('ltr'))();

  /// JSON-encoded natural-sorted page entry names.
  TextColumn get pageOrder => text()();
  IntColumn get pagesCount => integer()();
  IntColumn get sizeBytes => integer().nullable()();

  /// sha256 hex of the archive bytes (duplicate detection).
  TextColumn get contentHash => text().nullable()();

  /// Source file mtime, epoch ms (T4 rescan reconcile); null for copies.
  IntColumn get lastModified => integer().nullable()();

  /// Device clock, epoch ms.
  IntColumn get importedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
