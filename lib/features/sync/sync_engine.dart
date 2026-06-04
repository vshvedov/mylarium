import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';

import '../../core/db/database.dart';
import '../../data/komga/komga_api.dart';
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
