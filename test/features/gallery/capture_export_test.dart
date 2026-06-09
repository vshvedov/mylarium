import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/features/gallery/capture_export.dart';
import 'package:mylarium/features/gallery/capture_models.dart';

Capture _capture({String? bookTitle, int pageNumber = 0}) => Capture(
      id: 'c1',
      sourceId: 's',
      seriesId: 'se',
      bookId: 'b',
      libraryId: null,
      seriesTitle: 'My Series',
      bookTitle: bookTitle,
      pageNumber: pageNumber,
      relativePath: 'media/captures/s/b/c1.png',
      absolutePath: '/tmp/c1.png',
      width: 100,
      height: 200,
      capturedAt: 1700000000000,
    );

void main() {
  group('exportFileName', () {
    test('uses the chapter title and 1-based page number', () {
      expect(
        exportFileName(_capture(bookTitle: 'Absolute Batman 008', pageNumber: 8)),
        'Absolute Batman 008 p9.png',
      );
    });

    test('falls back to Untitled when the chapter title is null or blank', () {
      expect(exportFileName(_capture(bookTitle: null)), 'Untitled p1.png');
      expect(exportFileName(_capture(bookTitle: '   ')), 'Untitled p1.png');
    });

    test('replaces filesystem-illegal characters and collapses whitespace', () {
      expect(
        exportFileName(_capture(bookTitle: 'A/B:C*?"<>|D', pageNumber: 2)),
        'A B C D p3.png',
      );
    });
  });
}
