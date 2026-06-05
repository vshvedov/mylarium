import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../age_rating.dart';
import 'tables/app_settings.dart';
import 'tables/book_state.dart';
import 'tables/books.dart';
import 'tables/cached_assets.dart';
import 'tables/cached_metadata.dart';
import 'tables/color_settings.dart';
import 'tables/download_tasks.dart';
import 'tables/libraries.dart';
import 'tables/library_prefs.dart';
import 'tables/reader_settings.dart';
import 'tables/reading_sessions.dart';
import 'tables/series.dart';
import 'tables/series_meta.dart';
import 'tables/sources.dart';
import 'tables/sync_queue.dart';
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
  ReaderSettings,
  CachedAssets,
  DownloadTasks,
  BookState,
  ReadingSessions,
  SyncQueue,
  SeriesMeta,
  ColorSettings,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _open());

  @override
  int get schemaVersion => 10;

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

  Future<void> updateDownloadWifiOnly(bool v) =>
      (update(appSettings)..where((t) => t.id.equals(1)))
          .write(AppSettingsCompanion(downloadWifiOnly: Value(v)));

  Future<void> updateImageQualitySmart(bool v) =>
      (update(appSettings)..where((t) => t.id.equals(1)))
          .write(AppSettingsCompanion(imageQualitySmart: Value(v)));

  Future<void> updateImageQualityManualLevel(int level) =>
      (update(appSettings)..where((t) => t.id.equals(1)))
          .write(AppSettingsCompanion(imageQualityManualLevel: Value(level)));

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
}

LazyDatabase _open() => LazyDatabase(() async {
      final dir = await getApplicationSupportDirectory();
      final file = File(p.join(dir.path, 'mylarium.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
