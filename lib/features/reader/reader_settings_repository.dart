import 'package:drift/drift.dart' show Value;

import '../../core/db/database.dart';
import 'reader_models.dart';

/// Loads and saves per-series [ReaderSettings] from the `reader_settings` table.
class ReaderSettingsRepository {
  const ReaderSettingsRepository(this._db);

  final AppDatabase _db;

  /// Loads settings for a series, or defaults when none are persisted.
  /// [mangaDirection] seeds the default reading direction (null in T4 until
  /// ComicInfo parsing lands in T7).
  Future<ReaderSettings> load(
    String sourceId,
    String seriesId, {
    String? mangaDirection,
  }) async {
    final row = await _db.getReaderSettings(sourceId, seriesId);
    if (row == null) return ReaderSettings.defaults(mangaDirection: mangaDirection);
    return ReaderSettings.fromColumns(
      mode: row.mode,
      fit: row.fit,
      taps: row.taps,
      invertTaps: row.invertTaps,
      doubleTapZoom: row.doubleTapZoom,
      animatePageTurn: row.animatePageTurn,
    );
  }

  Future<void> save(
    String sourceId,
    String seriesId,
    ReaderSettings s,
  ) =>
      _db.upsertReaderSettings(ReaderSettingsCompanion(
        sourceId: Value(sourceId),
        seriesId: Value(seriesId),
        mode: Value(s.mode.name),
        fit: Value(s.fit.name),
        taps: Value(s.taps.name),
        invertTaps: Value(s.invertTaps),
        doubleTapZoom: Value(s.doubleTapZoom),
        animatePageTurn: Value(s.animatePageTurn),
      ));
}
