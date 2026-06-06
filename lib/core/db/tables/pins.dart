import 'package:drift/drift.dart';

/// A user-curated "pin": marks a series or chapter to surface on the home
/// "Pinned" rail. Polymorphic via [ownerType] (`series` | `book`) + [ownerId],
/// keyed off the same owner pattern as covers/thumbnails. Composite PK
/// `{sourceId, ownerType, ownerId}` so a pin is unique per item.
///
/// This is distinct from offline pinning (`CachedAssets.pinned`, which exempts a
/// downloaded archive from cache eviction): a curation pin is purely a home-screen
/// affordance and never touches the offline cache.
@DataClassName('PinRow')
class Pins extends Table {
  /// FK to `Sources.id`.
  TextColumn get sourceId => text()();

  /// `series` or `book`.
  TextColumn get ownerType => text()();

  /// The series id or book id, per [ownerType].
  TextColumn get ownerId => text()();

  /// When the pin was created (epoch ms); the rail orders newest first.
  IntColumn get pinnedAt => integer()();

  @override
  Set<Column> get primaryKey => {sourceId, ownerType, ownerId};
}
