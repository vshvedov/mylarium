import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/theme/app_theme.dart';
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

  group('einkTheme', () {
    test('is monochrome black on white with eink tokens', () {
      final scheme = einkTheme.colorScheme;
      expect(einkTheme.scaffoldBackgroundColor, const Color(0xFFFFFFFF));
      expect(scheme.surface, const Color(0xFFFFFFFF));
      expect(scheme.primary, const Color(0xFF000000));
      expect(scheme.onPrimary, const Color(0xFFFFFFFF));
      // No hue: R, G, B equal in the key roles.
      for (final c in [scheme.onSurface, scheme.primary, scheme.surface]) {
        expect(c.r == c.g && c.g == c.b, isTrue,
            reason: '$c must be a pure gray');
      }
      expect(einkTheme.extension<DesignTokens>()!.isEink, isTrue);
    });
  });
}
