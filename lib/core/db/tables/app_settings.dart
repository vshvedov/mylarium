import 'package:drift/drift.dart';

/// Single-row app settings. The row is always id = 1; see
/// [AppDatabase.getOrCreateSettings]. Later tasks must not insert a second row.
class AppSettings extends Table {
  IntColumn get id => integer()();
  TextColumn get themeMode => text().withDefault(const Constant('system'))();
  BoolColumn get reduceMotionOverride =>
      boolean().withDefault(const Constant(false))();
  // 2 GiB default; the auto-cache size cap. 64-bit safe.
  IntColumn get cacheCapBytes =>
      integer().withDefault(const Constant(2147483648))();

  /// Whether opening a chapter auto-downloads it in the background (the
  /// ephemeral, LRU-evicted auto-cache pool).
  BoolColumn get autoCacheEnabled =>
      boolean().withDefault(const Constant(true))();

  /// Whether auto-cache downloads require Wi-Fi. Manual downloads ignore this.
  BoolColumn get downloadWifiOnly =>
      boolean().withDefault(const Constant(true))();

  /// Stable per-install id (uuid v4), generated once on first settings read.
  /// Stamped on local reading sessions; forward-compat for phase-2 multi-device
  /// dedup. NULL only between the column add and the first generation.
  TextColumn get deviceId => text().nullable()();

  /// Reader image quality. When true, Mylarium picks the page decode ceiling for
  /// the device; when false, [imageQualityManualLevel] selects it.
  BoolColumn get imageQualitySmart =>
      boolean().withDefault(const Constant(true))();

  /// Manual quality stop (index into the reader's ceiling table), used only when
  /// [imageQualitySmart] is false. Defaults to the middle stop.
  IntColumn get imageQualityManualLevel =>
      integer().withDefault(const Constant(2))();

  @override
  Set<Column> get primaryKey => {id};
}
