import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/core/platform/render_capabilities.dart';

void main() {
  group('focusTextureCap', () {
    test('passes through values at or below the RAM-safe focus limit', () {
      expect(focusTextureCap(2048), 2048);
      expect(focusTextureCap(4096), 4096);
      expect(focusTextureCap(kMaxFocusTextureDim), kMaxFocusTextureDim);
    });

    test('clamps values above the RAM-safe focus limit', () {
      expect(focusTextureCap(16384), kMaxFocusTextureDim);
      expect(focusTextureCap(kMaxFocusTextureDim + 1), kMaxFocusTextureDim);
    });

    test('the fallback floor is a safe, conservative value', () {
      expect(kFallbackMaxTextureDim, 4096);
      expect(focusTextureCap(kFallbackMaxTextureDim), 4096);
    });
  });
}
