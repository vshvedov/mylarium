/// Pure sync domain types and logic. No Flutter, no Drift, no Dio imports here
/// so this file is trivially unit-testable in isolation (the conflict and
/// recorder tests import only this).
///
/// Page coordinate system: every value in this file is 0-based (reader-native,
/// matching the reader's `_page`). The Komga boundary (1-based) is converted
/// exactly once in the sync engine; nothing here ever sees a 1-based page.
library;

import 'dart:math' as math;

/// A book's read position at a point in time. [lastModified] is epoch ms; for a
/// local edit it is the device clock, for a remote it is the parsed Komga
/// `readProgress.lastModified`. The two clock domains are never compared to
/// decide a page (page is always resolved by furthest-page-wins), only carried.
class ReadProgress {
  const ReadProgress({
    required this.page,
    required this.completed,
    required this.lastModified,
  });

  /// 0-based page index.
  final int page;
  final bool completed;

  /// Epoch milliseconds.
  final int lastModified;

  @override
  bool operator ==(Object other) =>
      other is ReadProgress &&
      other.page == page &&
      other.completed == completed &&
      other.lastModified == lastModified;

  @override
  int get hashCode => Object.hash(page, completed, lastModified);

  @override
  String toString() =>
      'ReadProgress(page: $page, completed: $completed, lastModified: $lastModified)';
}

/// Furthest-page-wins conflict resolution (PRD T6). Fully monotonic:
/// - page is the maximum of the two (never rewinds),
/// - completion is sticky (once completed, stays completed),
/// - the later [lastModified] is kept (the PRD "tiebreak": in the equal-page
///   case the more recent metadata and the OR of completion are retained; the
///   page itself is never decided by a timestamp, so a server-side progress
///   reset is intentionally not honored as a rewind).
///
/// An intentional restart (a re-read) is NOT handled here; it is detected one
/// level up in [applyProgress], which may deliberately lower the page.
ReadProgress resolveProgress(ReadProgress local, ReadProgress remote) =>
    ReadProgress(
      page: math.max(local.page, remote.page),
      completed: local.completed || remote.completed,
      lastModified: math.max(local.lastModified, remote.lastModified),
    );

/// Lifecycle status of a book for the local stats/state model.
enum ReadStatus { reading, completed, dropped, planToRead, paused, rereading }

/// Where a recorded progress event is allowed to sync. Komga sources write back
/// (PATCH + queue); local sources keep progress on-device only.
enum SyncTarget { komga, localOnly }

/// The kind of Komga write-back a queued row represents (T3). Stored by [name]
/// in `SyncQueue.op`; `progress` is the column default so every pre-T3 row reads
/// back as a read-progress PATCH. `unread` deletes a book's read-progress;
/// `seriesRead` / `seriesUnread` PATCH / DELETE a whole series' read-progress
/// (the seriesId rides in the row's bookId column).
enum SyncOp { progress, unread, seriesRead, seriesUnread }

/// The current local state of a book, as far as [applyProgress] needs it. A
/// minimal projection of the persisted `BookState` row (no Drift dependency).
class BookProgressState {
  const BookProgressState({
    required this.currentPage,
    required this.completed,
    required this.lastModified,
    required this.timesReread,
    required this.isRereading,
  });

  final int currentPage;
  final bool completed;
  final int lastModified;
  final int timesReread;
  final bool isRereading;

  ReadProgress get progress => ReadProgress(
    page: currentPage,
    completed: completed,
    lastModified: lastModified,
  );
}

/// The outcome of applying an [incoming] progress event to the current state.
/// Carries the new persisted fields plus whether this event started a re-read
/// pass (so the caller can stamp a fresh `rereadIndex`).
class ProgressOutcome {
  const ProgressOutcome({
    required this.currentPage,
    required this.completed,
    required this.status,
    required this.timesReread,
    required this.isRereading,
    required this.lastModified,
    required this.startedReread,
    required this.newlyCompleted,
  });

  final int currentPage;
  final bool completed;
  final ReadStatus status;
  final int timesReread;
  final bool isRereading;
  final int lastModified;

  /// True iff this event opened a new re-read pass (an intentional rewind).
  final bool startedReread;

  /// True iff this event transitioned the book from not-completed to completed.
  final bool newlyCompleted;
}

/// Applies an [incoming] read position to the prior [cur] state.
///
/// Re-read detection (the only path allowed to lower the page): when the book
/// was completed and the incoming page is below the current page and a re-read
/// is not already in progress, this is an intentional restart. We bump
/// `timesReread`, flag `isRereading`, and adopt the lower incoming page. Every
/// other case is monotonic via [resolveProgress] and never rewinds.
ProgressOutcome applyProgress(BookProgressState? cur, ReadProgress incoming) {
  if (cur != null &&
      cur.completed &&
      !cur.isRereading &&
      incoming.page < cur.currentPage) {
    return ProgressOutcome(
      currentPage: incoming.page,
      completed: false,
      status: ReadStatus.rereading,
      timesReread: cur.timesReread + 1,
      isRereading: true,
      lastModified: incoming.lastModified,
      startedReread: true,
      newlyCompleted: false,
    );
  }

  final resolved = cur == null
      ? incoming
      : resolveProgress(cur.progress, incoming);
  final wasCompleted = cur?.completed ?? false;
  final newlyCompleted = resolved.completed && !wasCompleted;
  final isRereading = (cur?.isRereading ?? false) && !resolved.completed;
  final status = resolved.completed
      ? ReadStatus.completed
      : (isRereading ? ReadStatus.rereading : ReadStatus.reading);
  return ProgressOutcome(
    currentPage: resolved.page,
    completed: resolved.completed,
    status: status,
    timesReread: cur?.timesReread ?? 0,
    isRereading: isRereading,
    lastModified: resolved.lastModified,
    startedReread: false,
    newlyCompleted: newlyCompleted,
  );
}

