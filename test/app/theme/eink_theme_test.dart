import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/theme/design_tokens.dart';
import 'package:mylarium/app/theme/theme_controller.dart';

void main() {
  group('AppThemeMode.eink', () {
    test('eink maps to ThemeMode.light', () {
      expect(toThemeMode(AppThemeMode.eink), ThemeMode.light);
    });

    test('eink round-trips through its name', () {
      // The settings column stores the enum name; reloading must parse it back.
      expect(AppThemeMode.values.byName('eink'), AppThemeMode.eink);
    });
  });

  group('DesignTokens.eink', () {
    test('flags eink and strips shadows and reader tint', () {
      const t = DesignTokens.eink;
      expect(t.isEink, isTrue);
      expect(t.elevation.card, isEmpty);
      expect(t.elevation.hero, isEmpty);
      expect(t.readerBackground, const Color(0xFFFFFFFF));
    });

    test('light and dark tokens are not eink', () {
      expect(DesignTokens.light.isEink, isFalse);
      expect(DesignTokens.dark.isEink, isFalse);
    });
  });
}
