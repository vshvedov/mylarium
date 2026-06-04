import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';

import 'app/app.dart';
import 'app/theme/theme_controller.dart';
import 'core/db/database.dart';

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
  runApp(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        initialSettingsProvider.overrideWithValue(settings),
      ],
      child: const MylariumApp(),
    ),
  );
}
