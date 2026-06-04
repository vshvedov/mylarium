import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/app.dart';
import 'package:mylarium/app/theme/app_theme.dart';

import '../../support/test_scope.dart';

void main() {
  testWidgets('reduce-motion swaps in the no-transitions builder',
      (tester) async {
    final scope = await TestScope.create();
    addTearDown(scope.db.close);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: ProviderScope(
          overrides: scope.overrides,
          child: const MylariumApp(),
        ),
      ),
    );
    await tester.pump();

    final theme = tester.widget<MaterialApp>(find.byType(MaterialApp)).theme!;
    expect(
      theme.pageTransitionsTheme.builders[TargetPlatform.android],
      isA<NoTransitionsBuilder>(),
    );
  });
}
