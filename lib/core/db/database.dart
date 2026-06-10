import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart' show OpenMode, sqlite3;
import 'package:uuid/uuid.dart';

import 'tables/app_settings.dart';
import 'tables/book_state.dart';
import 'tables/books.dart';
import 'tables/cached_assets.dart';
import 'tables/cached_metadata.dart';
import 'tables/captures.dart';
import 'tables/color_settings.dart';
import 'tables/download_tasks.dart';
import 'tables/home_rail_items.dart';
import 'tables/libraries.dart';
import 'tables/library_prefs.dart';
import 'tables/local_comics.dart';
import 'tables/pins.dart';
import 'tables/reader_settings.dart';
import 'tables/reading_sessions.dart';
import 'tables/series.dart';
import 'tables/series_meta.dart';
import 'tables/sources.dart';
import 'tables/sync_queue.dart';
import 'tables/thumbnails.dart';

part 'database.g.dart';

/// A pinned item joined to its display + gating fields, straight from the cache.
/// [title] is null (and so [resolved] is false) when the owner row is not cached,
/// in which case the [pinnedItems] provider drops it. [libraryId] is the owner's
/// own library, used to hide the item when that library is locked.
typedef PinnedRaw = ({
  String ownerType,
  String ownerId,
  String? title,
  String? number,
  int booksCount,
  String? libraryId,
  bool resolved,
});

/// One grouped row of the local series grid: the series display name, its sort
/// key, the number of local books in it, and the id of its first book (by
/// numberSort) whose thumbnail serves as the series cover.
typedef LocalSeriesRaw = ({
  String series,
  String seriesSort,
  int booksCount,
  String coverComicId,
});

/// A resolved home-rail snapshot row: a pointer joined to its owner (series or
/// book) for display + the owner's library id (used to hide a locked library's
/// item). [title] is null when the owner row is not cached, in which case the
/// rail provider drops it.
typedef RailSnapshotRaw = ({
  String ownerType,
  String ownerId,
  String? title,
  String? number,
  int booksCount,
  String? libraryId,
});

