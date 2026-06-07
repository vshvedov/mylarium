import 'package:drift/drift.dart';

/// A snapshot of one home rail's last successfully-fetched membership, as an
/// ordered list of pointers into the [Series] / [Books] caches. Lets a network
/// rail render its previous content instantly on a warm launch (cache-first)
/// before the server responds. Composite PK `{sourceId, railKind, position}`.
///
/// Only the network-backed rails are snapshotted (`keepReading`,
/// `recentlyAddedChapters`, `recentlyAddedSeries`, `recentlyUpdatedSeries`); the
/// other rails already stream from authoritative local tables. The row class is
/// named `HomeRailItemRow` to avoid colliding with the UI `HomeRailItem` in
/// `features/home/home_layout.dart`.
@DataClassName('HomeRailItemRow')
class HomeRailItems extends Table {
  /// FK to `Sources.id`.
  TextColumn get sourceId => text()();

  /// The rail this snapshot belongs to (`HomeRailKind.name`).
  TextColumn get railKind => text()();

  /// 0-based position in the server-returned order.
  IntColumn get position => integer()();

  /// `series` or `book`.
  TextColumn get ownerType => text()();

  /// The series id or book id, per [ownerType].
  TextColumn get ownerId => text()();

  @override
  Set<Column> get primaryKey => {sourceId, railKind, position};
}
