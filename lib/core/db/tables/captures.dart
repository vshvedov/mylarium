import 'package:drift/drift.dart';

/// A user-captured region of a page, saved to the personal gallery. Each row
/// carries enough source context (`sourceId`, `seriesId`, `bookId`,
/// `pageNumber`) to return to the exact chapter and page later, plus
/// [capturedAt] (device clock, epoch ms) so a future monthly/yearly recap can
/// be built without storing anything differently.
///
/// The PNG itself lives on disk under `media/captures/...`; only the RELATIVE
/// [relativePath] is stored here (the iOS sandbox container path changes between
/// installs). [libraryId] is the owning book's library (null when the book was
/// not cached at capture time), used to hide a now-locked library's captures
/// from the gallery, mirroring the rest of the app's lock model.
@DataClassName('CaptureRow')
@TableIndex(name: 'idx_captures_captured_at', columns: {#capturedAt})
class Captures extends Table {
  /// uuid v4.
  TextColumn get id => text()();

  TextColumn get sourceId => text()();
  TextColumn get seriesId => text()();
  TextColumn get bookId => text()();

  /// Owning book's library id, for lock-aware gallery filtering. Null when the
  /// book was not cached at capture time (treated as not-locked, consistent with
  /// `AppLock.isLocked(null)`).
  TextColumn get libraryId => text().nullable()();

  /// Series display title, denormalized so the gallery can show the series name
  /// even when the series row is uncached, offline, or the source was removed.
  TextColumn get seriesTitle => text().nullable()();

  /// Book (chapter) display title, denormalized so the gallery can label a
  /// capture even when the book row is uncached, offline, or the source was
  /// removed.
  TextColumn get bookTitle => text().nullable()();

  /// 0-based page index in the reader, matching `BookState.currentPage`.
  IntColumn get pageNumber => integer()();

  /// Relative path of the PNG under `media/captures/...`.
  TextColumn get relativePath => text()();

  /// Captured image dimensions in pixels (drive the gallery tile aspect).
  IntColumn get width => integer()();
  IntColumn get height => integer()();

  /// Device clock, epoch ms.
  IntColumn get capturedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
