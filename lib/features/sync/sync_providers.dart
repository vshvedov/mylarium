import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/theme/theme_controller.dart' show appDatabaseProvider;
import '../../data/source/source_providers.dart';
import '../stats/stats_repository.dart';
import 'sync_engine.dart';

part 'sync_providers.g.dart';

/// The stable per-install device id, generated once on first settings read.
/// Stamped on local reading sessions (forward-compat for phase-2 dedup).
@Riverpod(keepAlive: true)
Future<String> deviceId(Ref ref) async {
  final settings = await ref.watch(appDatabaseProvider).getOrCreateSettings();
  return settings.deviceId!;
}

/// The app-wide sync engine. keepAlive so the write-back queue and reconcile
/// outlive any reader screen. The content client is resolved lazily per call
/// (through [contentApiForProvider]), so mid-session re-auth or source deletion
/// is honored at flush/reconcile time.
@Riverpod(keepAlive: true)
Future<SyncEngine> syncEngine(Ref ref) async {
  final db = ref.watch(appDatabaseProvider);
  final id = await ref.watch(deviceIdProvider.future);
  return SyncEngine(
    db,
    (sourceId) => ref.read(contentApiForProvider(sourceId).future),
    deviceId: id,
  );
}

/// Reads-only roll-up over the reading-sessions log for the stats screen.
@riverpod
StatsRepository statsRepository(Ref ref) =>
    StatsRepository(ref.watch(appDatabaseProvider));
