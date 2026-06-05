import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/features/reader/color/color_math.dart';
import 'package:mylarium/features/reader/color/color_settings.dart';

/// Builds a 1-pixel RGBA buffer.
Uint8List _px(int r, int g, int b, [int a = 255]) =>
    Uint8List.fromList([r, g, b, a]);

void main() {
  group('applyToBytes', () {
    test('identity leaves the pixel unchanged', () {
      final px = _px(10, 128, 240);
      applyToBytes(px, 1, 1, ColorAdjustments.identity);
      expect(px, [10, 128, 240, 255]);
    });

    test('invert flips each channel and preserves alpha', () {
      final px = _px(10, 20, 30, 200);
      applyToBytes(px, 1, 1, const ColorAdjustments(mode: ColorMode.invert));
      expect(px, [245, 235, 225, 200]);
    });

    test('brightness adds a normalized offset', () {
      final px = _px(100, 100, 100);
      applyToBytes(px, 1, 1, const ColorAdjustments(brightness: 0.2));
      // 100/255 + 0.2 = 0.5922 -> 151
      expect(px[0], closeTo(151, 1));
    });

    test('contrast holds the midpoint and pushes extremes', () {
      final dark = _px(64, 64, 64);
      final light = _px(200, 200, 200);
      applyToBytes(dark, 1, 1, const ColorAdjustments(contrast: 1.0));
      applyToBytes(light, 1, 1, const ColorAdjustments(contrast: 1.0));
      // c = 2: 64 -> ~1, 200 -> clamps to 255
      expect(dark[0], lessThan(10));
      expect(light[0], 255);
    });

    test('gamma 2.0 lifts midtones (sqrt)', () {
      final px = _px(64, 64, 64);
      applyToBytes(px, 1, 1, const ColorAdjustments(gamma: 2.0));
      // sqrt(64/255) * 255 ~= 128
      expect(px[0], closeTo(128, 1));
    });

    test('grayscale uses Rec.601 luma', () {
      final px = _px(255, 0, 0);
      applyToBytes(px, 1, 1, const ColorAdjustments(mode: ColorMode.grayscale));
      // 0.299 * 255 ~= 76
      expect(px[0], closeTo(76, 1));
      expect(px[0], px[1]);
      expect(px[1], px[2]);
    });

    test('sepia warms a mid-gray', () {
      final px = _px(100, 100, 100);
      applyToBytes(px, 1, 1, const ColorAdjustments(mode: ColorMode.sepia));
      expect(px[0], closeTo(135, 1));
      expect(px[1], closeTo(120, 1));
      expect(px[2], closeTo(94, 1));
    });

    test('auto-levels stretches a compressed range to full', () {
      // A flat block at value 128 in a [100, 156] band stretches toward mid.
      final levels = const Levels(
        rLo: 100 / 255,
        rHi: 156 / 255,
        gLo: 100 / 255,
        gHi: 156 / 255,
        bLo: 100 / 255,
        bHi: 156 / 255,
      );
      final px = _px(128, 128, 128);
      applyToBytes(
        px,
        1,
        1,
        const ColorAdjustments(autoLevels: true),
        levels: levels,
      );
      // (128-100)/(156-100) = 0.5 -> 128
      expect(px[0], closeTo(128, 1));

      final low = _px(100, 100, 100);
      applyToBytes(
        low,
        1,
        1,
        const ColorAdjustments(autoLevels: true),
        levels: levels,
      );
      expect(low[0], 0); // black point maps to 0
    });
  });

  group('computeAutoLevels', () {
    test('finds per-channel black/white points of a ramp', () {
      // 256 pixels: R ramps 0..255, G constant 128, B in a narrow 60..70 band.
      final buf = Uint8List(256 * 4);
      for (var i = 0; i < 256; i++) {
        buf[i * 4] = i; // R: full ramp
        buf[i * 4 + 1] = 128; // G: flat
        buf[i * 4 + 2] = 60 + (i % 11); // B: 60..70
        buf[i * 4 + 3] = 255;
      }
      final lv = computeAutoLevels(buf, 256, 1);
      // R spans nearly the whole range.
      expect((lv.rLo * 255).round(), lessThan(5));
      expect((lv.rHi * 255).round(), greaterThan(250));
      // G is flat -> degenerate -> identity (0..1).
      expect(lv.gLo, 0);
      expect(lv.gHi, 1);
      // B is a narrow band near 60..70.
      expect((lv.bLo * 255).round(), inInclusiveRange(58, 64));
      expect((lv.bHi * 255).round(), inInclusiveRange(66, 72));
    });

    test('empty buffer yields identity', () {
      expect(computeAutoLevels(Uint8List(0), 0, 0).rHi, 1);
    });
  });

  group('buildMatrix vs applyToBytes (affine subset agree within 1/255)', () {
    const affines = [
      ColorAdjustments(brightness: 0.1),
      ColorAdjustments(contrast: 0.3),
      ColorAdjustments(mode: ColorMode.invert),
      ColorAdjustments(mode: ColorMode.grayscale),
      ColorAdjustments(mode: ColorMode.sepia),
      ColorAdjustments(brightness: 0.15, contrast: 0.4, mode: ColorMode.sepia),
    ];
    final samples = [
      [0, 0, 0],
      [255, 255, 255],
      [40, 120, 200],
      [200, 30, 90],
      [128, 128, 128],
    ];

    for (final adj in affines) {
      test('matrix == bytes for ${adj.signature}', () {
        expect(adj.isAffineOnly, isTrue);
        final m = buildMatrix(adj);
        for (final s in samples) {
          final argb = applyMatrixToPixel(m, s[0], s[1], s[2], 255);
          final mr = (argb >> 16) & 0xFF;
          final mg = (argb >> 8) & 0xFF;
          final mb = argb & 0xFF;

          final px = _px(s[0], s[1], s[2]);
          applyToBytes(px, 1, 1, adj);

          expect((px[0] - mr).abs(), lessThanOrEqualTo(1), reason: 'R $s');
          expect((px[1] - mg).abs(), lessThanOrEqualTo(1), reason: 'G $s');
          expect((px[2] - mb).abs(), lessThanOrEqualTo(1), reason: 'B $s');
        }
      });
    }
  });
}
