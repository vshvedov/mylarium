import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../age_rating.dart';
import 'tables/app_settings.dart';
import 'tables/books.dart';
import 'tables/cached_metadata.dart';
import 'tables/libraries.dart';
import 'tables/library_prefs.dart';
import 'tables/series.dart';
import 'tables/sources.dart';
import 'tables/thumbnails.dart';

part 'database.g.dart';

@DriftDatabase(tables: [
  AppSettings,
  Sources,
  Libraries,
  Series,
  Books,
  Thumbnails,
  CachedMetadata,
  LibraryPrefs,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _open());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        // A fresh install at the current version: createAll covers every table
        // plus the generated indexes.
        onCreate: (m) => m.createAll(),
        // Each bump is additive. v1 data is never touched (no data loss across
        // an app update).
        onUpgrade: (m, from, to) async {
          // v1 -> v2: source + metadata tables.
          if (from < 2) {
            await m.createTable(sources);
            await m.createTable(libraries);
            await m.createTable(series);
            await m.createTable(books);
          }
          // v2 -> v3: thumbnail/metadata caches, per-library prefs, and the
          // series keyset indexes that back the virtualized grids.
          if (from < 3) {
            await m.createTable(thumbnails);
            await m.createTable(cachedMetadata);
            await m.createTable(libraryPrefs);
            await m.createIndex(seriesKeyset);
            await m.createIndex(seriesKeysetLib);
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

  /// One keyset page of series for [sourceId], ordered by `(titleSort, id)`.
  /// [afterTitleSort]/[afterId] is the cursor (both null = first page). When
  /// [includeRestricted] is false, age-restricted series are excluded in SQL.
  /// Index-backed by `series_keyset` (unscoped) / `series_keyset_lib` (scoped).
  Future<List<SeriesRow>> seriesPage({
    required String sourceId,
    String? libraryId,
    String? afterTitleSort,
    String? afterId,
    required int limit,
    required bool includeRestricted,
  }) {
    final q = select(series)..where((t) => t.sourceId.equals(sourceId));
    if (libraryId != null) {
      q.where((t) => t.libraryId.equals(libraryId));
    }
    if (!includeRestricted) {
      // NULL ageRating is allowed; only hide >= kRestrictedAgeRating.
      q.where((t) =>
          t.ageRating.isNull() |
          t.ageRating.isSmallerThanValue(kRestrictedAgeRating));
    }
    if (afterTitleSort != null && afterId != null) {
      q.where((t) =>
          t.titleSort.isBiggerThanValue(afterTitleSort) |
          (t.titleSort.equals(afterTitleSort) &
              t.id.isBiggerThanValue(afterId)));
    }
    q.orderBy([
      (t) => OrderingTerm(expression: t.titleSort),
      (t) => OrderingTerm(expression: t.id),
    ]);
    q.limit(limit);
    return q.get();
  }

  /// Count of cached series for a source (used to detect a partially-filled
  /// cache against the server's reported total).
  Future<int> seriesCount(String sourceId, {String? libraryId}) async {
    final count = series.id.count();
    final q = selectOnly(series)
      ..addColumns([count])
      ..where(series.sourceId.equals(sourceId));
    if (libraryId != null) {
      q.where(series.libraryId.equals(libraryId));
    }
    final row = await q.getSingle();
    return row.read(count) ?? 0;
  }

  Future<SeriesRow?> getSeries(String sourceId, String id) =>
      (select(series)
            ..where((t) => t.sourceId.equals(sourceId) & t.id.equals(id)))
          .getSingleOrNull();

  /// Books of a series, ordered by numberSort then number (drives series
  /// detail).
  Stream<List<Book>> watchBooksForSeries(String sourceId, String seriesId) =>
      (select(books)
            ..where((t) => t.sourceId.equals(sourceId) &
                t.seriesId.equals(seriesId))
            ..orderBy([
              (t) => OrderingTerm(expression: t.numberSort),
              (t) => OrderingTerm(expression: t.number),
            ]))
          .watch();

  Future<Book?> getBook(String sourceId, String id) =>
      (select(books)..where((t) => t.sourceId.equals(sourceId) & t.id.equals(id)))
          .getSingleOrNull();

  // --- Thumbnails ----------------------------------------------------------

  Future<Thumbnail?> getThumbnail(
    String sourceId,
    String ownerType,
    String ownerId,
  ) =>
      (select(thumbnails)
            ..where((t) =>
                t.sourceId.equals(sourceId) &
                t.ownerType.equals(ownerType) &
                t.ownerId.equals(ownerId)))
          .getSingleOrNull();

  Future<void> upsertThumbnail(ThumbnailsCompanion row) =>
      into(thumbnails).insertOnConflictUpdate(row);

  // --- Cached metadata (collections / read lists) --------------------------

  Future<CachedMetadataRow?> getCachedMetadata(
    String sourceId,
    String ownerType,
    String ownerId,
  ) =>
      (select(cachedMetadata)
            ..where((t) =>
                t.sourceId.equals(sourceId) &
                t.ownerType.equals(ownerType) &
                t.ownerId.equals(ownerId)))
          .getSingleOrNull();

  Future<void> upsertCachedMetadata(CachedMetadataCompanion row) =>
      into(cachedMetadata).insertOnConflictUpdate(row);

  // --- Library prefs (lock / show-restricted) ------------------------------

  Future<LibraryPref?> getLibraryPref(String sourceId, String libraryId) =>
      (select(libraryPrefs)
            ..where((t) =>
                t.sourceId.equals(sourceId) & t.libraryId.equals(libraryId)))
          .getSingleOrNull();

  Future<List<LibraryPref>> allLibraryPrefs(String sourceId) =>
      (select(libraryPrefs)..where((t) => t.sourceId.equals(sourceId))).get();

  Stream<List<LibraryPref>> watchLibraryPrefs(String sourceId) =>
      (select(libraryPrefs)..where((t) => t.sourceId.equals(sourceId))).watch();

  Future<void> upsertLibraryPref(LibraryPrefsCompanion row) =>
      into(libraryPrefs).insertOnConflictUpdate(row);
}

LazyDatabase _open() => LazyDatabase(() async {
      final dir = await getApplicationSupportDirectory();
      final file = File(p.join(dir.path, 'mylarium.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
