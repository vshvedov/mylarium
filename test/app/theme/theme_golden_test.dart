import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/theme/app_theme.dart';
import 'package:mylarium/features/home/home_screen.dart';

import '../../support/test_scope.dart';

Future<void> _pumpHome(WidgetTester tester, ThemeData theme) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final scope = await TestScope.create();
  addTearDown(scope.db.close);

  await tester.pumpWidget(
    ProviderScope(
      overrides: scope.overrides,
      child: MaterialApp(theme: theme, home: const HomeScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('home renders in light theme', (tester) async {
    await _pumpHome(tester, lightTheme);
    await expectLater(
      find.byType(HomeScreen),
      matchesGoldenFile('goldens/home_light.png'),
    );
  });

  testWidgets('home renders in dark theme', (tester) async {
    await _pumpHome(tester, darkTheme);
    await expectLater(
      find.byType(HomeScreen),
      matchesGoldenFile('goldens/home_dark.png'),
    );
  });
}
