import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mylarium/app/theme/theme_controller.dart';
import 'package:mylarium/core/db/database.dart';

/// Builds a fresh in-memory DB and its provider overrides for a single test.
/// The caller closes [db] via `addTearDown`.
class TestScope {
  TestScope._(this.db, this.overrides);

  final AppDatabase db;
  final List<Override> overrides;

  static Future<TestScope> create({AppSetting? settings}) async {
    final db = AppDatabase(NativeDatabase.memory());
    final s = settings ?? await db.getOrCreateSettings();
    return TestScope._(db, [
      appDatabaseProvider.overrideWithValue(db),
      initialSettingsProvider.overrideWithValue(s),
    ]);
  }
}
