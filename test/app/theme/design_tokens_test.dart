import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/theme/design_tokens.dart';

void main() {
  test('lerp interpolates every field at the midpoint', () {
    final m = DesignTokens.light.lerp(DesignTokens.dark, 0.5);
    // Equal endpoints stay equal.
    expect(m.gridGutter, DesignTokens.light.gridGutter);
    expect(m.coverRadius, DesignTokens.light.coverRadius);
    expect(m.tapZones.edgeFraction, DesignTokens.light.tapZones.edgeFraction);
    // Differing endpoints interpolate.
    expect(
      m.readerBackground,
      Color.lerp(
        DesignTokens.light.readerBackground,
        DesignTokens.dark.readerBackground,
        0.5,
      ),
    );
    expect(
      m.tapZones.overlay,
      Color.lerp(
        DesignTokens.light.tapZones.overlay,
        DesignTokens.dark.tapZones.overlay,
        0.5,
      ),
    );
  });

  test('copyWith changes only the named field', () {
    final c = DesignTokens.light.copyWith(gridGutter: 99);
    expect(c.gridGutter, 99);
    expect(c.coverRadius, DesignTokens.light.coverRadius);
    expect(c.readerBackground, DesignTokens.light.readerBackground);
  });
}
