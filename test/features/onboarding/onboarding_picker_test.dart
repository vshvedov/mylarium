import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mylarium/app/theme/app_theme.dart';
import 'package:mylarium/app/theme/theme_controller.dart' show appDatabaseProvider;
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/features/onboarding/onboarding_screen.dart';

Widget _harness({List<Override> overrides = const []}) {
  final router = GoRouter(
    initialLocation: '/onboarding',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const Scaffold(body: Text('HOME')),
      ),
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
  // The real app always mounts onboarding under the root ProviderScope (the
  // ephemeral-storage banner reads a provider); mirror that here.
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(theme: lightTheme, routerConfig: router),
  );
}

void main() {
  testWidgets('picker lists all three sources with none coming-soon',
      (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await tester.pumpWidget(_harness(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    ));
    await tester.pumpAndSettle();

    expect(find.text('Komga'), findsOneWidget);
    expect(find.text('Kavita'), findsOneWidget);
    expect(find.text('Local files'), findsOneWidget);

    // All three sources are connectable; no coming-soon chips.
    expect(find.text('Soon'), findsNothing);
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

  testWidgets('tapping Local files creates the source and navigates home',
      (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await tester.pumpWidget(_harness(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Local files'));
    await tester.pumpAndSettle();

    // Navigates to home; the local source row was created.
    expect(find.text('HOME'), findsOneWidget);
    expect(await db.localFilesSource(), isNotNull);
  });
}
