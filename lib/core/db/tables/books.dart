import 'package:drift/drift.dart';

/// A book belonging to a source. Composite PK `{sourceId, id}`.
///
/// [readPage]/[completed] cache the last-known Komga read progress for display;
/// progress write-back (pushing local progress to the server) is T6.
class Books extends Table {
  /// FK to `Sources.id`.
  TextColumn get sourceId => text()();

  /// Komga book id.
  TextColumn get id => text()();

  /// Komga series id this book belongs to.
  TextColumn get seriesId => text()();

  /// Komga library id this book belongs to.
  TextColumn get libraryId => text()();

  TextColumn get title => text()();

  /// Issue/volume number as a display string (e.g. "1", "1.5", "Special").
  TextColumn get number => text()();
  RealColumn get numberSort => real().nullable()();
  IntColumn get pagesCount => integer().withDefault(const Constant(0))();
  TextColumn get mediaType => text().nullable()();
  IntColumn get sizeBytes => integer().nullable()();
  IntColumn get readPage => integer().nullable()();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {sourceId, id};
}
