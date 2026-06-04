import 'package:drift/drift.dart' show Value;

import '../../core/db/database.dart';
import '../../core/network/komga_exception.dart';
import '../../data/komga/komga_api.dart';

/// Maximum transient failures before a queued write-back is dead-lettered.
const int kMaxSyncAttempts = 20;

/// Drains the Komga read-progress write-back queue. Each pending row is a
/// 0-based local page; the Komga API is 1-based, so we PATCH `page + 1`.
///
/// Error policy:
/// - transient (server unreachable / TLS / 401 / 408 / 429 / 5xx): bump
///   `attempts` and stop draining THAT source (no point hammering a down or
///   unauthorized server), but keep draining other sources; a row exceeding
///   [kMaxSyncAttempts] is dead-lettered.
/// - permanent (other 4xx, e.g. 400/403/404): dead-letter the row immediately
///   and continue draining the rest.
/// - source gone / no credential (apiFor returns null): drop the row.
class WriteBackQueue {
  WriteBackQueue(this._db, this._apiFor);

  final AppDatabase _db;
  final Future<KomgaApi?> Function(String sourceId) _apiFor;

  Future<void> flush() async {
    final rows = await _db.pendingSync();
    final apis = <String, KomgaApi?>{};
    // Sources that hit a transient error this pass: skip their remaining rows so
    // one down/unauthorized server cannot stall write-back for the others.
    final stalled = <String>{};
    for (final row in rows) {
      if (stalled.contains(row.sourceId)) continue;
      final api = apis[row.sourceId] ??= await _apiFor(row.sourceId);
      if (api == null) {
        // The source was deleted or lost its credential; nothing to push to.
        await _db.deleteSyncRow(row.id);
        continue;
      }
      try {
        await api.patchReadProgress(
          row.bookId,
          page: row.page + 1, // 0-based local -> 1-based Komga
          completed: row.completed,
        );
        await _db.deleteSyncRow(row.id);
      } on KomgaException catch (e) {
        if (_isTransient(e)) {
          final attempts = row.attempts + 1;
          await _db.updateSyncRow(
            row.id,
            SyncQueueCompanion(
              attempts: Value(attempts),
              state: attempts >= kMaxSyncAttempts
                  ? const Value('failed')
                  : const Value('pending'),
            ),
          );
          // This source is likely down/unauthorized; stop draining it this pass
          // and retry on the next trigger (launch / resume / next online write).
          stalled.add(row.sourceId);
          continue;
        }
        // Permanent (e.g. book deleted server-side): dead-letter and continue.
        await _db.updateSyncRow(
          row.id,
          const SyncQueueCompanion(state: Value('failed')),
        );
      }
    }
  }
}

/// Whether a Komga error is worth retrying. Unreachable/TLS carry a null
/// statusCode; 401 (session may re-auth), 408, 429, and 5xx are transient.
/// Everything else (400/403/404/422...) is permanent.
bool _isTransient(KomgaException e) {
  switch (e.kind) {
    case KomgaErrorKind.unreachable:
    case KomgaErrorKind.tls:
    case KomgaErrorKind.unauthorized:
      return true;
    case KomgaErrorKind.forbidden:
    case KomgaErrorKind.notFound:
      return false;
    case KomgaErrorKind.badResponse:
    case KomgaErrorKind.unknown:
      final s = e.statusCode;
      return s == null || s == 408 || s == 429 || s >= 500;
  }
}
