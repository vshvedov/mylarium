import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/features/reader/image_quality.dart';

void main() {
  group('manual decode ceilings', () {
    test('increase from smoother to sharper', () {
      for (var i = 1; i < kManualDecodeCeilings.length; i++) {
        expect(kManualDecodeCeilings[i],
            greaterThan(kManualDecodeCeilings[i - 1]));
      }
    });

    test('sharpest stop is the effectively-uncapped (native) sentinel', () {
      expect(kManualDecodeCeilings.last, kNativeDecodeCeiling);
      expect(kNativeDecodeCeiling, greaterThan(100000));
    });
  });

  group('ImageQuality.focusCeiling', () {
    test('smart uses the device cap and ignores the manual level', () {
      expect(const ImageQuality(smart: true, manualLevel: 0).focusCeiling(4096),
          4096);
      expect(const ImageQuality(smart: true, manualLevel: 4).focusCeiling(2048),
          2048);
    });

    test('manual maps each level to the ceiling table, ignoring the device cap',
        () {
      for (var i = 0; i < kManualDecodeCeilings.length; i++) {
        expect(ImageQuality(smart: false, manualLevel: i).focusCeiling(4096),
            kManualDecodeCeilings[i]);
      }
    });

    test('manual clamps an out-of-range level', () {
      expect(const ImageQuality(smart: false, manualLevel: -1).focusCeiling(4096),
          kManualDecodeCeilings.first);
      expect(const ImageQuality(smart: false, manualLevel: 99).focusCeiling(4096),
          kManualDecodeCeilings.last);
    });
  });
}
