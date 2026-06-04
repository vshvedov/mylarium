import 'package:drift/drift.dart';

/// Local, source-of-truth read state for a book. Composite PK `{sourceId,
/// bookId}` (multi-source safe; two servers can share a book id).
///
/// [currentPage] is 0-based (reader-native). Komga's 1-based page is converted
/// at the sync boundary, never stored here. [updatedAt] is our local
/// lastModified (device clock); [remoteUpdatedAt] is the last-seen Komga
/// `readProgress.lastModified` (server clock), used as the reconcile baseline.
///
/// Several columns carry share-ready fields for the future phase-2 social layer
/// but default private. Phase 1 never auto-enables [shareToFeed], so NSFW
/// content is never auto-shared; a phase-2 share path must re-evaluate the
/// series age rating at share time (the value can change after a row is
/// written).
@DataClassName('BookStateRow')
class BookState extends Table {
  TextColumn get sourceId => text()();
  TextColumn get bookId => text()();

  /// One of [ReadStatus] by name, or NULL before any progress is recorded.
  TextColumn get status => text().nullable()();
  IntColumn get currentPage => integer().withDefault(const Constant(0))();

  /// RESERVED (forward-compat for Komga volume progress); unwritten in phase 1.
  RealColumn get progressVolumes => real().nullable()();

  /// RESERVED (no rating UI in phase 1).
  IntColumn get rating => integer().nullable()();

  IntColumn get timesReread => integer().withDefault(const Constant(0))();
  BoolColumn get isRereading => boolean().withDefault(const Constant(false))();
  IntColumn get startedAt => integer().nullable()();
  IntColumn get finishedAt => integer().nullable()();

  TextColumn get visibility => text().withDefault(const Constant('private'))();
  BoolColumn get shareToFeed => boolean().withDefault(const Constant(false))();

  /// Local lastModified, epoch ms (device clock).
  IntColumn get updatedAt => integer()();

  /// Last-seen Komga progress lastModified, epoch ms (SERVER clock). The
  /// "is there something new on the server" baseline; only ever a server value,
  /// NULL when the server has no read progress for this book. Never compared
  /// against a device clock.
  IntColumn get remoteUpdatedAt => integer().nullable()();

  /// When this book was last reconciled, epoch ms (DEVICE clock). Drives the
  /// reconcile rotation (least-recently-reconciled first); NULL = never
  /// reconciled, so it sorts to the head. Kept separate from [remoteUpdatedAt]
  /// so the rotation order and the freshness comparison never mix clock
  /// domains.
  IntColumn get reconciledAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {sourceId, bookId};
}
