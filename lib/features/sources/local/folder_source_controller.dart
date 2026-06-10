import 'dart:io' show File;

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saf_util/saf_util.dart';
import 'package:uuid/uuid.dart';

import '../../../app/theme/theme_controller.dart' show appDatabaseProvider;
import '../../../core/db/database.dart';
import '../../../core/fs/app_paths.dart';
import '../../../core/platform/storage_volumes.dart';
import '../../../data/local/tree_fs.dart';
import '../../../data/local/tree_scanner.dart';
import '../../../data/source/content_source.dart';

part 'folder_source_controller.g.dart';

/// Mounted removable volumes (SD cards), for the dedicated "use SD card"
/// shortcut. Android-only by nature; empty elsewhere. Probed once per app run
/// (mount changes are picked up on the next launch or sheet reopen via
/// [ref.invalidate]).
@riverpod
Future<List<RemovableVolume>> removableVolumes(Ref ref) =>
    const StorageVolumes().removable();

/// The production tree filesystem (Android SAF).
@riverpod
TreeFs treeFs(Ref ref) => SafTreeFs();

@riverpod
TreeScanner treeScanner(Ref ref) =>
    TreeScanner(ref.watch(appDatabaseProvider), ref.watch(treeFsProvider));

/// Whether a folder source's tree root is currently reachable (card mounted,
/// permission intact). Drives the non-blocking offline banner; manual refresh
/// via [ref.invalidate] (first cut: no live mount watching).
@riverpod
Future<bool> treeSourceOnline(Ref ref, String sourceId) async {
  final source = await ref.watch(appDatabaseProvider).getSource(sourceId);
  final handle = source?.handle;
  if (handle == null) return false;
  return ref.watch(treeFsProvider).exists(handle, isDir: true);
}

/// Lifecycle states of one folder source's scan.
sealed class FolderScanState {
  const FolderScanState();
}

class FolderScanIdle extends FolderScanState {
  const FolderScanIdle();
}

class FolderScanRunning extends FolderScanState {
  const FolderScanRunning(this.progress);
  final ScanProgress progress;
}

class FolderScanDone extends FolderScanState {
  const FolderScanDone(this.result);
  final RescanResult result;
}

/// Drives scanning/rescanning one folder source. keepAlive so a scan survives
/// navigating away from the home surface; per-source family.
@Riverpod(keepAlive: true)
class FolderScanController extends _$FolderScanController {
  bool _cancelRequested = false;
  bool _running = false;

  @override
  FolderScanState build(String sourceId) => const FolderScanIdle();

  /// Starts a scan/rescan pass (no-op while one is running).
  Future<void> rescan() async {
    if (_running) return;
    _running = true;
    _cancelRequested = false;
    final db = ref.read(appDatabaseProvider);
    final source = await db.getSource(sourceId);
    if (source == null) {
      _running = false;
      return;
    }
    final scanner = ref.read(treeScannerProvider);
    var added = 0, updated = 0;
    try {
      await for (final p
          in scanner.scan(source, isCancelled: () => _cancelRequested)) {
        added = p.added;
        updated = p.updated;
        if (p.done) {
          state = FolderScanDone(RescanResult(
            added: p.added,
            updated: p.updated,
            removed: 0,
            cancelled: p.cancelled,
          ));
        } else {
          state = FolderScanRunning(p);
        }
      }
    } catch (_) {
      // A failed pass (e.g. card ejected mid-scan) keeps whatever reconciled;
      // the offline banner explains the situation.
      state = FolderScanDone(RescanResult(
        added: added,
        updated: updated,
        removed: 0,
        cancelled: true,
      ));
    } finally {
      _running = false;
    }
  }

  void cancel() => _cancelRequested = true;
}

/// Add-folder-source flow + folder source management (rename, relink, remove).
class FolderSourceService {
  FolderSourceService(this._db, {SafUtil? saf, String Function()? newId})
      : _saf = saf ?? SafUtil(),
        _newId = newId ?? (() => const Uuid().v4());

  final AppDatabase _db;
  final SafUtil _saf;
  final String Function() _newId;

  /// Opens the SAF folder picker (rooted at [initialUri] when given, e.g. an
  /// SD card root) and creates the safTree Sources row with a persisted read
  /// permission. Returns the new source id, or null when the user cancelled.
  Future<String?> addFolderSource({String? initialUri}) async {
    final picked = await _saf.pickDirectory(
      initialUri: initialUri,
      writePermission: false,
      persistablePermission: true,
    );
    if (picked == null) return null;
    final id = _newId();
    await _db.upsertSource(SourcesCompanion(
      id: Value(id),
      kind: Value(SourceKind.safTree.name),
      handle: Value(picked.uri),
      label: Value(picked.name.isEmpty ? 'Folder' : picked.name),
    ));
    return id;
  }

  /// Re-picks the tree for an existing source (the offline-recovery relink):
  /// updates the handle IN PLACE so rows, state, and stats stay attached.
  /// Returns true when a folder was picked.
  Future<bool> relink(Source source) async {
    final picked = await _saf.pickDirectory(
      initialUri: source.handle,
      writePermission: false,
      persistablePermission: true,
    );
    if (picked == null) return false;
    await _db.updateSourceHandle(source.id, picked.uri);
    return true;
  }

  /// Removes a folder source: its rows and thumbnails go (the on-card files
  /// are untouched; this is a read-only view), reading history is kept, and
  /// the persisted tree permission is released.
  Future<void> removeFolderSource(Source source) async {
    for (final t in await _db.thumbnailsForSource(source.id)) {
      final diskPath = t.diskPath;
      if (diskPath == null) continue;
      try {
        final f = File(await AppPaths.resolve(diskPath));
        if (await f.exists()) await f.delete();
      } on Object {
        // Best-effort file cleanup.
      }
    }
    await _db.deleteThumbnailsForSource(source.id);
    await _db.deleteLocalComicsForSource(source.id);
    await _db.deleteSource(source.id);
    final handle = source.handle;
    if (handle != null) {
      try {
        await _saf.releasePersistedPermission(handle);
      } on Object {
        // Releasing a permission the OS already dropped is fine.
      }
    }
  }
}

@riverpod
FolderSourceService folderSourceService(Ref ref) =>
    FolderSourceService(ref.watch(appDatabaseProvider));
