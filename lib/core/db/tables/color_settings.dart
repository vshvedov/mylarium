import 'package:drift/drift.dart';

/// Persisted reader page color-correction settings, scoped global / per-series
/// / per-book. Composite PK `{sourceId, scope, scopeId}`: the `global` row uses
/// empty `sourceId`/`scopeId`; `series`/`book` rows carry the owning ids.
///
/// [mode] stores the `ColorMode.name` string (never the index) so adding
/// variants later cannot reinterpret existing rows.
@DataClassName('ColorSettingsRow')
class ColorSettings extends Table {
  /// FK to `Sources.id` (empty string for the app-wide `global` row).
  TextColumn get sourceId => text()();

  /// `ColorScopeKind.name`: `global` | `series` | `book`.
  TextColumn get scope => text()();

  /// The owning id for the scope: empty for global, seriesId for series,
  /// bookId for book.
  TextColumn get scopeId => text()();

  /// Whether correction is enabled at this scope. Persisted per scope so the
  /// user can independently toggle global / series / chapter. A disabled
  /// most-specific row acts as an explicit "no correction here" override.
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();

  RealColumn get brightness => real().withDefault(const Constant(0.0))();
  RealColumn get contrast => real().withDefault(const Constant(0.0))();
  RealColumn get gamma => real().withDefault(const Constant(1.0))();
  TextColumn get mode => text().withDefault(const Constant('none'))();
  BoolColumn get autoLevels => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {sourceId, scope, scopeId};
}
