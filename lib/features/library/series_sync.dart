import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/theme/theme_controller.dart' show appDatabaseProvider;
import '../../core/db/database.dart';
import '../../core/network/content_exception.dart';
import '../../data/repositories/series_repository.dart';
import '../../data/source/source_providers.dart';

part 'series_sync.g.dart';

/// Fills the ENTIRE series list for a (sourceId, libraryId) into the local
/// cache in large chunks, once. This replaces the browse grid's old per-page
/// OFFSET catch-up (which could storm into dozens of sequential network
/// round-trips when the keyset cursor outran the fill frontier). The grid
/// renders from the cache and this sync fills it in the background.
class SeriesSync {
  SeriesSync({
    required this.db,
    required this.repo,
    required this.sourceId,
    this.libraryId,
    this.syncSize = 500,
  });

  final AppDatabase db;
  final SeriesRepository repo;
  final String sourceId;
  final String? libraryId;
  final int syncSize;

  int _syncedPages = 0;
  int? _total;
  bool _done = false;
  bool _failed = false;
  bool _cancelled = false;
  Future<void>? _loop;

  /// True once the whole list is cached, or a fetch/write failed (degrade to
  /// whatever is cached). Always becomes true when the loop stops on its own, so
  /// a consumer waiting on it never spins forever.
  bool get complete => _done || _failed;

  /// Runs the fill loop exactly once (shared across callers).
  Future<void> ensureSynced() => _loop ??= _run();

  /// Stops the loop early (e.g. the owning provider was disposed/rebuilt), so a
  /// superseded fill does not keep fetching in the background.
  void cancel() => _cancelled = true;

  Future<void> _run() async {
    while (!_done && !_failed && !_cancelled) {
      try {
        _total = await repo.refresh(
          sourceId,
          page: _syncedPages,
          size: syncSize,
          libraryId: libraryId,
        );
        _syncedPages++;
        final total = _total ?? 0;
        if (_syncedPages * syncSize >= total) {
          _done = true;
        } else if (await db.seriesCount(sourceId, libraryId: libraryId) >=
            total) {
          _done = true;
        }
      } on ContentException {
        _failed = true;
      } catch (_) {
        // A DB write or deserialisation failure: degrade to whatever is cached
        // rather than leaving `complete` false (which would spin the grid
        // loader forever). Swallow so the shared future completes cleanly.
        _failed = true;
      }
    }
  }
}

/// Shared per (sourceId, libraryId) full sync; watching it kicks the
/// background fill. keepAlive so it is not torn down between rebuilds while
/// browsing.
///
/// Returns null when the [SeriesRepository] is not yet available (e.g. auth
/// still loading). The grid can await the non-null value before rendering.
@Riverpod(keepAlive: true)
Future<SeriesSync?> seriesSync(Ref ref, String sourceId, String? libraryId) async {
  final db = ref.watch(appDatabaseProvider);
  final repo = await ref.watch(seriesRepositoryProvider.future);
  if (repo == null) return null;

  final sync = SeriesSync(
    db: db,
    repo: repo,
    sourceId: sourceId,
    libraryId: libraryId,
  );
  // Stop the fill if this provider is rebuilt (e.g. auth refresh) so a
  // superseded loop does not keep fetching alongside its replacement.
  ref.onDispose(sync.cancel);
  // Kick the fill in the background; do not await so the provider resolves
  // immediately and the grid can start rendering cached rows.
  unawaited(sync.ensureSynced());
  return sync;
}
