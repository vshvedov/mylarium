import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';

import 'app/app.dart';
import 'app/router.dart';
import 'app/theme/theme_controller.dart';
import 'core/db/database.dart';
import 'core/platform/system_ui.dart';
import 'features/offline/offline_providers.dart';
import 'features/sync/live_sync_providers.dart';
import 'features/sync/sync_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Run edge to edge with the top status bar hidden (cover-forward fullscreen).
  unawaited(setAppFullscreen());
  // Not `late final`: the in-memory fallback reassigns these, so `final` would
  // make the fallback itself throw a LateInitializationError (crashing on the
  // splash) on any DB-open failure.
  late AppDatabase db;
  late AppSetting settings;
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
  // Open the Komga live-event stream for steady-state freshness (T1); the
  // observer keeps it connected only while the app is foregrounded.
  unawaited(container.read(liveSyncProvider.notifier).start());
  WidgetsBinding.instance.addObserver(_ForegroundObserver(container));
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

/// Runs the foreground-return reconciles: flushes the Komga write-back queue,
/// and revives any offline download the OS paused or killed while the app was
/// suspended (e.g. the device screen turned off mid-download) so it is never
/// left stuck.
class _ForegroundObserver with WidgetsBindingObserver {
  _ForegroundObserver(this._container);

  final ProviderContainer _container;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final live = _container.read(liveSyncProvider.notifier);
    // Disconnect the live stream off-foreground; reconnect (and flush) on return.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      unawaited(live.stop());
      return;
    }
    if (state != AppLifecycleState.resumed) return;
    _container
        .read(syncEngineProvider.future)
        .then((e) => e.flushQueue())
        .catchError((Object _) {});
    unawaited(_container.read(downloadManagerProvider).onAppForeground());
    unawaited(live.start());
  }
}
