import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/app.dart';
import 'package:mylarium/app/theme/theme_controller.dart';

import '../../support/test_scope.dart';

void main() {
  testWidgets('controller swaps theme mode and persists', (tester) async {
    final scope = await TestScope.create();
    addTearDown(scope.db.close);

    await tester.pumpWidget(
      ProviderScope(overrides: scope.overrides, child: const MylariumApp()),
    );
    await tester.pumpAndSettle();

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.system,
    );

    final container =
        ProviderScope.containerOf(tester.element(find.byType(MylariumApp)));
    await container.read(themeControllerProvider.notifier).set(AppThemeMode.dark);
    await tester.pumpAndSettle();

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
    expect((await scope.db.getOrCreateSettings()).themeMode, 'dark');
  });
}
