import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/app.dart';
import 'package:mylarium/app/theme/app_theme.dart';

import '../../support/test_scope.dart';

void main() {
  test('high-contrast themes differ from the normal schemes', () {
    expect(highContrastLightTheme.colorScheme,
        isNot(equals(lightTheme.colorScheme)));
    expect(highContrastDarkTheme.colorScheme,
        isNot(equals(darkTheme.colorScheme)));
  });

  testWidgets('app wires non-null high-contrast theme slots', (tester) async {
    final scope = await TestScope.create();
    addTearDown(scope.db.close);

    await tester.pumpWidget(
      ProviderScope(overrides: scope.overrides, child: const MylariumApp()),
    );

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.highContrastTheme, isNotNull);
    expect(app.highContrastDarkTheme, isNotNull);
  });
}
