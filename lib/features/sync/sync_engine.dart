import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';

import '../../core/db/database.dart';
import '../../data/komga/komga_api.dart';
import '../offline/offline_cache.dart';
import 'reconciler.dart';
import 'sync_models.dart';
import 'write_back_queue.dart';

/// Source-aware progress sync and the local stats event model.
///
/// Komga sources do two-way sync: a local turn updates [BookState], enqueues a
/// write-back, and attempts an immediate flush; offline turns stay queued.
/// Local sources keep progress on-device only (no queue, no PATCH).
/// Conflict resolution is furthest-page-wins and never rewinds; see
/// [resolveProgress] / [applyProgress] in sync_models.
class SyncEngine {
  SyncEngine(
    this._db,
    Future<KomgaApi?> Function(String sourceId) apiFor, {
    required this.deviceId,
    int Function()? now,
  }) : _now = now ?? (() => DateTime.now().millisecondsSinceEpoch),
       _queue = WriteBackQueue(_db, apiFor),
       _reconciler = Reconciler(_db, apiFor, deviceId: deviceId, now: now);

  final AppDatabase _db;
  final String deviceId;
  final int Function() _now;
  final WriteBackQueue _queue;
  final Reconciler _reconciler;
  final _uuid = const Uuid();

  /// Furthest-page-wins resolution (PRD name); delegates to the pure top-level
  /// [resolveProgress].
  ReadProgress resolve(ReadProgress local, ReadProgress remote) =>
      resolveProgress(local, remote);

  /// Records a 0-based [page] (and completion) for a book. Updates [BookState]
  /// monotonically, and for Komga sources enqueues + flushes the write-back.
  Future<void> recordProgress(
    String sourceId,
    String bookId,
    int page,
    bool completed,
  ) async {
    final now = _now();
    final cur = await _db.getBookState(sourceId, bookId);
    final curState = cur == null
        ? null
        : BookProgressState(
            currentPage: cur.currentPage,
            completed: cur.status == ReadStatus.completed.name,
            lastModified: cur.updatedAt,
            timesReread: cur.timesReread,
            isRereading: cur.isRereading,
          );
    final outcome = applyProgress(
      curState,
      ReadProgress(page: page, completed: completed, lastModified: now),
    );

    await _db.upsertBookState(
      BookStateCompanion(
        sourceId: Value(sourceId),
        bookId: Value(bookId),
        status: Value(outcome.status.name),
        currentPage: Value(outcome.currentPage),
        timesReread: Value(outcome.timesReread),
        isRereading: Value(outcome.isRereading),
        startedAt: Value(cur?.startedAt ?? now),
        finishedAt: outcome.newlyCompleted
            ? Value(now)
            : Value(cur?.finishedAt),
        updatedAt: Value(now),
        // Privacy: nothing is auto-shared in phase 1; visibility/shareToFeed keep
        // their private/false defaults (NSFW therefore never auto-shares).
        remoteUpdatedAt: Value(cur?.remoteUpdatedAt),
      ),
    );

    if (await _isKomga(sourceId)) {
      await _db.enqueueSync(
        SyncQueueCompanion.insert(
          sourceId: sourceId,
          bookId: bookId,
          page: outcome.currentPage,
          queuedAt: now,
          completed: Value(outcome.completed),
        ),
      );
      await _queue.flush();
    }
  }

  /// When "delete on read" is enabled, removes a just-finished chapter's
  /// auto-cached copy to reclaim space. Manual (permanent) downloads are kept:
  /// they are an explicit "keep offline" choice. Best-effort; a failure here must
  /// never block marking a chapter read.
  ///
  /// Call this only once the chapter is no longer being viewed (reader teardown,
  /// or a book-detail "Mark read"): deleting the archive while the reader still
  /// holds it open would fail in-flight page decodes.
  Future<void> maybeDeleteOnRead(String sourceId, String bookId) async {
    try {
      if ((await _db.getOrCreateSettings()).deleteOnRead != true) return;
      final asset = await _db.getCachedAsset(sourceId, bookId);
      if (asset == null || asset.permanent) return;
      await OfflineCacheManager(_db).delete(sourceId, bookId);
    } catch (_) {
      // Reclaiming space must never break completion.
    }
  }

