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

  test(
    'lerp interpolates the new token groups at the midpoint without throwing',
    () {
      final m = DesignTokens.light.lerp(DesignTokens.dark, 0.5);
      // Curves snap (not interpolable); equal-endpoint durations stay equal.
      expect(m.motion.short, DesignTokens.light.motion.short);
      // Elevation shadows interpolate (blur is the average of the endpoints).
      expect(m.elevation.card, isNotEmpty);
      expect(
        m.elevation.card.first.blurRadius,
        closeTo(
          (DesignTokens.light.elevation.card.first.blurRadius +
                  DesignTokens.dark.elevation.card.first.blurRadius) /
              2,
          0.001,
        ),
      );
      expect(m.gradients.scrim, isA<Gradient>());
    },
  );

  test('copyWith replaces a new token group and leaves others intact', () {
    const motion = MotionTokens(
      standard: Curves.linear,
      emphasized: Curves.linear,
      short: Duration(milliseconds: 1),
      medium: Duration(milliseconds: 2),
    );
    final c = DesignTokens.light.copyWith(motion: motion);
    expect(c.motion.short, const Duration(milliseconds: 1));
    expect(c.gridGutter, DesignTokens.light.gridGutter);
    expect(c.elevation, DesignTokens.light.elevation);
  });
}
