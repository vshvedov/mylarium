import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/theme/app_theme.dart';
import 'package:mylarium/features/reader/widgets/image_quality_sheet.dart';

import '../../support/test_scope.dart';

void main() {
  testWidgets('Smart switch gates the manual slider and persists', (tester) async {
    final scope = await TestScope.create();
    addTearDown(scope.db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: scope.overrides,
        child: MaterialApp(
          theme: lightTheme,
          home: const Scaffold(body: ImageQualitySheet()),
        ),
      ),
    );

    // Defaults: Smart on, slider present but disabled.
    expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
    expect(tester.widget<Slider>(find.byType(Slider)).onChanged, isNull);

    // Turn Smart off -> slider becomes interactive.
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
    expect(tester.widget<Slider>(find.byType(Slider)).onChanged, isNotNull);

    // The choice persisted to the database.
    final settings = await scope.db.getOrCreateSettings();
    expect(settings.imageQualitySmart, isFalse);
  });
}
