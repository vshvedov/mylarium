import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';

import 'app/app.dart';
import 'app/router.dart';
import 'app/theme/theme_controller.dart';
import 'core/db/database.dart';
import 'features/offline/offline_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  late final AppDatabase db;
  late final AppSetting settings;
  try {
    db = AppDatabase();
    settings = await db.getOrCreateSettings();
  } catch (e, st) {
    debugPrint('Mylarium: DB open failed, using in-memory fallback: $e\n$st');
    db = AppDatabase(NativeDatabase.memory());
    settings = await db.getOrCreateSettings();
  }
  // Boot into onboarding until at least one source is connected.
  final hasSource = await db.hasAnySource();
  // An explicit container so we can resume downloads after the first frame.
  final container = ProviderContainer(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      initialSettingsProvider.overrideWithValue(settings),
      initialLocationProvider
          .overrideWithValue(hasSource ? '/' : '/onboarding'),
    ],
  );
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MylariumApp(),
    ),
  );
  // Resume any unfinished offline downloads (fire-and-forget).
  unawaited(container.read(downloadManagerProvider).resumeAll());
}
