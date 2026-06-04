import 'package:drift/drift.dart';

/// Per-series reader preferences. Composite PK `{sourceId, seriesId}`.
///
/// Enums are stored as their `.name` string (never the index) so adding variants
/// later cannot reinterpret existing rows. The data class is `ReaderSettingsRow`
/// to avoid colliding with the domain `ReaderSettings` class.
@DataClassName('ReaderSettingsRow')
class ReaderSettings extends Table {
  /// FK to `Sources.id`.
  TextColumn get sourceId => text()();

  /// Komga series id these settings apply to.
  TextColumn get seriesId => text()();

  TextColumn get mode => text()();
  TextColumn get fit => text()();
  TextColumn get taps => text()();
  BoolColumn get invertTaps => boolean().withDefault(const Constant(false))();
  BoolColumn get doubleTapZoom =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get animatePageTurn =>
      boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {sourceId, seriesId};
}
