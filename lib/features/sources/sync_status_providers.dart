import 'package:drift/drift.dart' hide Column;
import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/theme/theme_controller.dart' show appDatabaseProvider;
import '../../core/db/database.dart';

part 'sync_status_providers.g.dart';

/// Live counts over one source's write-back queue: rows still waiting to flush
/// (`pending`) and dead-lettered rows (`failed`).
class SyncQueueStatus {
  const SyncQueueStatus({required this.pending, required this.failed});

  final int pending;
  final int failed;

  int get total => pending + failed;
}

/// Watches the sync queue for [sourceId] and rolls it up into a
/// [SyncQueueStatus]. The table is tiny (at most one row per book), so the
/// whole filtered set is watched and counted in Dart.
@riverpod
Stream<SyncQueueStatus> syncQueueStatus(Ref ref, String sourceId) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.syncQueue)
        ..where((t) => t.sourceId.equals(sourceId)))
      .watch()
      .map((rows) => SyncQueueStatus(
            pending: rows.where((r) => r.state == 'pending').length,
            failed: rows.where((r) => r.state == 'failed').length,
          ));
}

/// Flips [sourceId]'s dead-lettered rows back to pending so the next flush
/// retries them. Resets `attempts` too: a row dead-lettered at the transient
/// cap would otherwise re-fail on its first new transient error. Returns the
/// number of rows flipped.
Future<int> retryFailedSync(AppDatabase db, String sourceId) =>
    (db.update(db.syncQueue)
          ..where(
              (t) => t.sourceId.equals(sourceId) & t.state.equals('failed')))
        .write(const SyncQueueCompanion(
      state: Value('pending'),
      attempts: Value(0),
    ));
