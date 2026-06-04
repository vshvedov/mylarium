import 'package:drift/drift.dart';

/// A queued/in-flight offline download. Composite PK `{sourceId, bookId}`
/// (multi-source safe: two servers can share a book id).
///
/// [taskId] correlates with the `background_downloader` task for resume.
/// [state] is one of `enqueued|running|paused|complete|failed`.
@DataClassName('DownloadTask')
class DownloadTasks extends Table {
  TextColumn get sourceId => text()();
  TextColumn get bookId => text()();

  TextColumn get taskId => text()();
  TextColumn get state => text().withDefault(const Constant('enqueued'))();
  IntColumn get bytesDownloaded => integer().withDefault(const Constant(0))();
  IntColumn get totalBytes => integer().nullable()();
  BoolColumn get requiresWifi => boolean().withDefault(const Constant(true))();

  /// True for a manual download (goes to the permanent downloads pool); false
  /// for an auto-cache download. Lets resume-on-launch pick the right pool.
  BoolColumn get permanent => boolean().withDefault(const Constant(false))();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {sourceId, bookId};
}
