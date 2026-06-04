import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/theme/design_tokens.dart';

/// WCAG relative luminance of an sRGB color (channels are 0..1 doubles).
double _luminance(Color c) {
  double lin(double ch) => ch <= 0.03928
      ? ch / 12.92
      : math.pow((ch + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * lin(c.r) + 0.7152 * lin(c.g) + 0.0722 * lin(c.b);
}

double _contrastRatio(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  final hi = math.max(la, lb);
  final lo = math.min(la, lb);
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  test(
    'hero text (white) over the cover fallback meets WCAG AA in both themes',
    () {
      for (final tokens in [DesignTokens.light, DesignTokens.dark]) {
        final fallback = tokens.gradients.coverFallback as LinearGradient;
        final bottom = fallback.colors.last;
        expect(
          _contrastRatio(Colors.white, bottom),
          greaterThanOrEqualTo(4.5),
          reason: 'white hero text over the fallback hero must clear AA',
        );
      }
    },
  );
}
