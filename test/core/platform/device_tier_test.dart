import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/core/platform/device_tier.dart';

void main() {
  group('resolveDeviceTier', () {
    test('four or fewer cores is low', () {
      expect(resolveDeviceTier(processors: 4, screenPixels: 1000000),
          DeviceTier.low);
      expect(resolveDeviceTier(processors: 2, screenPixels: 4000000),
          DeviceTier.low);
    });
    test('mid cores is normal', () {
      expect(resolveDeviceTier(processors: 6, screenPixels: 2000000),
          DeviceTier.normal);
    });
    test('many cores and a large screen is high', () {
      expect(resolveDeviceTier(processors: 8, screenPixels: 4000000),
          DeviceTier.high);
    });
    test('many cores but a small screen stays normal', () {
      expect(resolveDeviceTier(processors: 8, screenPixels: 800000),
          DeviceTier.normal);
    });
  });

  group('focus cap', () {
    test('low is the most conservative at 2048', () {
      expect(DeviceTier.low.focusCap, 2048);
    });
    test('normal is the safe texture size', () {
      expect(DeviceTier.normal.focusCap, kMaxSafeTextureDim);
    });
    test('high is at least the safe texture size', () {
      expect(DeviceTier.high.focusCap,
          greaterThanOrEqualTo(kMaxSafeTextureDim));
    });
    test('caps increase from low to high', () {
      expect(DeviceTier.normal.focusCap, greaterThan(DeviceTier.low.focusCap));
      expect(DeviceTier.high.focusCap,
          greaterThanOrEqualTo(DeviceTier.normal.focusCap));
    });
  });

  group('sampling', () {
    test('low uses medium, others high', () {
      expect(DeviceTier.low.sampling, FilterQuality.medium);
      expect(DeviceTier.normal.sampling, FilterQuality.high);
      expect(DeviceTier.high.sampling, FilterQuality.high);
    });
  });
}
