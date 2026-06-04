import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/app_settings.dart';

part 'database.g.dart';

@DriftDatabase(tables: [AppSettings])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _open());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration =>
      MigrationStrategy(onCreate: (m) => m.createAll());

  /// Reads the single settings row, inserting defaults exactly once. Never
  /// clobbers a persisted row on subsequent launches.
  Future<AppSetting> getOrCreateSettings() async {
    final existing = await (select(appSettings)..limit(1)).getSingleOrNull();
    if (existing != null) return existing;
    await into(appSettings).insert(
      const AppSettingsCompanion(id: Value(1)),
      mode: InsertMode.insertOrIgnore,
    );
    return (select(appSettings)..where((t) => t.id.equals(1))).getSingle();
  }

  Future<void> updateThemeMode(String mode) =>
      (update(appSettings)..where((t) => t.id.equals(1)))
          .write(AppSettingsCompanion(themeMode: Value(mode)));

  Future<void> updateReduceMotionOverride(bool v) =>
      (update(appSettings)..where((t) => t.id.equals(1)))
          .write(AppSettingsCompanion(reduceMotionOverride: Value(v)));

  Stream<AppSetting> watchSettings() =>
      (select(appSettings)..where((t) => t.id.equals(1))).watchSingle();
}

LazyDatabase _open() => LazyDatabase(() async {
      final dir = await getApplicationSupportDirectory();
      final file = File(p.join(dir.path, 'mylarium.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
