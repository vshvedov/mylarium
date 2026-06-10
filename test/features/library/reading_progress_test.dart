import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/theme/app_theme.dart';
import 'package:mylarium/features/library/widgets/reading_progress.dart';

Widget _host(Widget child) => MaterialApp(
      theme: lightTheme,
      home: Scaffold(
        body: Center(child: SizedBox(width: 156, child: child)),
      ),
    );

void main() {
  testWidgets('renders the caption and the bar at the page fraction',
      (tester) async {
    await tester.pumpWidget(
        _host(const ReadingProgressLabel(current: 2, total: 10)));
    await tester.pumpAndSettle();

    expect(find.text('p. 2 of 10'), findsOneWidget);
    final fill = tester.widget<FractionallySizedBox>(
      find.descendant(
        of: find.byType(ReadingProgressBar),
        matching: find.byType(FractionallySizedBox),
      ),
    );
    expect(fill.widthFactor, closeTo(0.2, 0.0001));
  });

  testWidgets('clamps a current page past the page count to the last page',
      (tester) async {
    await tester.pumpWidget(
        _host(const ReadingProgressLabel(current: 12, total: 10)));
    await tester.pumpAndSettle();

    expect(find.text('p. 10 of 10'), findsOneWidget);
  });

  testWidgets('renders nothing when the page count is missing',
      (tester) async {
    await tester.pumpWidget(
        _host(const ReadingProgressLabel(current: 2, total: 0)));
    await tester.pumpAndSettle();

    expect(find.byType(ReadingProgressBar), findsNothing);
    expect(find.textContaining('p. '), findsNothing);
  });

  testWidgets('renders nothing when the current page is not positive',
      (tester) async {
    await tester.pumpWidget(
        _host(const ReadingProgressLabel(current: 0, total: 10)));
    await tester.pumpAndSettle();

    expect(find.byType(ReadingProgressBar), findsNothing);
    expect(find.textContaining('p. '), findsNothing);
  });
}
