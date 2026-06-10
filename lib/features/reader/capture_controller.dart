/// Outcome of a capture save attempt; the reader maps each stage's failure to
/// a distinct user-facing message (a capture vs a save failure).
enum CaptureSaveOutcome { saved, captureFailed, saveFailed }

/// Owns the page-capture state machine and the crop-then-save pipeline.
///
/// One controller lives per reader body, as plain state with no Flutter
/// dependencies: the widget wraps [start]/[cancel] in its own setState,
/// rebuilds around [save], and keeps all ScaffoldMessenger/snackbar plumbing.
/// [capturing] drives the marquee overlay (and pointer-ignore on the page
/// view); [saving] guards against a double-Save while a write is in flight.
class CaptureController {
  /// Page-capture mode: when true the capture overlay is up, chrome is hidden,
  /// and the page view ignores pointers so the overlay owns the marquee
  /// gesture.
  bool get capturing => _capturing;
  bool _capturing = false;

  /// Guards against a double-Save while a capture write is in flight.
  bool get saving => _saving;
  bool _saving = false;

  /// Enter capture mode (the widget hides its chrome alongside).
  void start() => _capturing = true;

  /// Leave capture mode without saving.
  void cancel() => _capturing = false;

  /// Runs the pipeline: [crop] renders the selection to bytes, [persist]
  /// writes the result to the gallery. Returns the outcome (which stage
  /// failed decides the message), or null when a save is already in flight
  /// (the double-Save guard). Capture mode ends with the attempt either way.
  Future<CaptureSaveOutcome?> save<T>({
    required Future<T> Function() crop,
    required Future<void> Function(T shot) persist,
  }) async {
    if (_saving) return null;
    _saving = true;
    T shot;
    try {
      shot = await crop();
    } catch (_) {
      _finish();
      return CaptureSaveOutcome.captureFailed;
    }
    try {
      await persist(shot);
    } catch (_) {
      _finish();
      return CaptureSaveOutcome.saveFailed;
    }
    _finish();
    return CaptureSaveOutcome.saved;
  }

  void _finish() {
    _capturing = false;
    _saving = false;
  }
}
