import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/features/reader/gestures/fit_scale.dart';
import 'package:mylarium/features/reader/reader_models.dart';

void main() {
  group('boxFitFor', () {
    test('maps each fit mode', () {
      expect(boxFitFor(FitMode.screen), BoxFit.contain);
      expect(boxFitFor(FitMode.width), BoxFit.fitWidth);
      expect(boxFitFor(FitMode.height), BoxFit.fitHeight);
      expect(boxFitFor(FitMode.original), BoxFit.none);
    });
  });
}
