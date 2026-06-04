import 'package:drift/drift.dart';

/// Pending Komga read-progress write-backs. Each book has at most one queued
/// row (UNIQUE `{sourceId, bookId}`); a new local turn replaces the prior row
/// via a delete-then-insert (latest-wins), and the enqueued value is always the
/// post-resolve monotonic progress, so the collapse can never un-complete or
/// rewind. [page] is 0-based; the engine converts to Komga 1-based on PATCH.
///
/// [state] is `pending` or `failed` (dead-lettered after repeated permanent
/// errors). [attempts] counts transient failures.
@DataClassName('SyncQueueRow')
@TableIndex(
  name: 'sync_queue_book',
  columns: {#sourceId, #bookId},
  unique: true,
)
class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get sourceId => text()();
  TextColumn get bookId => text()();
  IntColumn get page => integer()();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  IntColumn get queuedAt => integer()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get state => text().withDefault(const Constant('pending'))();
}
