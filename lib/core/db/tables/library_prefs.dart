import 'package:drift/drift.dart';

/// Per-library reading preferences: lock state and whether age-restricted series
/// are shown. Composite PK `{sourceId, libraryId}`.
///
/// This is configuration (never evicted), so it lives in its own table rather
/// than in the thumbnail/metadata caches. [locked] gates the library behind a
/// biometric/PIN unlock; [showRestricted] reveals restricted series, but only
/// takes effect while the library is unlocked (see `AppLock`).
@DataClassName('LibraryPref')
class LibraryPrefs extends Table {
  /// FK to `Sources.id`.
  TextColumn get sourceId => text()();

  /// Komga library id.
  TextColumn get libraryId => text()();

  BoolColumn get locked => boolean().withDefault(const Constant(false))();
  BoolColumn get showRestricted =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {sourceId, libraryId};
}