@DriftDatabase(tables: [
  AppSettings,
  Sources,
  Libraries,
  Series,
  Books,
  Thumbnails,
  CachedMetadata,
  Captures,
  LibraryPrefs,
  LocalComics,
  ReaderSettings,
  CachedAssets,
  DownloadTasks,
  BookState,
  ReadingSessions,
  SyncQueue,
  SeriesMeta,
  ColorSettings,
  Pins,
  HomeRailItems,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _open());

  @override
  int get schemaVersion => _kSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        // The accumulated alpha migration chain (versions 1..15) was collapsed
        // into a single baseline, so createAll builds every table and index at
        // the current shape. The baseline is anchored at [_kBaselineVersion] =
        // 16, deliberately ABOVE every version a pre-collapse build ever shipped
        // (max 15), so those burned numbers can never collide with a future
        // migration. Pre-collapse databases (user_version < 16) are not migrated
        // here: [openOrResetDatabase] discards them before drift opens the file.
        //
        // Adding migrations from now on is normal: bump [_kSchemaVersion] to 17,
        // 18, ... and add an `onUpgrade` step below. Devices already on the
        // baseline (16+) upgrade incrementally; [openOrResetDatabase] keeps
        // resetting only the pre-baseline and downgrade cases.
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          // v16 -> v17: add the page-capture gallery table. Purely additive
          // (CREATE TABLE + its index); no existing data is touched.
          // `createTable` does not create table-scoped indexes, so the
          // capturedAt index is created explicitly.
          if (from < 17) {
            await m.createTable(captures);
            await m.createIndex(idxCapturesCapturedAt);
          }
          // v17 -> v18: add the local-comics table (More Sources I, T1).
          // Purely additive. `createTable` does not create table-scoped
          // indexes, so both @TableIndex indexes are created explicitly.
          if (from < 18) {
            await m.createTable(localComics);
            await m.createIndex(idxLocalComicsSeries);
            await m.createIndex(idxLocalComicsBooks);
          }
          // v18 -> v19: remember the last-active source across restarts.
          // Purely additive nullable column on the settings row. The `to`
          // guard matters only for the per-version golden tests (which stop
          // at intermediate versions); real upgrades always target the
          // current schema version.
          if (from < 19 && to >= 19) {
            await m.addColumn(appSettings, appSettings.lastActiveSourceId);
          }
        },
      );

  /// Reads the canonical settings row (id = 1), inserting defaults exactly once
  /// and generating a stable [AppSetting.deviceId] on first read. Never
  /// clobbers a persisted row on subsequent launches. The deviceId generation
  /// is a single atomic `UPDATE ... WHERE id = 1 AND device_id IS NULL`, so two
  /// concurrent first-launch callers cannot mint two ids.
  Future<AppSetting> getOrCreateSettings() async {
    await into(appSettings).insert(
      const AppSettingsCompanion(id: Value(1)),
      mode: InsertMode.insertOrIgnore,
    );
    await (update(appSettings)
          ..where((t) => t.id.equals(1) & t.deviceId.isNull()))
        .write(AppSettingsCompanion(deviceId: Value(const Uuid().v4())));
    return (select(appSettings)..where((t) => t.id.equals(1))).getSingle();
  }

  Future<void> updateThemeMode(String mode) =>
      (update(appSettings)..where((t) => t.id.equals(1)))
          .write(AppSettingsCompanion(themeMode: Value(mode)));

  Future<void> updateReduceMotionOverride(bool v) =>
      (update(appSettings)..where((t) => t.id.equals(1)))
          .write(AppSettingsCompanion(reduceMotionOverride: Value(v)));

  Future<void> updateCacheCapBytes(int bytes) =>
      (update(appSettings)..where((t) => t.id.equals(1)))
          .write(AppSettingsCompanion(cacheCapBytes: Value(bytes)));

  Future<void> updateAutoCacheEnabled(bool v) =>
      (update(appSettings)..where((t) => t.id.equals(1)))
          .write(AppSettingsCompanion(autoCacheEnabled: Value(v)));

  Future<void> updateAutoAdvance(bool v) =>
      (update(appSettings)..where((t) => t.id.equals(1)))
          .write(AppSettingsCompanion(autoAdvance: Value(v)));

  Future<void> updateDownloadWifiOnly(bool v) =>
      (update(appSettings)..where((t) => t.id.equals(1)))
          .write(AppSettingsCompanion(downloadWifiOnly: Value(v)));

  Future<void> updateImageQualitySmart(bool v) =>
      (update(appSettings)..where((t) => t.id.equals(1)))
          .write(AppSettingsCompanion(imageQualitySmart: Value(v)));

  Future<void> updateImageQualityManualLevel(int level) =>
      (update(appSettings)..where((t) => t.id.equals(1)))
          .write(AppSettingsCompanion(imageQualityManualLevel: Value(level)));

  Future<void> updateHomeLayout(String json) =>
      (update(appSettings)..where((t) => t.id.equals(1)))
          .write(AppSettingsCompanion(homeLayout: Value(json)));

  Future<void> updateDeleteOnRead(bool v) =>
      (update(appSettings)..where((t) => t.id.equals(1)))
          .write(AppSettingsCompanion(deleteOnRead: Value(v)));

  Future<void> updateLastActiveSourceId(String id) =>
      (update(appSettings)..where((t) => t.id.equals(1)))
          .write(AppSettingsCompanion(lastActiveSourceId: Value(id)));

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

  /// Sets a series' cached book count (the number the grid shows). Used after a
  /// book-list load so sources whose series-list endpoint omits counts (Kavita)
  /// get an accurate count once the series has been browsed.
  Future<void> setSeriesBooksCount(
    String sourceId,
    String seriesId,
    int count,
  ) =>
      (update(series)
            ..where((s) => s.sourceId.equals(sourceId) & s.id.equals(seriesId)))
          .write(SeriesCompanion(booksCount: Value(count)));

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
  /// [afterTitleSort]/[afterId] is the cursor (both null = first page).
  /// [hiddenLibraryIds] (locked, not-unlocked libraries) are excluded in SQL so
  /// their content never appears in browse. Index-backed by `series_keyset`
  /// (unscoped) / `series_keyset_lib` (scoped).
  Future<List<SeriesRow>> seriesPage({
    required String sourceId,
    String? libraryId,
    String? afterTitleSort,
    String? afterId,
    required int limit,
    Set<String> hiddenLibraryIds = const {},
  }) {
    final q = select(series)..where((t) => t.sourceId.equals(sourceId));
    if (libraryId != null) {
      q.where((t) => t.libraryId.equals(libraryId));
    }
    if (hiddenLibraryIds.isNotEmpty) {
      q.where((t) => t.libraryId.isNotIn(hiddenLibraryIds.toList()));
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

  /// The full series list for [sourceId], sorted by `(titleSort, id)` (ascending
  /// unless [descending]), as a reactive stream. Optionally scoped to
  /// [libraryId]; [hiddenLibraryIds] (locked libraries) are excluded in SQL.
  /// Backs the browse grid, which renders the whole cached list (filled by the
  /// background sync) rather than keyset-paging the network.
  Stream<List<SeriesRow>> watchSeriesSorted(
    String sourceId, {
    String? libraryId,
    bool descending = false,
    Set<String> hiddenLibraryIds = const {},
  }) {
    final q = select(series)..where((t) => t.sourceId.equals(sourceId));
    if (libraryId != null) {
      q.where((t) => t.libraryId.equals(libraryId));
    }
    if (hiddenLibraryIds.isNotEmpty) {
      q.where((t) => t.libraryId.isNotIn(hiddenLibraryIds.toList()));
    }
    final mode = descending ? OrderingMode.desc : OrderingMode.asc;
    q.orderBy([
      (t) => OrderingTerm(expression: t.titleSort, mode: mode),
      (t) => OrderingTerm(expression: t.id, mode: mode),
    ]);
    return q.watch();
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

  // --- Series metadata (publisher / genres for stats) ----------------------

  Future<void> upsertSeriesMeta(SeriesMetaCompanion row) =>
      into(seriesMeta).insertOnConflictUpdate(row);

  /// Sets only the local star [rating] for a series (T3). On conflict touches
  /// ONLY `rating`; `seriesMetaToRow` never writes rating, so a later series
  /// re-sync (`upsertSeriesMeta`) leaves it intact. A null [rating] clears it.
  Future<void> setSeriesRating(String sourceId, String seriesId, int? rating) =>
      into(seriesMeta).insert(
        SeriesMetaCompanion.insert(
          sourceId: sourceId,
          seriesId: seriesId,
          rating: Value(rating),
        ),
        onConflict: DoUpdate((_) => SeriesMetaCompanion(rating: Value(rating))),
      );

  Future<SeriesMetaRow?> getSeriesMeta(String sourceId, String seriesId) =>
      (select(seriesMeta)
            ..where((t) =>
                t.sourceId.equals(sourceId) & t.seriesId.equals(seriesId)))
          .getSingleOrNull();

  Future<List<SeriesMetaRow>> allSeriesMeta() => select(seriesMeta).get();

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

  /// All cached books of a series (awaitable; the [watchBooksForSeries] stream
  /// cannot be consumed inside a transaction). Used by the series mark-read
  /// optimistic write and the series sync-queue purge (T3).
  Future<List<Book>> getBooksForSeries(String sourceId, String seriesId) =>
      (select(books)
            ..where((t) =>
                t.sourceId.equals(sourceId) & t.seriesId.equals(seriesId)))
          .get();

  /// Cached books of a series, ordered exactly like [watchBooksForSeries]
  /// (numberSort, then number) but awaitable. Backs the reader's next/prev book
  /// resolution (T4), so "next in the reader" matches "next in the series list".
  Future<List<Book>> getBooksForSeriesOrdered(String sourceId, String seriesId) =>
      (select(books)
            ..where((t) =>
                t.sourceId.equals(sourceId) & t.seriesId.equals(seriesId))
            ..orderBy([
              (t) => OrderingTerm(expression: t.numberSort),
              (t) => OrderingTerm(expression: t.number),
            ]))
          .get();

  /// Optimistically updates a cached book's read fields after a local mark
  /// read/unread (T3), so any consumer reading the Books row directly stays in
  /// step with [BookState] (the authoritative badge source).
  Future<void> setBookReadCache(
    String sourceId,
    String bookId, {
    int? readPage,
    required bool completed,
  }) =>
      (update(books)
            ..where((t) => t.sourceId.equals(sourceId) & t.id.equals(bookId)))
          .write(BooksCompanion(
            readPage: Value(readPage),
            completed: Value(completed),
          ));

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

  // --- Reader settings (per series) ----------------------------------------

  Future<ReaderSettingsRow?> getReaderSettings(
    String sourceId,
    String seriesId,
  ) =>
      (select(readerSettings)
            ..where((t) =>
                t.sourceId.equals(sourceId) & t.seriesId.equals(seriesId)))
          .getSingleOrNull();

  Future<void> upsertReaderSettings(ReaderSettingsCompanion row) =>
      into(readerSettings).insertOnConflictUpdate(row);

  // --- Color settings (global / per-series / per-book) ----------------------

  Future<ColorSettingsRow?> getColorSettings(
    String sourceId,
    String scope,
    String scopeId,
  ) =>
      (select(colorSettings)
            ..where((t) =>
                t.sourceId.equals(sourceId) &
                t.scope.equals(scope) &
                t.scopeId.equals(scopeId)))
          .getSingleOrNull();

  Future<void> upsertColorSettings(ColorSettingsCompanion row) =>
      into(colorSettings).insertOnConflictUpdate(row);

  Future<void> deleteColorSettings(
    String sourceId,
    String scope,
    String scopeId,
  ) =>
      (delete(colorSettings)
            ..where((t) =>
                t.sourceId.equals(sourceId) &
                t.scope.equals(scope) &
                t.scopeId.equals(scopeId)))
          .go();

  // --- Cached assets (offline archives) ------------------------------------

  Future<CachedAsset?> getCachedAsset(String sourceId, String bookId) =>
      (select(cachedAssets)
            ..where((t) =>
                t.sourceId.equals(sourceId) & t.bookId.equals(bookId)))
          .getSingleOrNull();

  Future<List<CachedAsset>> allCachedAssets() => select(cachedAssets).get();

  Stream<List<CachedAsset>> watchCachedAssets() => select(cachedAssets).watch();

  /// Cached assets paired with their book's title (null when the book row is
  /// missing), for the storage screen so it can show names rather than ids.
  Stream<List<({CachedAsset asset, String? title})>>
      watchCachedAssetsWithTitles() {
    final query = select(cachedAssets).join([
      leftOuterJoin(
        books,
        books.sourceId.equalsExp(cachedAssets.sourceId) &
            books.id.equalsExp(cachedAssets.bookId),
      ),
    ]);
    return query.watch().map(
          (rows) => rows
              .map((r) => (
                    asset: r.readTable(cachedAssets),
                    title: r.readTableOrNull(books)?.title,
                  ))
              .toList(),
        );
  }

  Stream<CachedAsset?> watchCachedAsset(String sourceId, String bookId) =>
      (select(cachedAssets)
            ..where((t) =>
                t.sourceId.equals(sourceId) & t.bookId.equals(bookId)))
          .watchSingleOrNull();

  Future<void> upsertCachedAsset(CachedAssetsCompanion row) =>
      into(cachedAssets).insertOnConflictUpdate(row);

  Future<void> deleteCachedAsset(String sourceId, String bookId) =>
      (delete(cachedAssets)
            ..where((t) =>
                t.sourceId.equals(sourceId) & t.bookId.equals(bookId)))
          .go();

  /// Books available offline for a source, most-recently-downloaded/opened
  /// first (the "Downloaded" home rail). Joins cached assets to their book row.
  Stream<List<Book>> watchDownloadedBooks(String sourceId) {
    final query = select(books).join([
      innerJoin(
        cachedAssets,
        cachedAssets.sourceId.equalsExp(books.sourceId) &
            cachedAssets.bookId.equalsExp(books.id),
      ),
    ])
      ..where(cachedAssets.sourceId.equals(sourceId))
      ..orderBy([OrderingTerm.desc(cachedAssets.lastAccessedAt)]);
    return query
        .watch()
        .map((rows) => rows.map((r) => r.readTable(books)).toList());
  }

  /// Books finished most recently first (the "Recently read" home rail): books
  /// with a local completed state, ordered by when they were finished. Cache-
  /// backed (local BookState), so it works offline.
  Stream<List<Book>> watchRecentlyReadBooks(String sourceId, {int limit = 20}) {
    final query = select(books).join([
      innerJoin(
        bookState,
        bookState.sourceId.equalsExp(books.sourceId) &
            bookState.bookId.equalsExp(books.id),
      ),
    ])
      ..where(bookState.sourceId.equals(sourceId) &
          bookState.status.equals('completed'))
      ..orderBy([OrderingTerm.desc(bookState.finishedAt)])
      ..limit(limit);
    return query
        .watch()
        .map((rows) => rows.map((r) => r.readTable(books)).toList());
  }

  /// Live (total books, downloaded books) for a series, for the series-detail
  /// download control. Reactive to both the books cache and cached assets.
  Stream<({int total, int downloaded, int active})> watchSeriesDownloadCounts(
    String sourceId,
    String seriesId,
  ) =>
      customSelect(
        'SELECT '
        '(SELECT COUNT(*) FROM books WHERE source_id = ?1 AND series_id = ?2) '
        'AS total, '
        '(SELECT COUNT(*) FROM cached_assets ca JOIN books b '
        'ON b.source_id = ca.source_id AND b.id = ca.book_id '
        'WHERE b.source_id = ?1 AND b.series_id = ?2) AS downloaded, '
        // In-flight tasks (queued/running/paused, not terminal): the difference
        // between "actively downloading" and "partially downloaded but idle".
        "(SELECT COUNT(*) FROM download_tasks dt JOIN books b "
        'ON b.source_id = dt.source_id AND b.id = dt.book_id '
        "WHERE b.source_id = ?1 AND b.series_id = ?2 "
        "AND dt.state NOT IN ('complete', 'failed')) AS active",
        variables: [Variable.withString(sourceId), Variable.withString(seriesId)],
        readsFrom: {books, cachedAssets, downloadTasks},
      ).watchSingle().map(
            (row) => (
              total: row.read<int>('total'),
              downloaded: row.read<int>('downloaded'),
              active: row.read<int>('active'),
            ),
          );

  Future<void> touchCachedAsset(
    String sourceId,
    String bookId,
    int atMillis,
  ) =>
      (update(cachedAssets)
            ..where((t) =>
                t.sourceId.equals(sourceId) & t.bookId.equals(bookId)))
          .write(CachedAssetsCompanion(lastAccessedAt: Value(atMillis)));

  // --- Download tasks ------------------------------------------------------

  Future<DownloadTask?> getDownloadTask(String sourceId, String bookId) =>
      (select(downloadTasks)
            ..where((t) =>
                t.sourceId.equals(sourceId) & t.bookId.equals(bookId)))
          .getSingleOrNull();

  Future<DownloadTask?> getDownloadTaskByTaskId(String taskId) =>
      (select(downloadTasks)..where((t) => t.taskId.equals(taskId)))
          .getSingleOrNull();

  Future<List<DownloadTask>> unfinishedDownloadTasks() =>
      (select(downloadTasks)..where((t) => t.state.equals('complete').not()))
          .get();

  Stream<DownloadTask?> watchDownloadTask(String sourceId, String bookId) =>
      (select(downloadTasks)
            ..where((t) =>
                t.sourceId.equals(sourceId) & t.bookId.equals(bookId)))
          .watchSingleOrNull();

  Future<void> upsertDownloadTask(DownloadTasksCompanion row) =>
      into(downloadTasks).insertOnConflictUpdate(row);

  Future<void> deleteDownloadTask(String sourceId, String bookId) =>
      (delete(downloadTasks)
            ..where((t) =>
                t.sourceId.equals(sourceId) & t.bookId.equals(bookId)))
          .go();

  // --- Book state (local read state) ---------------------------------------

  Future<BookStateRow?> getBookState(String sourceId, String bookId) =>
      (select(bookState)
            ..where((t) =>
                t.sourceId.equals(sourceId) & t.bookId.equals(bookId)))
          .getSingleOrNull();

  Future<void> upsertBookState(BookStateCompanion row) =>
      into(bookState).insertOnConflictUpdate(row);

  // --- Local comics (Local files / folder sources, T1) ----------------------

  Future<void> insertLocalComic(LocalComicsCompanion row) =>
      into(localComics).insert(row);

  Future<LocalComic?> getLocalComic(String id) =>
      (select(localComics)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Duplicate-import probe (PRD OQ3): a row on [sourceId] with the same byte
  /// size and sha256 is the same file. Returns the existing row or null.
  Future<LocalComic?> findLocalComicByHash(
    String sourceId,
    int sizeBytes,
    String contentHash,
  ) =>
      (select(localComics)
            ..where((t) =>
                t.sourceId.equals(sourceId) &
                t.sizeBytes.equals(sizeBytes) &
                t.contentHash.equals(contentHash))
            ..limit(1))
          .getSingleOrNull();

  /// The local series grid: one row per distinct series on [sourceId], ordered
  /// by sort key, with the book count and the id of the first book (by
  /// numberSort, then title) for the cover thumbnail.
  Stream<List<LocalSeriesRaw>> watchLocalSeries(String sourceId) =>
      customSelect(
        'SELECT series, series_sort, COUNT(*) AS books_count, '
        '(SELECT c2.id FROM local_comics c2 '
        'WHERE c2.source_id = ?1 AND c2.series = local_comics.series '
        'ORDER BY c2.number_sort IS NULL, c2.number_sort, c2.title LIMIT 1) '
        'AS cover_comic_id '
        'FROM local_comics WHERE source_id = ?1 '
        'GROUP BY series, series_sort ORDER BY series_sort',
        variables: [Variable.withString(sourceId)],
        readsFrom: {localComics},
      ).watch().map(
            (rows) => [
              for (final r in rows)
                (
                  series: r.read<String>('series'),
                  seriesSort: r.read<String>('series_sort'),
                  booksCount: r.read<int>('books_count'),
                  coverComicId: r.read<String>('cover_comic_id'),
                ),
            ],
          );

  /// Books of one local series, ordered like the server-source series detail
  /// (numberSort, then title), with unnumbered specials (NULL numberSort)
  /// LAST rather than SQLite's default NULL-first.
  Stream<List<LocalComic>> watchLocalBooks(String sourceId, String series) =>
      (select(localComics)
            ..where(
                (t) => t.sourceId.equals(sourceId) & t.series.equals(series))
            ..orderBy([
              (t) => OrderingTerm(expression: t.numberSort.isNull()),
              (t) => OrderingTerm(expression: t.numberSort),
              (t) => OrderingTerm(expression: t.title),
            ]))
          .watch();

  /// The device's single "Local files" source row, or null before the first
  /// import. 'local' is `SourceKind.local.name` (core/db does not import the
  /// data layer, so the name string is used directly, like 'completed' above).
  Future<Source?> localFilesSource() =>
      (select(sources)..where((t) => t.kind.equals('local')))
          .getSingleOrNull();

  /// Local keep-reading rail: comics on [sourceId] whose local [BookState] is
  /// in progress (status reading or rereading), most recently touched first.
  Stream<List<LocalComic>> watchLocalKeepReading(
    String sourceId, {
    int limit = 20,
  }) {
    final query = select(localComics).join([
      innerJoin(
        bookState,
        bookState.sourceId.equalsExp(localComics.sourceId) &
            bookState.bookId.equalsExp(localComics.id),
      ),
    ])
      ..where(bookState.sourceId.equals(sourceId) &
          bookState.status.isIn(const ['reading', 'rereading']))
      ..orderBy([OrderingTerm.desc(bookState.updatedAt)])
      ..limit(limit);
    return query
        .watch()
        .map((rows) => rows.map((r) => r.readTable(localComics)).toList());
  }

  /// Recently-imported rail: newest imports first.
  Stream<List<LocalComic>> watchRecentlyImported(
    String sourceId, {
    int limit = 20,
  }) =>
      (select(localComics)
            ..where((t) => t.sourceId.equals(sourceId))
            ..orderBy([(t) => OrderingTerm.desc(t.importedAt)])
            ..limit(limit))
          .watch();

  Future<void> deleteLocalComic(String id) =>
      (delete(localComics)..where((t) => t.id.equals(id))).go();

  Future<void> deleteThumbnail(
    String sourceId,
    String ownerType,
    String ownerId,
  ) =>
      (delete(thumbnails)
            ..where((t) =>
                t.sourceId.equals(sourceId) &
                t.ownerType.equals(ownerType) &
                t.ownerId.equals(ownerId)))
          .go();

  // --- Captures (page-capture gallery) -------------------------------------

  Future<void> insertCapture(CapturesCompanion row) =>
      into(captures).insert(row);

  /// All captures, newest first (drives the gallery grid).
  Stream<List<CaptureRow>> watchCaptures() =>
      (select(captures)..orderBy([(t) => OrderingTerm.desc(t.capturedAt)]))
          .watch();

  Future<CaptureRow?> getCapture(String id) =>
      (select(captures)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> deleteCapture(String id) =>
      (delete(captures)..where((t) => t.id.equals(id))).go();

  /// The owning library id for a cached book, or null when the book is not
  /// cached. Used to stamp a capture's `libraryId` for lock-aware filtering.
  Future<String?> bookLibraryId(String sourceId, String bookId) async {
    final row = await (select(books)
          ..where((t) => t.sourceId.equals(sourceId) & t.id.equals(bookId)))
        .getSingleOrNull();
    return row?.libraryId;
  }

  /// The display title for a cached series, or null when it is not cached. Used
  /// to stamp a capture's denormalized `seriesTitle` for gallery display.
  Future<String?> seriesTitle(String sourceId, String seriesId) async {
    final row = await (select(series)
          ..where((t) => t.sourceId.equals(sourceId) & t.id.equals(seriesId)))
        .getSingleOrNull();
    return row?.title;
  }

  Stream<BookStateRow?> watchBookState(String sourceId, String bookId) =>
      (select(bookState)
            ..where((t) =>
                t.sourceId.equals(sourceId) & t.bookId.equals(bookId)))
          .watchSingleOrNull();

  /// Whether a book reads as completed for grid badges: a local [BookState] row
  /// wins (`status == 'completed'`); otherwise the cached `Books.completed`
  /// flag (which a server refresh may overwrite). Mirrors the series-detail
  /// `isCompleted` precedence, but for a single book so any cover tile can show
  /// the "read" corner. Emits `false` when the book is not yet cached.
  Stream<bool> watchBookCompleted(String sourceId, String bookId) {
    final query = select(books).join([
      leftOuterJoin(
        bookState,
        bookState.sourceId.equalsExp(books.sourceId) &
            bookState.bookId.equalsExp(books.id),
      ),
    ])..where(books.sourceId.equals(sourceId) & books.id.equals(bookId));
    return query.watchSingleOrNull().map((row) {
      if (row == null) return false;
      final state = row.readTableOrNull(bookState);
      if (state != null) return state.status == 'completed';
      return row.readTable(books).completed;
    });
  }

  /// Komga book-state rows ordered for reconcile rotation: least-recently
  /// reconciled first (NULL [BookState.reconciledAt] = never reconciled =
  /// highest priority, since SQLite sorts NULL first in ascending order). The
  /// rotation key is a device clock, distinct from the server-clock freshness
  /// baseline, so the order is stable.
  Future<List<BookStateRow>> bookStatesForReconcile(
    Set<String> komgaSourceIds, {
    required int limit,
  }) =>
      (select(bookState)
            ..where((t) => t.sourceId.isIn(komgaSourceIds))
            ..orderBy([(t) => OrderingTerm(expression: t.reconciledAt)])
            ..limit(limit))
          .get();

  /// The [BookState] rows for every book of a series that has one (T3 series
  /// detail badges). Joined on `{sourceId, bookId} == {sourceId, id}` so books
  /// without a state row simply do not appear; the grid falls back to the
  /// cached `Books.completed` for those.
  Stream<List<BookStateRow>> watchSeriesReadStates(
    String sourceId,
    String seriesId,
  ) {
    final query = select(bookState).join([
      innerJoin(
        books,
        books.sourceId.equalsExp(bookState.sourceId) &
            books.id.equalsExp(bookState.bookId),
      ),
    ])
      ..where(books.sourceId.equals(sourceId) & books.seriesId.equals(seriesId));
    return query
        .watch()
        .map((rows) => rows.map((r) => r.readTable(bookState)).toList());
  }

  /// Sets only the local star [rating] for a book (T3). Inserts a minimal row
  /// when the book has no state yet (supplying the NOT NULL `updatedAt`), and on
  /// conflict touches ONLY `rating`, so existing progress and `updatedAt` are
  /// untouched. A null [rating] clears it.
  Future<void> setBookRating(
    String sourceId,
    String bookId,
    int? rating,
    int now,
  ) =>
      into(bookState).insert(
        BookStateCompanion.insert(
          sourceId: sourceId,
          bookId: bookId,
          rating: Value(rating),
          updatedAt: now,
        ),
        onConflict: DoUpdate((_) => BookStateCompanion(rating: Value(rating))),
      );

  /// Optimistically marks every cached book of a series read or unread (T3).
  /// Writing a [BookState] row per book both flips the series grid badges
  /// (which read state-then-cache) and seeds rows the reconciler later confirms
  /// (it only visits existing state rows). `'completed'` matches
  /// `ReadStatus.completed.name`; the badge keys on status, not the page.
  Future<void> setSeriesBooksReadStates(
    String sourceId,
    String seriesId, {
    required bool read,
    required int now,
  }) =>
      transaction(() async {
        final rows = await getBooksForSeries(sourceId, seriesId);
        for (final b in rows) {
          final page = read && b.pagesCount > 0 ? b.pagesCount - 1 : 0;
          await into(bookState).insert(
            BookStateCompanion.insert(
              sourceId: sourceId,
              bookId: b.id,
              status: Value(read ? 'completed' : null),
              currentPage: Value(page),
              isRereading: const Value(false),
              updatedAt: now,
            ),
            // Clear isRereading too: a series mark must not leave a book in the
            // impossible status=completed + isRereading=true state.
            onConflict: DoUpdate((_) => BookStateCompanion(
                  status: Value(read ? 'completed' : null),
                  currentPage: Value(page),
                  isRereading: const Value(false),
                  updatedAt: Value(now),
                )),
          );
        }
      });

  // --- Reading sessions (append-only stats log) ----------------------------

  Future<void> insertReadingSession(ReadingSessionsCompanion row) =>
      into(readingSessions).insert(row);

  /// Sessions whose start falls in the half-open epoch-ms window
  /// `[startMs, endMs)`, ordered by start.
  Future<List<ReadingSessionRow>> sessionsInRange(int startMs, int endMs) =>
      (select(readingSessions)
            ..where((t) =>
                t.startedAt.isBiggerOrEqualValue(startMs) &
                t.startedAt.isSmallerThanValue(endMs))
            ..orderBy([(t) => OrderingTerm(expression: t.startedAt)]))
          .get();

  Future<List<ReadingSessionRow>> allReadingSessions() =>
      (select(readingSessions)
            ..orderBy([(t) => OrderingTerm(expression: t.startedAt)]))
          .get();

  // --- Sync queue (Komga write-back) ---------------------------------------

  /// Replaces any queued row for `{sourceId, bookId}` (pending OR dead-lettered)
  /// with a single fresh pending row carrying the latest progress.
  Future<void> enqueueSync(SyncQueueCompanion row) => transaction(() async {
        await (delete(syncQueue)
              ..where((t) =>
                  t.sourceId.equals(row.sourceId.value) &
                  t.bookId.equals(row.bookId.value)))
            .go();
        await into(syncQueue).insert(row);
      });

  /// Pending (non-dead-lettered) rows, oldest first.
  Future<List<SyncQueueRow>> pendingSync() =>
      (select(syncQueue)
            ..where((t) => t.state.equals('pending'))
            ..orderBy([(t) => OrderingTerm(expression: t.queuedAt)]))
          .get();

  Future<void> deleteSyncRow(int id) =>
      (delete(syncQueue)..where((t) => t.id.equals(id))).go();

  /// Drops any pending per-book write-back rows for the books of [seriesId]
  /// (T3). Called before enqueueing a series read/unread op so a stale per-book
  /// progress row cannot flush afterwards and re-diverge from the series mark.
  Future<void> deletePendingSyncForSeries(
    String sourceId,
    String seriesId,
  ) async {
    final ids =
        (await getBooksForSeries(sourceId, seriesId)).map((b) => b.id).toList();
    if (ids.isEmpty) return;
    await (delete(syncQueue)
          ..where((t) => t.sourceId.equals(sourceId) & t.bookId.isIn(ids)))
        .go();
  }

  Future<void> updateSyncRow(int id, SyncQueueCompanion row) =>
      (update(syncQueue)..where((t) => t.id.equals(id))).write(row);

  // --- Pins (home curation) ------------------------------------------------

  /// Pins for a source as [PinnedRaw] rows (newest first), each left-joined to
  /// its owner (a series or a book) for display + the owner's library id (used to
  /// hide the item when that library is locked). Cache-only: an item whose owner
  /// row is not cached is reported with `resolved == false` and dropped upstream
  /// (the pin row persists and returns once the cache repopulates). Reactive to
  /// pins, series and books. Tie-break on `(ownerType, ownerId)` keeps the order
  /// deterministic when two items share a `pinnedAt`.
  Stream<List<PinnedRaw>> watchPinnedItems(String sourceId) => customSelect(
        'SELECT p.owner_type AS owner_type, p.owner_id AS owner_id, '
        's.title AS s_title, s.books_count AS s_count, s.library_id AS s_lib, '
        'b.title AS b_title, b.number AS b_number, b.library_id AS b_lib '
        'FROM pins p '
        "LEFT JOIN series s ON p.owner_type = 'series' "
        'AND s.source_id = p.source_id AND s.id = p.owner_id '
        "LEFT JOIN books b ON p.owner_type = 'book' "
        'AND b.source_id = p.source_id AND b.id = p.owner_id '
        'WHERE p.source_id = ?1 '
        'ORDER BY p.pinned_at DESC, p.owner_type, p.owner_id',
        variables: [Variable.withString(sourceId)],
        readsFrom: {pins, series, books},
      ).watch().map(
            (rows) => [
              for (final row in rows)
                if (row.read<String>('owner_type') == 'series')
                  (
                    ownerType: 'series',
                    ownerId: row.read<String>('owner_id'),
                    title: row.read<String?>('s_title'),
                    number: null,
                    booksCount: row.read<int?>('s_count') ?? 0,
                    libraryId: row.read<String?>('s_lib'),
                    resolved: row.read<String?>('s_title') != null,
                  )
                else
                  (
                    ownerType: 'book',
                    ownerId: row.read<String>('owner_id'),
                    title: row.read<String?>('b_title'),
                    number: row.read<String?>('b_number'),
                    booksCount: 0,
                    libraryId: row.read<String?>('b_lib'),
                    resolved: row.read<String?>('b_title') != null,
                  ),
            ],
          );

  /// Whether [ownerId] of [ownerType] is currently pinned on [sourceId].
  Stream<bool> watchIsPinned(
    String sourceId,
    String ownerType,
    String ownerId,
  ) =>
      (select(pins)
            ..where((t) =>
                t.sourceId.equals(sourceId) &
                t.ownerType.equals(ownerType) &
                t.ownerId.equals(ownerId)))
          .watchSingleOrNull()
          .map((row) => row != null);

  /// Pins or unpins an item. Pinning is idempotent (the PK makes a re-pin just
  /// refresh [PinRow.pinnedAt], floating it back to the front of the rail).
  Future<void> setPinned(
    String sourceId,
    String ownerType,
    String ownerId, {
    required bool pinned,
    required int now,
  }) {
    if (pinned) {
      return into(pins).insertOnConflictUpdate(
        PinsCompanion.insert(
          sourceId: sourceId,
          ownerType: ownerType,
          ownerId: ownerId,
          pinnedAt: now,
        ),
      );
    }
    return (delete(pins)
          ..where((t) =>
              t.sourceId.equals(sourceId) &
              t.ownerType.equals(ownerType) &
              t.ownerId.equals(ownerId)))
        .go();
  }

  // --- Home rail snapshots (cache-first rails) -----------------------------

  /// The saved snapshot for one rail, ordered by position, each pointer joined
  /// to its owner (series or book) for display + gating. An empty result means
  /// no snapshot exists (the rail has never loaded on this source) - the
  /// provider treats that as "cold" (show a skeleton). Follows the same
  /// LEFT-JOIN structure as [watchPinnedItems]; omits the `resolved` flag (the
  /// rail provider simply drops rows with a null title).
  Future<List<RailSnapshotRaw>> getRailSnapshot(
    String sourceId,
    String railKind,
  ) async {
    final rows = await customSelect(
      'SELECT i.owner_type AS owner_type, i.owner_id AS owner_id, '
      's.title AS s_title, s.books_count AS s_count, s.library_id AS s_lib, '
      'b.title AS b_title, b.number AS b_number, b.library_id AS b_lib '
      'FROM home_rail_items i '
      "LEFT JOIN series s ON i.owner_type = 'series' "
      'AND s.source_id = i.source_id AND s.id = i.owner_id '
      "LEFT JOIN books b ON i.owner_type = 'book' "
      'AND b.source_id = i.source_id AND b.id = i.owner_id '
      'WHERE i.source_id = ?1 AND i.rail_kind = ?2 '
      'ORDER BY i.position',
      variables: [Variable.withString(sourceId), Variable.withString(railKind)],
      readsFrom: {homeRailItems, series, books},
    ).get();
    return [
      for (final row in rows)
        if (row.read<String>('owner_type') == 'series')
          (
            ownerType: 'series',
            ownerId: row.read<String>('owner_id'),
            title: row.read<String?>('s_title'),
            number: null,
            booksCount: row.read<int?>('s_count') ?? 0,
            libraryId: row.read<String?>('s_lib'),
          )
        else
          (
            ownerType: 'book',
            ownerId: row.read<String>('owner_id'),
            title: row.read<String?>('b_title'),
            number: row.read<String?>('b_number'),
            booksCount: 0,
            libraryId: row.read<String?>('b_lib'),
          ),
    ];
  }

  /// Replaces the snapshot for one rail with [items] in order (a fresh server
  /// fetch is the source of truth). Delete-then-insert in a transaction so a
  /// reader never sees a partial snapshot.
  Future<void> replaceRailSnapshot(
    String sourceId,
    String railKind,
    List<({String ownerType, String ownerId})> items,
  ) =>
      transaction(() async {
        await (delete(homeRailItems)
              ..where((t) =>
                  t.sourceId.equals(sourceId) & t.railKind.equals(railKind)))
            .go();
        await batch((b) {
          for (var i = 0; i < items.length; i++) {
            b.insert(
              homeRailItems,
              HomeRailItemsCompanion.insert(
                sourceId: sourceId,
                railKind: railKind,
                position: i,
                ownerType: items[i].ownerType,
                ownerId: items[i].ownerId,
              ),
            );
          }
        });
      });
}

/// The version at which the collapsed single-baseline schema was introduced,
/// anchored one above the highest pre-collapse version that ever shipped (15).
/// Any on-disk database below this came from a pre-collapse build with an
/// incompatible shape and is reset rather than migrated, so the burned 1..15
/// numbers can never collide with a future migration.
const int _kBaselineVersion = 16;

/// The current schema version. Raise it (17, 18, ...) and add an `onUpgrade`
/// step in [AppDatabase.migration] for each new incremental migration. Databases
/// in `[_kBaselineVersion, _kSchemaVersion]` migrate normally; everything else is
/// reset by [openOrResetDatabase].
///
/// v17: adds the `Captures` table (page-capture gallery).
/// v18: adds the `LocalComics` table (local files / folder sources, T1).
/// v19: adds `AppSettings.lastActiveSourceId` (restore the active source).
const int _kSchemaVersion = 19;

LazyDatabase _open() => LazyDatabase(() async {
      final dir = await getApplicationSupportDirectory();
      return openOrResetDatabase(File(p.join(dir.path, 'mylarium.sqlite')));
    });

/// Opens the database at [file], first discarding any database this build cannot
/// open incrementally: a pre-collapse database (`user_version < _kBaselineVersion`),
/// one from a newer build (`user_version > _kSchemaVersion`, a downgrade drift
/// cannot perform), or an unreadable/corrupt file.
///
/// Without this, drift throws on such a file and main() silently falls back to
/// an in-memory database, so the connected source is lost on every launch and
/// the app re-prompts for credentials forever. Resetting recreates the database
/// at the baseline (a one-time reset, with credentials preserved in secure
/// storage) and keeps the source persistent from then on. Databases already in
/// the migratable range `[_kBaselineVersion, _kSchemaVersion]` are left for
/// drift's normal `onUpgrade` chain.
///
/// Exposed for testing; production callers go through [_open].
@visibleForTesting
Future<QueryExecutor> openOrResetDatabase(File file) async {
  if (await file.exists() && _isIncompatibleDatabase(file)) {
    await _deleteDatabaseFiles(file);
  }
  return NativeDatabase.createInBackground(file);
}

/// True when [file] carries a schema this build cannot open incrementally: a
/// `user_version` below the baseline (pre-collapse) or above the current schema
/// (a downgrade), or an unreadable/corrupt file (also reset, rather than
/// crashing the splash).
bool _isIncompatibleDatabase(File file) {
  try {
    final db = sqlite3.open(file.path, mode: OpenMode.readOnly);
    try {
      final v = db.userVersion;
      return v < _kBaselineVersion || v > _kSchemaVersion;
    } finally {
      db.dispose();
    }
  } catch (_) {
    return true;
  }
}

/// Removes the SQLite database and its WAL/SHM/journal sidecars so the next open
/// starts from a clean baseline.
Future<void> _deleteDatabaseFiles(File file) async {
  for (final suffix in const ['', '-wal', '-shm', '-journal']) {
    final sidecar = File('${file.path}$suffix');
    if (await sidecar.exists()) await sidecar.delete();
  }
}
