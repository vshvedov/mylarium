import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/app_settings.dart';
import 'tables/books.dart';
import 'tables/libraries.dart';
import 'tables/series.dart';
import 'tables/sources.dart';

part 'database.g.dart';

@DriftDatabase(tables: [AppSettings, Sources, Libraries, Series, Books])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _open());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        // A fresh install at v2: createAll covers app_settings plus the four
        // source/metadata tables added in this version.
        onCreate: (m) => m.createAll(),
        // v1 -> v2: add the source + metadata tables. The v1 app_settings row
        // is left untouched (no data loss across an app update).
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(sources);
            await m.createTable(libraries);
            await m.createTable(series);
            await m.createTable(books);
          }
        },
      );

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

  // --- Sources -------------------------------------------------------------

  /// True once at least one source has been onboarded. Drives the boot route.
  Future<bool> hasAnySource() async {
    final row = await (selectOnly(sources)..addColumns([sources.id.count()]))
        .getSingle();
    return (row.read(sources.id.count()) ?? 0) > 0;
  }

  Future<void> upsertSource(SourcesCompanion row) =>
      into(sources).insertOnConflictUpdate(row);

  Future<void> deleteSource(String id) =>
      (delete(sources)..where((t) => t.id.equals(id))).go();

  Future<Source?> getSource(String id) =>
      (select(sources)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<Source>> allSources() => select(sources).get();

  Stream<List<Source>> watchSources() => select(sources).watch();

  // --- Metadata upserts (carry sourceId on every row) ----------------------

  Future<void> upsertLibrary(LibrariesCompanion row) =>
      into(libraries).insertOnConflictUpdate(row);

  Future<void> upsertSeries(SeriesCompanion row) =>
      into(series).insertOnConflictUpdate(row);

  Future<void> upsertBook(BooksCompanion row) =>
      into(books).insertOnConflictUpdate(row);

  /// Series for a source, title-sorted (drives the T2 debug list).
  Stream<List<SeriesRow>> watchSeries(String sourceId) =>
      (select(series)
            ..where((t) => t.sourceId.equals(sourceId))
            ..orderBy([(t) => OrderingTerm(expression: t.titleSort)]))
          .watch();

  Stream<List<Library>> watchLibraries(String sourceId) =>
      (select(libraries)..where((t) => t.sourceId.equals(sourceId))).watch();
}

LazyDatabase _open() => LazyDatabase(() async {
      final dir = await getApplicationSupportDirectory();
      final file = File(p.join(dir.path, 'mylarium.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
