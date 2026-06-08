import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
}