  /// Marks a book read from the UI (T3): records completion at the last page
  /// through the monotonic [recordProgress] path (so it enqueues a `progress`
  /// write-back and flushes), and updates the Books cache for any direct reader.
  Future<void> markRead(String sourceId, String bookId, int lastPageIndex) async {
    await recordProgress(sourceId, bookId, lastPageIndex, true);
    await _db.setBookReadCache(
      sourceId,
      bookId,
      readPage: lastPageIndex + 1, // 0-based -> Komga 1-based for the cache
      completed: true,
    );
    // Marked read from a detail screen (no reader holds the archive), so it is
    // safe to reclaim the cached copy now if the setting is on.
    await maybeDeleteOnRead(sourceId, bookId);
  }

  /// Marks a book unread from the UI (T3). This is the one intentional
  /// un-complete: it resets the read position directly (bypassing the monotonic
  /// [applyProgress]) while PRESERVING timesReread / startedAt / rating /
  /// remoteUpdatedAt / reconciledAt (left absent in the companion). Keeping
  /// remoteUpdatedAt matters: the reconciler's "nothing new" early-return then
  /// holds the unread state if the DELETE has not flushed, and launch flushes
  /// the queue before reconcile. Because status is now null (not completed), a
  /// later [markRead] does not trip the re-read branch, so timesReread is not
  /// bumped. The reading-sessions log is append-only and is not rewritten.
  Future<void> markUnread(String sourceId, String bookId) async {
    final now = _now();
    await _db.upsertBookState(
      BookStateCompanion(
        sourceId: Value(sourceId),
        bookId: Value(bookId),
        status: const Value(null),
        currentPage: const Value(0),
        isRereading: const Value(false),
        finishedAt: const Value(null),
        updatedAt: Value(now),
      ),
    );
    await _db.setBookReadCache(sourceId, bookId, readPage: 0, completed: false);
    if (await _isKomga(sourceId)) {
      await _db.enqueueSync(
        SyncQueueCompanion.insert(
          sourceId: sourceId,
          bookId: bookId,
          page: 0,
          queuedAt: now,
          op: Value(SyncOp.unread.name),
        ),
      );
      await _queue.flush();
    }
  }

  /// Marks every book of a series read (T3).
  Future<void> markSeriesRead(String sourceId, String seriesId) =>
      _markSeries(sourceId, seriesId, read: true, op: SyncOp.seriesRead);

  /// Marks every book of a series unread (T3).
  Future<void> markSeriesUnread(String sourceId, String seriesId) =>
      _markSeries(sourceId, seriesId, read: false, op: SyncOp.seriesUnread);

  Future<void> _markSeries(
    String sourceId,
    String seriesId, {
    required bool read,
    required SyncOp op,
  }) async {
    final now = _now();
    // Optimistic per-book BookState rows: flips the grid badges now and seeds
    // rows the reconciler later confirms (it only visits existing state rows).
    await _db.setSeriesBooksReadStates(sourceId, seriesId, read: read, now: now);
    if (await _isKomga(sourceId)) {
      // Drop any stale per-book write-backs so they cannot flush after the
      // series op and re-diverge.
      await _db.deletePendingSyncForSeries(sourceId, seriesId);
      await _db.enqueueSync(
        SyncQueueCompanion.insert(
          sourceId: sourceId,
          bookId: seriesId, // series ops carry the seriesId in bookId
          page: 0,
          queuedAt: now,
          op: Value(op.name),
        ),
      );
      await _queue.flush();
    }
  }

  /// Appends a finished reading session (append-only stats log), stamping this
  /// device's id and the current reread index. Defaults keep it private and
  /// unshared (NSFW never auto-shares in phase 1).
  Future<void> recordSession(
    ReadingSessionSpan span, {
    required bool isCompletion,
  }) async {
    final state = await _db.getBookState(span.sourceId, span.bookId);
    await _db.insertReadingSession(
      ReadingSessionsCompanion.insert(
        id: _uuid.v4(),
        sourceId: span.sourceId,
        bookId: span.bookId,
        seriesId: span.seriesId,
        startedAt: span.startedAt,
        endedAt: span.endedAt,
        activeSeconds: span.activeSeconds,
        startPage: span.startPage,
        endPage: span.endPage,
        pagesRead: span.pagesRead,
        isCompletion: Value(isCompletion),
        rereadIndex: Value(state?.timesReread ?? 0),
        deviceId: deviceId,
      ),
    );
  }

  /// Drains the Komga write-back queue (launch / resume / online-write).
  Future<void> flushQueue() => _queue.flush();

  /// Reconciles local state with Komga on launch.
  Future<void> reconcile() => _reconciler.reconcile();

  Future<bool> _isKomga(String sourceId) async {
    final source = await _db.getSource(sourceId);
    return source?.kind == 'komga';
  }
}
