import 'package:drift/drift.dart';

/// Single-row app settings. The row is always id = 1; see
/// [AppDatabase.getOrCreateSettings]. Later tasks must not insert a second row.
class AppSettings extends Table {
  IntColumn get id => integer()();
  TextColumn get themeMode => text().withDefault(const Constant('system'))();
  BoolColumn get reduceMotionOverride =>
      boolean().withDefault(const Constant(false))();
  // 2 GiB default; unused until T5 (offline cache cap). 64-bit safe.
  IntColumn get cacheCapBytes =>
      integer().withDefault(const Constant(2147483648))();

  @override
  Set<Column> get primaryKey => {id};
}
