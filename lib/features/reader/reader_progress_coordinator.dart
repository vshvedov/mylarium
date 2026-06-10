import 'dart:async';

import '../sync/sync_engine.dart';
import '../sync/sync_models.dart';

/// Owns the reader's progress write-back and reading-session recording.
///
/// One coordinator lives per reader open: created in the reader body's
/// initState (capturing the app-lifetime [SyncEngine] future so the teardown
/// write never touches `ref` after the element is disposed) and flushed +
/// disposed in its dispose, so its lifetime matches a single reading of one
/// book. It owns the per-turn progress debounce, the session recorder, the
/// periodic in-flight checkpoint, and the lifecycle pause/resume bookkeeping;
/// the widget only reports page changes and lifecycle transitions.
class ReaderProgressCoordinator {
  ReaderProgressCoordinator({
    required this.syncEngine,
    required this.sourceId,
    required this.bookId,
    required this.seriesId,
    required this.preview,
    required this.isLastPage,
    int Function()? nowMs,
  })  : _nowMs = nowMs ?? _wallClockMs {
    // Checkpoint the in-flight session every minute (see [checkpoint] for the
    // hard-kill rationale). Preview records no sessions, so no timer.
    if (!preview) {
      _checkpointTimer = Timer.periodic(
        const Duration(seconds: 60),
        (_) => checkpoint(),
      );
    }
  }

  static int _wallClockMs() => DateTime.now().millisecondsSinceEpoch;

  /// The app-lifetime engine future, captured once by the screen so writes
  /// survive the reader's teardown.
  final Future<SyncEngine> syncEngine;
  final String sourceId;
  final String bookId;
  final String seriesId;

  /// "Preview" mode: read the book without reporting any progress to the
  /// source (Komga never sees it as currently-reading) or recording a reading
  /// session.
  final bool preview;

  /// Whether a page index is at the end of the book in the reader's current
  /// mode (mode-aware: any page of the final double-page spread counts).
  final bool Function(int page) isLastPage;

  final int Function() _nowMs;

  /// Reading-time + page-span accumulator for the current session. Lives on
  /// the coordinator (a stable per-open lifetime) so orientation rebuilds do
  /// not reset it.
  final _recorder = ReadingSessionRecorder();

  /// Debounces per-turn progress write-back (BookState + Komga queue).
  Timer? _debounce;

  /// Periodic in-flight session checkpoint. A hard process kill (OOM, crash,
  /// task-switcher swipe-kill) never runs dispose or the lifecycle pause
  /// path, so without this the whole in-flight reading session would be lost;
  /// checkpointing every minute bounds the stats loss to at most one interval.
  /// Never started in preview mode.
  Timer? _checkpointTimer;

  /// The page most recently reported through [onPage] / [resume]: what the
  /// checkpoint and pause paths record when they fire between page turns.
  int _page = 0;

  /// Records a page change: feeds the session recorder and schedules a
  /// debounced progress write-back. The last page flushes immediately (marks
  /// completion).
  void onPage(int page) {
    _page = page;
    _recorder.onPage(page, _nowMs());
    _debounce?.cancel();
    if (isLastPage(page)) {
      _pushProgress(page, completed: true);
    } else {
      _debounce = Timer(
        const Duration(seconds: 2),
        () => _pushProgress(page, completed: false),
      );
    }
  }

  /// App backgrounded: flush time, push the final position, and checkpoint
  /// the session so a background-kill does not lose it.
  void pause() {
    _recorder.pause(_nowMs());
    _debounce?.cancel();
    _pushProgress(_page, completed: isLastPage(_page));
    _finalizeSession();
  }

  /// Starts a fresh session segment at [page]: the opening page on reader
  /// open, or the current page when the app returns to the foreground.
  void resume(int page) {
    _page = page;
    _recorder.onPage(page, _nowMs());
  }

  /// Periodic checkpoint of the in-flight reading session. Mirrors the
  /// paused -> resumed lifecycle sequence (flush time, append, restart at the
  /// current page) but deliberately does NOT push progress (that has its own
  /// debounce). [_finalizeSession] is naturally a no-op when the recorder has
  /// nothing measurable (its build() returns null).
  void checkpoint() {
    if (preview) return;
    _recorder.pause(_nowMs());
    _finalizeSession();
    _recorder.onPage(_page, _nowMs());
  }

  /// Teardown write, for the reader's dispose: cancels the timers, pushes the
  /// final position (durable) and appends the session (best-effort; the
  /// SyncEngine + database are app-lifetime, so the write survives the
  /// reader's teardown).
  void flush({required int page}) {
    _page = page;
    _debounce?.cancel();
    _checkpointTimer?.cancel();
    _pushProgress(page, completed: isLastPage(page));
    _finalizeSession();
  }

  /// Cancels the debounce and checkpoint timers. Safe (and a no-op) after
  /// [flush], which already cancelled both.
  void dispose() {
    _debounce?.cancel();
    _checkpointTimer?.cancel();
  }

  void _pushProgress(int page, {required bool completed}) {
    // Preview mode is a non-committal peek: never report progress (local or to
    // the source), so the book is not marked currently-reading anywhere.
    if (preview) return;
    syncEngine
        .then((e) => e.recordProgress(sourceId, bookId, page, completed))
        .catchError((Object _) {});
  }

  /// Appends the current reading session (if it has measurable activity) and
  /// resets the recorder so a later checkpoint or dispose does not double-emit.
  void _finalizeSession() {
    // Preview mode records no reading session (no stats, no completion).
    if (preview) return;
    final span = _recorder.build(
      sourceId: sourceId,
      bookId: bookId,
      seriesId: seriesId,
    );
    _recorder.reset();
    if (span == null) return;
    final isCompletion = isLastPage(span.endPage);
    syncEngine
        .then((e) => e.recordSession(span, isCompletion: isCompletion))
        .catchError((Object _) {});
  }
}
