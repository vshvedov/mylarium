// Public param names intentionally differ from the private fields they back.
// ignore_for_file: prefer_initializing_formals
import 'dart:async';
import 'dart:math';

import '../../core/network/content_exception.dart';
import '../../data/source/models/live_event.dart';

/// Owns one live-event subscription and keeps it healthy (T1). Transport- and
/// Riverpod-agnostic: it is handed closures to open a fresh stream, to apply a
/// read-progress event, to invalidate UI for other events, and to signal
/// session expiry, so the reconnect/backoff and routing logic is unit-testable
/// without a network.
///
/// Lifecycle: [start] runs a connect loop; a dropped stream reconnects with
/// capped exponential backoff and jitter; a session-expiry event (or a 401 on
/// connect) stops the loop and fires [onSessionExpired] so the UI can surface a
/// non-blocking re-auth affordance instead of hammering the server. [stop]
/// cancels the active subscription and ends the loop.
class LiveSyncController {
  LiveSyncController({
    required Stream<LiveEvent> Function() connect,
    required Future<void> Function(String bookId) onReadProgress,
    required void Function(LiveEvent event) onInvalidate,
    required void Function() onSessionExpired,
    Future<void> Function(Duration)? delay,
    double Function()? random,
    this.baseBackoff = const Duration(seconds: 1),
    this.maxBackoff = const Duration(seconds: 60),
  })  : _connect = connect,
        _onReadProgress = onReadProgress,
        _onInvalidate = onInvalidate,
        _onSessionExpired = onSessionExpired,
        _delay = delay ?? Future<void>.delayed,
        _random = random ?? Random().nextDouble;

  final Stream<LiveEvent> Function() _connect;
  final Future<void> Function(String bookId) _onReadProgress;
  final void Function(LiveEvent event) _onInvalidate;
  final void Function() _onSessionExpired;
  final Future<void> Function(Duration) _delay;
  final double Function() _random;
  final Duration baseBackoff;
  final Duration maxBackoff;

  bool _running = false;
  bool _sessionExpired = false;
  StreamSubscription<LiveEvent>? _sub;
  Completer<void>? _connection;

  bool get isSessionExpired => _sessionExpired;

  /// Begins the connect loop (idempotent: a second call while running is a
  /// no-op). Does not throw; connect/stream errors drive reconnect.
  void start() {
    if (_running || _sessionExpired) return;
    _running = true;
    unawaited(_run());
  }

  /// Cancels the active subscription and ends the loop. Safe to call repeatedly.
  Future<void> stop() async {
    _running = false;
    final sub = _sub;
    _sub = null;
    await sub?.cancel();
    final conn = _connection;
    if (conn != null && !conn.isCompleted) conn.complete();
  }

  Future<void> _run() async {
    var attempt = 0;
    while (_running && !_sessionExpired) {
      final connection = _connection = Completer<void>();
      final sub = _sub = _connect().listen(
        (event) {
          attempt = 0; // a delivered event proves the connection is healthy
          _handle(event);
          if ((_sessionExpired || !_running) && !connection.isCompleted) {
            connection.complete();
          }
        },
        onError: (Object e) {
          // A 401/expired session on connect: stop, do not reconnect.
          if (e is ContentException &&
              e.kind == ContentErrorKind.unauthorized) {
            _expire();
          }
          if (!connection.isCompleted) connection.complete();
        },
        onDone: () {
          if (!connection.isCompleted) connection.complete();
        },
        cancelOnError: true,
      );
      await connection.future;
      await sub.cancel();
      if (_sub == sub) _sub = null;
      if (!_running || _sessionExpired) break;
      attempt++;
      await _delay(_backoffFor(attempt));
    }
    _running = false;
  }

  void _handle(LiveEvent event) {
    switch (event) {
      case ReadProgressChanged(:final bookId) ||
            ReadProgressDeleted(:final bookId):
        // Best-effort: a connectivity error here is swallowed; the stream-level
        // reconnect (or the next launch reconcile) covers the gap.
        unawaited(_onReadProgress(bookId).catchError((Object _) {}));
      case SessionExpired():
        _expire();
      default:
        _onInvalidate(event);
    }
  }

  void _expire() {
    if (_sessionExpired) return;
    _sessionExpired = true;
    _running = false;
    _onSessionExpired();
  }

  /// Capped exponential backoff with full-ish jitter: the nth reconnect waits a
  /// random span in [cap/2, cap] where cap = min(maxBackoff, base * 2^(n-1)).
  /// Jitter avoids a thundering-herd reconnect when a server restarts.
  Duration _backoffFor(int attempt) {
    final capMs = min(
      maxBackoff.inMilliseconds,
      baseBackoff.inMilliseconds * (1 << (attempt - 1).clamp(0, 30)),
    );
    final jittered = capMs * (0.5 + 0.5 * _random());
    return Duration(milliseconds: jittered.round());
  }
}