/// The page span and timing of one finished reading session, as measured by the
/// reader. The engine stamps the device id and reread index and applies the
/// private-by-default visibility before appending it to the log.
class ReadingSessionSpan {
  const ReadingSessionSpan({
    required this.sourceId,
    required this.bookId,
    required this.seriesId,
    required this.startedAt,
    required this.endedAt,
    required this.activeSeconds,
    required this.startPage,
    required this.endPage,
    required this.pagesRead,
  });

  final String sourceId;
  final String bookId;
  final String seriesId;
  final int startedAt;
  final int endedAt;
  final int activeSeconds;
  final int startPage;
  final int endPage;
  final int pagesRead;
}

/// The deviceId stamped on a session synthesized for an off-device (server)
/// read during reconciliation. Reserved; a uuid v4 will never collide with it.
const String kRemoteDeviceId = 'remote';

/// Inter-event reading time above this gap (ms) is treated as idle and capped,
/// so a book left open does not inflate "time read". 5 minutes.
const int kIdleCapMs = 5 * 60 * 1000;

/// Accumulates active reading time and page span for one reading session.
///
/// Pure and clock-injected: callers pass `nowMs`, so tests drive it
/// deterministically. Owned by the reader screen's State (a stable lifetime),
/// not by a rebuilding provider. Active time is the sum of inter-page-turn
/// gaps, each clamped to [kIdleCapMs]; background stretches are excluded via
/// [pause]/[resume].
class ReadingSessionRecorder {
  int? _startedAt;
  int _lastTs = 0;
  int _endedAt = 0;
  int _startPage = 0;
  int _endPage = 0;
  int _maxPage = 0;
  int _activeMs = 0;
  bool _paused = false;

  /// True once at least one page event has been seen since the last [reset].
  bool get hasEvents => _startedAt != null;

  /// Records that the reader is now showing [page] at [nowMs]. The first call
  /// of a segment seeds the start; later calls accumulate capped active time.
  void onPage(int page, int nowMs) {
    if (_startedAt == null) {
      _startedAt = nowMs;
      _lastTs = nowMs;
      _endedAt = nowMs;
      _startPage = page;
      _endPage = page;
      _maxPage = page;
      _activeMs = 0;
      _paused = false;
      return;
    }
    if (_paused) {
      _lastTs = nowMs;
      _paused = false;
    } else {
      _activeMs += math.min(nowMs - _lastTs, kIdleCapMs);
      _lastTs = nowMs;
    }
    _endedAt = nowMs;
    _endPage = page;
    _maxPage = math.max(_maxPage, page);
  }

  /// Flushes the in-flight gap and freezes the clock (app backgrounded). The
  /// next [onPage] or [resume] starts a fresh gap with no double counting.
  void pause(int nowMs) {
    if (_startedAt == null || _paused) return;
    _activeMs += math.min(nowMs - _lastTs, kIdleCapMs);
    _endedAt = nowMs;
    _paused = true;
  }

  /// Resumes timing from [nowMs] without accumulating the paused stretch.
  void resume(int nowMs) {
    _lastTs = nowMs;
    _paused = false;
  }

  /// Builds the session span for the events seen so far, or null when nothing
  /// reportable happened (no page events, or zero active time and zero pages).
  ReadingSessionSpan? build({
    required String sourceId,
    required String bookId,
    required String seriesId,
  }) {
    if (_startedAt == null) return null;
    final pagesRead = math.max(0, _maxPage - _startPage);
    final activeSeconds = (_activeMs / 1000).round();
    if (activeSeconds <= 0 && pagesRead <= 0) return null;
    return ReadingSessionSpan(
      sourceId: sourceId,
      bookId: bookId,
      seriesId: seriesId,
      startedAt: _startedAt!,
      endedAt: _endedAt,
      activeSeconds: activeSeconds,
      startPage: _startPage,
      endPage: _endPage,
      pagesRead: pagesRead,
    );
  }

  /// Clears all accumulated state so a fresh segment can begin (used after a
  /// pause-time checkpoint append, so a later dispose does not double-emit).
  void reset() {
    _startedAt = null;
    _lastTs = 0;
    _endedAt = 0;
    _startPage = 0;
    _endPage = 0;
    _maxPage = 0;
    _activeMs = 0;
    _paused = false;
  }
}
