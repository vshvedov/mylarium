import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/theme/app_theme.dart';

void main() {
  testWidgets('the bespoke transition fades and scales the incoming route', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: darkTheme,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const Scaffold(body: Text('SECOND')),
                  ),
                ),
                child: const Text('GO'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('GO'));
    await tester.pump(); // start the transition
    await tester.pump(const Duration(milliseconds: 50)); // mid-transition

    expect(find.byType(FadeTransition), findsWidgets);
    expect(find.byType(ScaleTransition), findsWidgets);
    expect(tester.takeException(), isNull);

    await tester.pumpAndSettle();
    expect(find.text('SECOND'), findsOneWidget);
  });
}
