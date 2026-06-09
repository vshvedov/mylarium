import '../../core/db/database.dart';

/// A saved page capture, as the gallery sees it: the persisted row fields plus
/// the [absolutePath] of the PNG resolved for this install (the DB stores only a
/// relative path, which changes container between installs on iOS).
class Capture {
  const Capture({
    required this.id,
    required this.sourceId,
    required this.seriesId,
    required this.bookId,
    required this.libraryId,
    required this.seriesTitle,
    required this.bookTitle,
    required this.pageNumber,
    required this.relativePath,
    required this.absolutePath,
    required this.width,
    required this.height,
    required this.capturedAt,
  });

  factory Capture.fromRow(CaptureRow row, String absolutePath) => Capture(
        id: row.id,
        sourceId: row.sourceId,
        seriesId: row.seriesId,
        bookId: row.bookId,
        libraryId: row.libraryId,
        seriesTitle: row.seriesTitle,
        bookTitle: row.bookTitle,
        pageNumber: row.pageNumber,
        relativePath: row.relativePath,
        absolutePath: absolutePath,
        width: row.width,
        height: row.height,
        capturedAt: row.capturedAt,
      );

  final String id;
  final String sourceId;
  final String seriesId;
  final String bookId;
  final String? libraryId;
  final String? seriesTitle;
  final String? bookTitle;
  final int pageNumber;
  final String relativePath;
  final String absolutePath;
  final int width;
  final int height;

  /// Device clock, epoch ms.
  final int capturedAt;

  DateTime get capturedAtLocal =>
      DateTime.fromMillisecondsSinceEpoch(capturedAt);

  /// Display aspect ratio for a gallery tile (guards against a zero dimension).
  double get aspectRatio => (width <= 0 || height <= 0) ? 0.7 : width / height;
}
