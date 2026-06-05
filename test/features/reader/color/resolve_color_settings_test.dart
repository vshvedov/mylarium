import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/features/reader/color/color_settings.dart';

void main() {
  const global = ColorAdjustments(brightness: 0.1);
  const series = ColorAdjustments(brightness: 0.2);
  const chapter = ColorAdjustments(brightness: 0.3);

  group('resolveColorSettings (most specific wins, whole record)', () {
    test('chapter beats series beats global', () {
      expect(resolveColorSettings(global, series, chapter), chapter);
    });

    test('series wins when chapter is absent', () {
      expect(resolveColorSettings(global, series, null), series);
    });

    test('global wins when series and chapter are absent', () {
      expect(resolveColorSettings(global, null, null), global);
    });

    test('identity when nothing is set', () {
      expect(resolveColorSettings(null, null, null), ColorAdjustments.identity);
    });
  });

  group('ColorAdjustments', () {
    test('identity is identity and affine-only', () {
      expect(ColorAdjustments.identity.isIdentity, isTrue);
      expect(ColorAdjustments.identity.isAffineOnly, isTrue);
    });

    test('gamma or auto-levels makes it non-affine', () {
      expect(const ColorAdjustments(gamma: 1.5).isAffineOnly, isFalse);
      expect(const ColorAdjustments(autoLevels: true).isAffineOnly, isFalse);
      expect(const ColorAdjustments(brightness: 0.5).isAffineOnly, isTrue);
    });

    test('signature is stable and 2dp', () {
      expect(const ColorAdjustments(brightness: 0.2).signature,
          'b0.20_c0.00_g1.00_mnone_a0');
      expect(
          const ColorAdjustments(autoLevels: true, mode: ColorMode.sepia)
              .signature,
          'b0.00_c0.00_g1.00_msepia_a1');
    });
  });

  group('splitAdjustments', () {
    test('affine carries brightness/contrast/mode; residual carries gamma/auto',
        () {
      const adj = ColorAdjustments(
        brightness: 0.2,
        contrast: 0.3,
        gamma: 1.5,
        mode: ColorMode.sepia,
        autoLevels: true,
      );
      final (affine: affine, residual: residual) = splitAdjustments(adj);

      expect(affine.brightness, 0.2);
      expect(affine.contrast, 0.3);
      expect(affine.mode, ColorMode.sepia);
      expect(affine.gamma, 1.0);
      expect(affine.autoLevels, isFalse);
      expect(affine.isAffineOnly, isTrue);

      expect(residual.gamma, 1.5);
      expect(residual.autoLevels, isTrue);
      expect(residual.brightness, 0);
      expect(residual.contrast, 0);
      expect(residual.mode, ColorMode.none);
      expect(residual.isIdentity, isFalse);
    });

    test('an affine-only adjustment leaves an identity residual', () {
      const adj = ColorAdjustments(brightness: 0.5, mode: ColorMode.invert);
      final (affine: _, residual: residual) = splitAdjustments(adj);
      expect(residual.isIdentity, isTrue);
    });
  });
}
