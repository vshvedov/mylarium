import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/features/reader/image_quality.dart';

void main() {
  group('ImageQuality.ceiling', () {
    test('smart uses the smart ceiling and ignores the manual level', () {
      expect(const ImageQuality(smart: true, manualLevel: 0).ceiling,
          kSmartDecodeCeiling);
      expect(const ImageQuality(smart: true, manualLevel: 4).ceiling,
          kSmartDecodeCeiling);
    });

    test('manual maps each level to the ceiling table', () {
      for (var i = 0; i < kManualDecodeCeilings.length; i++) {
        expect(ImageQuality(smart: false, manualLevel: i).ceiling,
            kManualDecodeCeilings[i]);
      }
    });

    test('manual clamps an out-of-range level', () {
      expect(const ImageQuality(smart: false, manualLevel: -1).ceiling,
          kManualDecodeCeilings.first);
      expect(const ImageQuality(smart: false, manualLevel: 99).ceiling,
          kManualDecodeCeilings.last);
    });

    test('sharpest stop is effectively uncapped (native)', () {
      expect(kManualDecodeCeilings.last, kNativeDecodeCeiling);
      expect(kNativeDecodeCeiling, greaterThan(100000));
    });

    test('ceilings increase from smoother to sharper', () {
      for (var i = 1; i < kManualDecodeCeilings.length; i++) {
        expect(kManualDecodeCeilings[i],
            greaterThan(kManualDecodeCeilings[i - 1]));
      }
    });
  });
}
