import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mylarium/app/theme/app_theme.dart';
import 'package:mylarium/features/onboarding/onboarding_screen.dart';

Widget _harness() {
  final router = GoRouter(
    initialLocation: '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (_, _) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/onboarding/komga',
        builder: (_, _) => const Scaffold(body: Text('KOMGA FORM')),
      ),
      GoRoute(
        path: '/onboarding/kavita',
        builder: (_, _) => const Scaffold(body: Text('KAVITA FORM')),
      ),
    ],
  );
  return MaterialApp.router(theme: lightTheme, routerConfig: router);
}

void main() {
  testWidgets('picker lists the three sources with Komga and Kavita connectable',
      (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    expect(find.text('Komga'), findsOneWidget);
    expect(find.text('Kavita'), findsOneWidget);
    expect(find.text('Local files'), findsOneWidget);

    // Only Local files is coming-soon now; Komga and Kavita are connectable.
    expect(find.text('Soon'), findsOneWidget);
  });

  testWidgets('tapping Komga opens the connect form', (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Komga'));
    await tester.pumpAndSettle();

    expect(find.text('KOMGA FORM'), findsOneWidget);
  });

  testWidgets('tapping Kavita opens the Kavita connect form', (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Kavita'));
    await tester.pumpAndSettle();

    expect(find.text('KAVITA FORM'), findsOneWidget);
  });

  testWidgets('coming-soon sources do not navigate', (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Local files'));
    await tester.pumpAndSettle();

    // Still on the picker; no connect form opened.
    expect(find.text('KOMGA FORM'), findsNothing);
    expect(find.text('KAVITA FORM'), findsNothing);
    expect(find.text('Local files'), findsOneWidget);
  });
}
