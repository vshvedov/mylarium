import 'package:drift/drift.dart';

/// A downloaded archive cached on disk for offline reading. Composite PK
/// `{sourceId, bookId}`.
///
/// [relativePath] is RELATIVE to applicationSupport (CLAUDE.md). [sizeBytes] is
/// the on-disk size, used for LRU eviction accounting. [pinned] (user pin) and
/// [permanent] (imported files, T7) are exempt from eviction. [lastAccessedAt]
/// (millis) is the LRU key, updated when the book is opened.
@DataClassName('CachedAsset')
@TableIndex(name: 'cached_assets_lru', columns: {#lastAccessedAt})
class CachedAssets extends Table {
  TextColumn get sourceId => text()();
  TextColumn get bookId => text()();

  /// Asset kind; `archive` for the downloaded CBZ/CBR.
  TextColumn get kind => text().withDefault(const Constant('archive'))();

  /// Path relative to applicationSupport.
  TextColumn get relativePath => text()();
  IntColumn get sizeBytes => integer().withDefault(const Constant(0))();

  /// Reserved for an integrity hash; unused in T5.
  TextColumn get sha => text().nullable()();
  IntColumn get lastAccessedAt => integer()();
  BoolColumn get pinned => boolean().withDefault(const Constant(false))();
  BoolColumn get permanent => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {sourceId, bookId};
}
