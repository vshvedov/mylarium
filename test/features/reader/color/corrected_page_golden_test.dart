import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/features/reader/color/color_math.dart';
import 'package:mylarium/features/reader/color/color_settings.dart';

/// A deterministic, platform-independent "golden" for a corrected page: a known
/// source pixel buffer transformed by the CPU pipeline (the decode-time path)
/// versus its hand-computed expected output. Uses raw bytes (not a rendered
/// PNG) so it never varies by platform/GPU.
void main() {
  test('gamma 2.0 corrects a known source to the golden bytes', () {
    // Source: a 1x4 grayscale ramp [0, 64, 128, 255].
    final source = Uint8List.fromList([
      0, 0, 0, 255, //
      64, 64, 64, 255,
      128, 128, 128, 255,
      255, 255, 255, 255,
    ]);
    final corrected = Uint8List.fromList(source);
    applyToBytes(corrected, 4, 1, const ColorAdjustments(gamma: 2.0));

    // sqrt(x/255) * 255: 0 -> 0, 64 -> 128, 128 -> 181, 255 -> 255.
    const golden = [
      0, 0, 0, 255, //
      128, 128, 128, 255,
      181, 181, 181, 255,
      255, 255, 255, 255,
    ];
    expect(corrected, golden);
    // And it actually changed the source (it is a correction, not a copy).
    expect(corrected, isNot(source));
  });

  test('sepia + contrast golden for a mid-gray block', () {
    final corrected = Uint8List.fromList([120, 120, 120, 255]);
    applyToBytes(
      corrected,
      1,
      1,
      const ColorAdjustments(contrast: 0.2, mode: ColorMode.sepia),
    );
    // contrast c=1.2: (120/255-0.5)*1.2+0.5 = 0.46471; sepia of equal channels:
    // R 1.351*0.46471=0.6278->160, G 1.203*0.46471=0.5590->143, B 0.937*0.46471=0.4354->111
    expect(corrected[0], closeTo(160, 1));
    expect(corrected[1], closeTo(143, 1));
    expect(corrected[2], closeTo(111, 1));
    expect(corrected[3], 255);
  });
}
