import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/features/reader/reader_controller.dart';

void main() {
  group('resolveInitialReaderPage', () {
    test('local read state wins over the server page', () {
      expect(
        resolveInitialReaderPage(savedCurrentPage: 5, serverReadPage: 99),
        5,
      );
    });

    test('a saved page 0 is honored (not overridden by a further server page)',
        () {
      expect(
        resolveInitialReaderPage(savedCurrentPage: 0, serverReadPage: 10),
        0,
      );
    });

    test('no local state falls back to the server page, 1-based -> 0-based', () {
      // The reinstall bug: BookState is missing, so without this fallback the
      // reader opened at page 1 despite the server knowing the resume page.
      expect(
        resolveInitialReaderPage(savedCurrentPage: null, serverReadPage: 8),
        7,
      );
    });

    test('no local state and no server page opens at the first page', () {
      expect(
        resolveInitialReaderPage(savedCurrentPage: null, serverReadPage: null),
        0,
      );
    });

    test('a server page of 1 (or a defensive 0) clamps to the first page', () {
      expect(
        resolveInitialReaderPage(savedCurrentPage: null, serverReadPage: 1),
        0,
      );
      expect(
        resolveInitialReaderPage(savedCurrentPage: null, serverReadPage: 0),
        0,
      );
    });
  });
}
