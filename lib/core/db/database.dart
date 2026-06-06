import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'tables/app_settings.dart';
import 'tables/book_state.dart';
import 'tables/books.dart';
import 'tables/cached_assets.dart';
import 'tables/cached_metadata.dart';
import 'tables/color_settings.dart';
import 'tables/download_tasks.dart';
import 'tables/libraries.dart';
import 'tables/library_prefs.dart';
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

@DriftDatabase(tables: [
  AppSettings,
  Sources,
  Libraries,
  Series,
  Books,
  Thumbnails,
  CachedMetadata,
  LibraryPrefs,
  ReaderSettings,
  CachedAssets,
  DownloadTasks,
  BookState,
  ReadingSessions,
  SyncQueue,
  SeriesMeta,
  ColorSettings,
  Pins,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _open());

  @override
  int get schemaVersion => 14;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        // A fresh install at the current version: createAll covers every table
        // plus the generated indexes.
        onCreate: (m) => m.createAll(),
        // Each bump is additive. v1 data is never touched (no data loss across
        // an app update).
        onUpgrade: (m, from, to) async {
          // Each step is bounded by both `from` and `to` so migrating to an
          // intermediate version (used by the golden migration tests) applies
          // exactly the steps for versions in (from, to].
          // v1 -> v2: source + metadata tables.
          if (from < 2 && to >= 2) {
            await m.createTable(sources);
            await m.createTable(libraries);
            await m.createTable(series);
            await m.createTable(books);
          }
          // v2 -> v3: thumbnail/metadata caches, per-library prefs, and the
          // series keyset indexes that back the virtualized grids.
          if (from < 3 && to >= 3) {
            await m.createTable(thumbnails);
            await m.createTable(cachedMetadata);
            await m.createTable(libraryPrefs);
            await m.createIndex(seriesKeyset);
            await m.createIndex(seriesKeysetLib);
          }
          // v3 -> v4: per-series reader settings.
          if (from < 4 && to >= 4) {
            await m.createTable(readerSettings);
          }
          // v4 -> v5: offline cache (downloaded archives) + download queue.
          if (from < 5 && to >= 5) {
            await m.createTable(cachedAssets);
            await m.createTable(downloadTasks);
            await m.createIndex(cachedAssetsLru);
          }
          // v5 -> v6: auto-cache settings (toggle + Wi-Fi-only) and a manual
          // vs auto flag on download tasks (so resume picks the right pool).
          if (from < 6 && to >= 6) {
            await m.addColumn(appSettings, appSettings.autoCacheEnabled);
            await m.addColumn(appSettings, appSettings.downloadWifiOnly);
            // download_tasks was introduced in v5 without `permanent`; only a
            // real v5 install lacks it. Upgrades from < 5 already create the
            // table with the current (v6) shape via createTable above, so
            // adding it again would duplicate the column.
            if (from == 5) {
              await m.addColumn(downloadTasks, downloadTasks.permanent);
            }
          }
          // v6 -> v7: progress sync + reading stats. New tables (book state,
          // append-only sessions, write-back queue, series metadata) plus a
          // per-install deviceId. app_settings exists from v1 on every path
          // reaching v7, so its addColumn is unconditional within this guard.
          // Series publisher/genres live in a side table (series_meta) rather
          // than as new series columns, so the historical v1 -> v2
          // createTable(series) keeps emitting the v2 shape (see SeriesMeta).
          if (from < 7 && to >= 7) {
            await m.createTable(bookState);
            await m.createTable(readingSessions);
            await m.createTable(syncQueue);
            await m.createIndex(syncQueueBook);
            await m.createTable(seriesMeta);
            await m.addColumn(appSettings, appSettings.deviceId);
          }
          // v7 -> v8: reader image-quality preference (Smart toggle + manual
          // stop). app_settings exists on every path reaching v8, so the
          // addColumns are unconditional within this guard.
          if (from < 8 && to >= 8) {
            await m.addColumn(appSettings, appSettings.imageQualitySmart);
            await m.addColumn(appSettings, appSettings.imageQualityManualLevel);
          }
          // v8 -> v9: reader page color-correction settings (global / per-series
          // / per-book). A new table, so additive createTable only.
          if (from < 9 && to >= 9) {
            await m.createTable(colorSettings);
          }
          // v9 -> v10: deeper Komga integration (T3). A write-back `op` kind on
          // the sync queue (mark read/unread, series read/unread) and a local
          // series rating mirror. Both syncQueue and seriesMeta are created in
          // the from<7 block, where createTable already emits the current (v10)
          // shape including these columns; only a real v7/v8/v9 install has the
          // tables WITHOUT them, so the addColumns are guarded on from >= 7.
          if (from < 10 && to >= 10) {
            if (from >= 7) {
              await m.addColumn(syncQueue, syncQueue.op);
              await m.addColumn(seriesMeta, seriesMeta.rating);
            }
          }
          // v10 -> v11: per-series reading direction (T4), the source of truth for
          // double-page RTL. Idempotent: a half-applied upgrade (the column added
          // but the version bump not committed, e.g. the process was killed
          // mid-migration) must not re-add `direction` (which would throw
          // "duplicate column"), and the from<4 createTable path already emits it.
          // So guard the addColumn on the column actually being absent rather than
          // on `from`. The backfill is naturally idempotent (a no-op on a fresh,
          // empty table) and keeps a series that read pagedRtl in RTL when it later
          // switches to double-page.
          if (from < 11 && to >= 11) {
            if (!await _hasColumn('reader_settings', 'direction')) {
              await m.addColumn(readerSettings, readerSettings.direction);
            }
            await customStatement(
              "UPDATE reader_settings SET direction = 'rtl' "
              "WHERE mode = 'pagedRtl'",
            );
          }
          // v11 -> v12: user-curated home pins (series/chapter). A brand-new
          // table, so a plain additive createTable (no idempotency guard: unlike
          // an addColumn, a half-applied createTable cannot leave a partial
          // column, and the from<12 path never created it earlier).
          if (from < 12 && to >= 12) {
            await m.createTable(pins);
          }
          // v12 -> v13: persisted home-screen row layout (order + visibility), a
          // single nullable JSON column on the settings row. Additive.
          if (from < 13 && to >= 13) {
            await m.addColumn(appSettings, appSettings.homeLayout);
          }
          // v13 -> v14: "delete downloaded chapter on read" toggle. Additive.
          if (from < 14 && to >= 14) {
            await m.addColumn(appSettings, appSettings.deleteOnRead);
          }
        },
      );

  /// Whether [table] currently has a column named [column]. Used to keep
  /// additive migrations idempotent so a half-applied upgrade (e.g. the process
  /// was killed mid-migration, leaving the column present but the version not
  /// bumped) can re-run without an "duplicate column" error.
  Future<bool> _hasColumn(String table, String column) async {
    final rows = await customSelect('PRAGMA table_info($table)').get();
    return rows.any((r) => r.data['name'] == column);
  }

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

  Stream<BookStateRow?> watchBookState(String sourceId, String bookId) =>
      (select(bookState)
            ..where((t) =>
                t.sourceId.equals(sourceId) & t.bookId.equals(bookId)))
          .watchSingleOrNull();

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
}

LazyDatabase _open() => LazyDatabase(() async {
      final dir = await getApplicationSupportDirectory();
      final file = File(p.join(dir.path, 'mylarium.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
