import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/features/reader/color/color_settings.dart';

void main() {
  ScopedColor on(double brightness) =>
      ScopedColor(ColorAdjustments(brightness: brightness), true);

  group('resolveScopedColor (most specific existing wins, enable-aware)', () {
    test('chapter beats series beats global', () {
      expect(resolveScopedColor(on(0.1), on(0.2), on(0.3)).brightness, 0.3);
    });

    test('series wins when chapter is absent', () {
      expect(resolveScopedColor(on(0.1), on(0.2), null).brightness, 0.2);
    });

    test('global wins when series and chapter are absent', () {
      expect(resolveScopedColor(on(0.1), null, null).brightness, 0.1);
    });

    test('identity when nothing is set', () {
      expect(resolveScopedColor(null, null, null), ColorAdjustments.identity);
    });

    test('a disabled most-specific row resolves to identity (explicit off)', () {
      final disabledChapter =
          ScopedColor(const ColorAdjustments(brightness: 0.3), false);
      expect(
        resolveScopedColor(on(0.1), on(0.2), disabledChapter),
        ColorAdjustments.identity,
      );
    });

    test('a disabled global with no overrides resolves to identity', () {
      final disabledGlobal =
          ScopedColor(const ColorAdjustments(brightness: 0.1), false);
      expect(
        resolveScopedColor(disabledGlobal, null, null),
        ColorAdjustments.identity,
      );
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
