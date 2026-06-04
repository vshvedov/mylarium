import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/theme/app_theme.dart';
import 'package:mylarium/features/stats/stats_models.dart';
import 'package:mylarium/features/stats/wrap_card.dart';

void main() {
  testWidgets('wrap card renders the year and headline totals', (tester) async {
    const summary = StatsSummary(
      totalPages: 1234,
      totalSeconds: 7200,
      booksCompleted: 7,
      sessionCount: 20,
      streakDays: 5,
      avgPagesPerSession: 60,
      avgSecondsPerSession: 360,
      pagesOverTime: [],
      bySeries: [],
      byGenre: [Breakdown(key: 'Action', pages: 800, seconds: 0, sessions: 10)],
      byPublisher: [],
      byFormat: [],
      heatmap: {},
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: lightTheme,
        home: const Scaffold(body: WrapCard(year: 2026, summary: summary)),
      ),
    );

    expect(find.text('2026 in review'), findsOneWidget);
    expect(find.text('1234'), findsOneWidget); // pages read
    expect(find.text('7'), findsOneWidget); // books finished
    expect(find.text('Action'), findsOneWidget); // top genre
  });
}
