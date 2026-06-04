import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/theme/app_theme.dart';
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/features/stats/stats_screen.dart';

import '../../support/test_scope.dart';

Future<void> _pump(WidgetTester tester, TestScope scope) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: scope.overrides,
      child: MaterialApp(theme: lightTheme, home: const StatsScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the empty state with no sessions', (tester) async {
    final scope = await TestScope.create();
    addTearDown(scope.db.close);
    await _pump(tester, scope);
    expect(find.text('No reading yet in this period.'), findsOneWidget);
  });

  testWidgets('renders totals when sessions exist in the period', (
    tester,
  ) async {
    final scope = await TestScope.create();
    addTearDown(scope.db.close);
    final now = DateTime.now();
    await scope.db.insertReadingSession(
      ReadingSessionsCompanion.insert(
        id: 's1',
        sourceId: 'A',
        bookId: 'b1',
        seriesId: 'serA',
        startedAt: now.millisecondsSinceEpoch,
        endedAt: now.millisecondsSinceEpoch + 600000,
        activeSeconds: 600,
        startPage: 0,
        endPage: 12,
        pagesRead: 12,
        isCompletion: const Value(true),
        deviceId: 'dev',
      ),
    );

    await _pump(tester, scope);

    expect(find.text('Pages'), findsOneWidget); // KPI label
    expect(find.text('12'), findsWidgets); // KPI value (pages)
    expect(find.text('Pages over time'), findsOneWidget); // first section
  });
}
