import 'package:drift/drift.dart';

/// Append-only log of reading sessions, the source of truth for stats. Each row
/// is share-ready (carries `sourceId`, `seriesId`, page span, timing,
/// `deviceId`, and private-by-default visibility) so the phase-2 social layer
/// is unblocked without storing anything differently.
///
/// [startPage]/[endPage] are 0-based. [activeSeconds] is idle-capped reading
/// time (not wall clock). A session synthesized for an off-device read during
/// reconciliation has `deviceId == 'remote'` and `activeSeconds == 0`; stats
/// exclude those from time metrics but count their pages.
@DataClassName('ReadingSessionRow')
class ReadingSessions extends Table {
  /// uuid v4.
  TextColumn get id => text()();

  TextColumn get sourceId => text()();
  TextColumn get bookId => text()();
  TextColumn get seriesId => text()();

  /// Epoch ms.
  IntColumn get startedAt => integer()();
  IntColumn get endedAt => integer()();

  /// Idle-capped active reading seconds.
  IntColumn get activeSeconds => integer()();

  IntColumn get startPage => integer()();
  IntColumn get endPage => integer()();
  IntColumn get pagesRead => integer()();
  BoolColumn get isCompletion => boolean().withDefault(const Constant(false))();
  IntColumn get rereadIndex => integer().withDefault(const Constant(0))();
  TextColumn get deviceId => text()();

  TextColumn get visibility => text().withDefault(const Constant('private'))();
  BoolColumn get shareToFeed => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
