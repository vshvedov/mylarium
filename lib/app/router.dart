import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/home/home_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/sources/debug_sources_screen.dart';

/// The route the app boots to. Overridden in main() to `/onboarding` when no
/// source exists yet, else `/`. Throws until overridden so a missing override
/// fails loudly rather than silently defaulting.
final initialLocationProvider = Provider<String>(
  (_) => throw UnimplementedError('override initialLocationProvider in main'),
);

final appRouterProvider = Provider<GoRouter>(
  (ref) => GoRouter(
    initialLocation: ref.watch(initialLocationProvider),
    routes: [
      GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (_, state) =>
            OnboardingScreen(initialUrl: state.uri.queryParameters['url']),
      ),
      GoRoute(
        path: '/debug/sources',
        builder: (_, _) => const DebugSourcesScreen(),
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(child: Text('Route not found: ${state.uri}')),
    ),
  ),
);
