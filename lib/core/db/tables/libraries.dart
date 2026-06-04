import 'package:drift/drift.dart';

/// A library belonging to a source. Komga entity ids are unique only within a
/// server, so the primary key is composite `{sourceId, id}` (CLAUDE.md forbids
/// single-source assumptions).
class Libraries extends Table {
  /// FK to `Sources.id`.
  TextColumn get sourceId => text()();

  /// Komga library id.
  TextColumn get id => text()();

  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {sourceId, id};
}
