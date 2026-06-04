import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/home/home_screen.dart';

final appRouterProvider = Provider<GoRouter>(
  (_) => GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(child: Text('Route not found: ${state.uri}')),
    ),
  ),
);
