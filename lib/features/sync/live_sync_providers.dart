import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/source/models/live_event.dart';
import '../../data/source/source_providers.dart';
import '../library/library_browse_controllers.dart';
import 'live_sync_controller.dart';
import 'sync_providers.dart';

part 'live_sync_providers.g.dart';

/// Owns the app's live-event subscription (T1). `state` is the session-expired
/// flag: false while healthy, true once the server session expires, so the UI
/// can show a non-blocking re-auth affordance. The actual reconnect/backoff and
/// event routing live in [LiveSyncController]; this provider binds it to the
/// active source, routes read-progress through the reconciler, invalidates the
/// API-backed home rails on change, and is driven by the app lifecycle (started
/// on foreground, stopped on background) from the root observer.
@Riverpod(keepAlive: true)
class LiveSync extends _$LiveSync {
  LiveSyncController? _controller;
  String? _sourceId;

  @override
  bool build() {
    ref.onDispose(() => _controller?.stop());
    return false;
  }

  /// Connects the live stream for the active source. Idempotent for a given
  /// source; switching sources tears down the old stream first. A no-op when no
  /// source is active or the session has already expired (avoids hammering a
  /// server that just rejected us; cleared by [reset] after re-auth).
  Future<void> start() async {
    if (state) return; // session expired: wait for an explicit reset
    final sourceId = await ref.read(activeSourceIdProvider.future);
    if (sourceId == null || sourceId.isEmpty) return;
    if (_controller != null && _sourceId == sourceId) return;

    final api = await ref.read(contentApiForProvider(sourceId).future);
    if (api == null) return;
    final engine = await ref.read(syncEngineProvider.future);

    await _controller?.stop();
    _sourceId = sourceId;
    _controller = LiveSyncController(
      connect: api.liveEvents,
      onReadProgress: (bookId) => engine.reconcileBook(sourceId, bookId),
      onInvalidate: (event) => _invalidate(sourceId, event),
      onSessionExpired: () => state = true,
    )..start();
  }

  /// Tears the live stream down (app backgrounded / teardown).
  Future<void> stop() async {
    await _controller?.stop();
    _controller = null;
    _sourceId = null;
  }

  /// Clears the session-expired flag (call after the user re-authenticates) so
  /// [start] can reconnect.
  Future<void> reset() async {
    state = false;
    await stop();
  }

  /// Refreshes the API-backed home rails for [sourceId] so a server-side change
  /// (progress elsewhere, a new/changed book or series, a new thumbnail) shows
  /// without a relaunch. Read-progress also updates `BookState` via the
  /// reconciler, which auto-refreshes the DB-watched detail surfaces.
  void _invalidate(String sourceId, LiveEvent event) {
    switch (event) {
      case ReadProgressChanged() ||
            ReadProgressDeleted() ||
            ReadProgressSeriesChanged() ||
            BookChanged() ||
            SeriesChanged() ||
            ThumbnailChanged():
        ref.invalidate(keepReadingProvider(sourceId));
        ref.invalidate(recentlyAddedBooksProvider(sourceId));
        ref.invalidate(recentlyAddedSeriesProvider(sourceId));
        ref.invalidate(recentlyUpdatedSeriesProvider(sourceId));
      case LibraryChanged() || SessionExpired() || UnknownEvent():
        break;
    }
  }
}
