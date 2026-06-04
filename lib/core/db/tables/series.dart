import 'package:drift/drift.dart';

/// A series belonging to a source. Composite PK `{sourceId, id}`.
///
/// [ageRating] is nullable and stays NULL when the source does not supply one
/// (it is never coerced to 0): T3's age-gating distinguishes "unset" from a
/// real rating of 0.
@DataClassName('SeriesRow')
@TableIndex(name: 'series_keyset', columns: {#sourceId, #titleSort, #id})
@TableIndex(
    name: 'series_keyset_lib', columns: {#sourceId, #libraryId, #titleSort, #id})
class Series extends Table {
  /// FK to `Sources.id`.
  TextColumn get sourceId => text()();

  /// Komga series id.
  TextColumn get id => text()();

  /// Komga library id this series belongs to.
  TextColumn get libraryId => text()();

  TextColumn get title => text()();
  TextColumn get titleSort => text()();
  IntColumn get ageRating => integer().nullable()();
  TextColumn get status => text().nullable()();
  TextColumn get summary => text().nullable()();
  IntColumn get booksCount => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {sourceId, id};
}
