import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';

import 'app/app.dart';
import 'app/router.dart';
import 'app/theme/theme_controller.dart';
import 'core/db/database.dart';
import 'features/offline/offline_providers.dart';
import 'features/sync/sync_providers.dart';

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
  // Reconcile read-progress with Komga and flush any queued write-backs on
  // launch; flush again whenever the app returns to the foreground.
  unawaited(_runLaunchSync(container));
  WidgetsBinding.instance.addObserver(_SyncLifecycleObserver(container));
}

Future<void> _runLaunchSync(ProviderContainer container) async {
  try {
    final engine = await container.read(syncEngineProvider.future);
    // Push local progress up first so reconcile pulls a server state that
    // already reflects this device's truth, then pull any off-device deltas.
    await engine.flushQueue();
    await engine.reconcile();
  } catch (_) {
    // Offline / unreachable: flush and reconcile retry on the next trigger.
  }
}

/// Flushes the Komga write-back queue when the app returns to the foreground.
class _SyncLifecycleObserver with WidgetsBindingObserver {
  _SyncLifecycleObserver(this._container);

  final ProviderContainer _container;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    _container
        .read(syncEngineProvider.future)
        .then((e) => e.flushQueue())
        .catchError((Object _) {});
  }
}
