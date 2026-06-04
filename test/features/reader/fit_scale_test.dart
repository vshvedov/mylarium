import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/features/reader/gestures/fit_scale.dart';
import 'package:mylarium/features/reader/reader_models.dart';
import 'package:photo_view/photo_view.dart';

void main() {
  group('fitInitialScale', () {
    test('screen always maps to contained', () {
      expect(fitInitialScale(FitMode.screen, 0.66, 0.7),
          PhotoViewComputedScale.contained);
    });

    test('null/invalid aspect falls back to contained', () {
      expect(fitInitialScale(FitMode.width, null, 0.7),
          PhotoViewComputedScale.contained);
      expect(fitInitialScale(FitMode.height, 0, 0.7),
          PhotoViewComputedScale.contained);
    });

    test('fit width zooms past contained for a page taller than the viewport',
        () {
      // Tall page (aspect 0.5) in a wider viewport (0.7): width should fill,
      // so the scale exceeds contained.
      final scale = fitInitialScale(FitMode.width, 0.5, 0.7)
          as PhotoViewComputedScale;
      expect(scale.multiplier, greaterThan(1.0));
    });

    test('fit width equals contained when the page is wider than the viewport',
        () {
      final scale = fitInitialScale(FitMode.width, 1.5, 0.7)
          as PhotoViewComputedScale;
      expect(scale.multiplier, 1.0);
    });

    test('fit height zooms past contained for a page wider than the viewport',
        () {
      final scale = fitInitialScale(FitMode.height, 1.5, 0.7)
          as PhotoViewComputedScale;
      expect(scale.multiplier, greaterThan(1.0));
    });

    test('original maps to covered', () {
      expect(fitInitialScale(FitMode.original, 0.66, 0.7),
          PhotoViewComputedScale.covered);
    });
  });

  group('boxFitFor', () {
    test('maps each fit mode', () {
      expect(boxFitFor(FitMode.screen), BoxFit.contain);
      expect(boxFitFor(FitMode.width), BoxFit.fitWidth);
      expect(boxFitFor(FitMode.height), BoxFit.fitHeight);
      expect(boxFitFor(FitMode.original), BoxFit.none);
    });
  });
}
