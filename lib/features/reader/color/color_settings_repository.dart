import 'package:drift/drift.dart' show Value;

import '../../../core/db/database.dart';
import 'color_settings.dart';

/// Loads and saves reader color-correction settings from the `color_settings`
/// table, applying global -> series -> book precedence (most specific wins),
/// with a per-scope enable flag.
class ColorSettingsRepository {
  const ColorSettingsRepository(this._db);

  final AppDatabase _db;

  /// The effective adjustment for a book, by precedence. Empty/absent
  /// [seriesId] or [bookId] skip that tier (an unknown series must not collide
  /// on an empty key). A disabled most-specific row resolves to identity.
  Future<ColorAdjustments> resolve(
    String sourceId,
    String? seriesId,
    String? bookId,
  ) async {
    final global = await forScope(const ColorScope.global());
    final series = (seriesId != null && seriesId.isNotEmpty)
        ? await forScope(ColorScope.series(sourceId, seriesId))
        : null;
    final book = (bookId != null && bookId.isNotEmpty)
        ? await forScope(ColorScope.book(sourceId, bookId))
        : null;
    return resolveScopedColor(global, series, book);
  }

  /// The settings persisted AT [scope] (adjustments + enable), or null when no
  /// row exists.
  Future<ScopedColor?> forScope(ColorScope scope) async {
    final row = await _db.getColorSettings(
      scope.sourceId,
      scope.kind.name,
      scope.id,
    );
    if (row == null) return null;
    return ScopedColor(_adjFromRow(row), row.enabled);
  }

  /// Writes the FULL record at [scope] (adjustments + [enabled]). A save
  /// freezes the currently-shown (possibly inherited) values as explicit
  /// overrides at this scope; later parent changes do not field-merge in.
  Future<void> save(
    ColorScope scope,
    ColorAdjustments adj, {
    required bool enabled,
  }) =>
      _db.upsertColorSettings(ColorSettingsCompanion(
        sourceId: Value(scope.sourceId),
        scope: Value(scope.kind.name),
        scopeId: Value(scope.id),
        enabled: Value(enabled),
        brightness: Value(adj.brightness),
        contrast: Value(adj.contrast),
        gamma: Value(adj.gamma),
        mode: Value(adj.mode.name),
        autoLevels: Value(adj.autoLevels),
      ));

  /// Deletes the row at [scope]; resolve then falls back up the chain.
  Future<void> reset(ColorScope scope) =>
      _db.deleteColorSettings(scope.sourceId, scope.kind.name, scope.id);

  static ColorAdjustments _adjFromRow(ColorSettingsRow row) => ColorAdjustments(
        brightness: row.brightness,
        contrast: row.contrast,
        gamma: row.gamma,
        mode: ColorMode.values.firstWhere(
          (m) => m.name == row.mode,
          orElse: () => ColorMode.none,
        ),
        autoLevels: row.autoLevels,
      );
}
