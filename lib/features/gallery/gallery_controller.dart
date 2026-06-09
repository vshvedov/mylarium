import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../app/theme/theme_controller.dart' show appDatabaseProvider;
import '../../core/db/database.dart';
import '../../core/fs/app_paths.dart';
import '../../core/fs/backup_exclusion.dart';
import '../../core/security/app_lock.dart';
import '../offline/offline_providers.dart';
import 'capture_models.dart';

part 'gallery_controller.g.dart';

/// Reads and writes page captures: the PNG on disk plus its [Captures] row. The
/// file is written first; if that fails, no row is inserted (no orphan row), and
/// a partially-written file is cleaned up. Only relative paths are persisted; the
/// absolute path is resolved per install when reading.
class CapturesRepository {
  CapturesRepository(this._db);

  final AppDatabase _db;

  /// Persists a capture: writes the PNG, excludes it from backup, stamps the
  /// owning library (for lock-aware filtering) and a device-clock timestamp, then
  /// inserts the row. Returns the resolved [Capture]. Rethrows on write failure
  /// so the caller can surface it.
  Future<Capture> save({
    required String sourceId,
    required String seriesId,
    required String bookId,
    String? bookTitle,
    required int pageNumber,
    required Uint8List pngBytes,
    required int width,
    required int height,
  }) async {
    final id = const Uuid().v4();
    final rel = AppPaths.captureRelativePath(sourceId, bookId, id);
    final file = await AppPaths.prepareFile(rel);
    try {
      await file.writeAsBytes(pngBytes, flush: true);
    } catch (_) {
      try {
        await file.delete();
      } catch (_) {
        // Best-effort cleanup; nothing was inserted.
      }
      rethrow;
    }
    await BackupExclusion.exclude(file.path);
    final libraryId = await _db.bookLibraryId(sourceId, bookId);
    final seriesTitle = await _db.seriesTitle(sourceId, seriesId);
    final capturedAt = DateTime.now().millisecondsSinceEpoch;
    await _db.insertCapture(CapturesCompanion.insert(
      id: id,
      sourceId: sourceId,
      seriesId: seriesId,
      bookId: bookId,
      libraryId: Value(libraryId),
      seriesTitle: Value(seriesTitle),
      bookTitle: Value(bookTitle),
      pageNumber: pageNumber,
      relativePath: rel,
      width: width,
      height: height,
      capturedAt: capturedAt,
    ));
    final root = await AppPaths.resolve('');
    return Capture(
      id: id,
      sourceId: sourceId,
      seriesId: seriesId,
      bookId: bookId,
      libraryId: libraryId,
      seriesTitle: seriesTitle,
      bookTitle: bookTitle,
      pageNumber: pageNumber,
      relativePath: rel,
      absolutePath: p.join(root, rel),
      width: width,
      height: height,
      capturedAt: capturedAt,
    );
  }

  /// All captures, newest first, each with its absolute path resolved (the
  /// install root is resolved once per emission, not per row).
  Stream<List<Capture>> watch() =>
      _db.watchCaptures().asyncMap((rows) async {
        final root = await AppPaths.resolve('');
        return [
          for (final r in rows)
            Capture.fromRow(r, p.join(root, r.relativePath)),
        ];
      });

  /// Deletes a capture's row and its PNG file (file removal is best-effort).
  Future<void> delete(String id) async {
    final row = await _db.getCapture(id);
    await _db.deleteCapture(id);
    if (row != null) {
      final abs = await AppPaths.resolve(row.relativePath);
      try {
        await File(abs).delete();
      } catch (_) {
        // Already gone or unreadable; the row is what matters.
      }
    }
  }
}

@riverpod
CapturesRepository capturesRepository(Ref ref) =>
    CapturesRepository(ref.watch(appDatabaseProvider));

/// All saved captures for the gallery, newest first, with captures whose library
/// is currently locked filtered out (mirrors the app-wide lock model). Re-emits
/// when a library is locked/unlocked.
@riverpod
Stream<List<Capture>> captures(Ref ref) async* {
  final lock = await ref.watch(appLockProvider.future);
  yield* ref
      .watch(capturesRepositoryProvider)
      .watch()
      .map((list) => [
            for (final c in list)
              if (!lock.isLocked(c.libraryId)) c,
          ]);
}

/// A single capture by id (with its absolute path resolved), or null if it no
/// longer exists. Drives the capture viewer.
@riverpod
Future<Capture?> captureById(Ref ref, String id) async {
  final row = await ref.watch(appDatabaseProvider).getCapture(id);
  if (row == null) return null;
  final root = await AppPaths.resolve('');
  return Capture.fromRow(row, p.join(root, row.relativePath));
}

/// Whether the chapter a capture came from can still be opened, so the viewer
/// knows whether to offer "Go to page". True when the book is still in the
/// catalog OR a cached offline archive is present; false when the chapter was
/// deleted (book purged / source removed / local file gone with nothing left).
@riverpod
Future<bool> captureChapterAvailable(
  Ref ref,
  String sourceId,
  String bookId,
) async {
  final book = await ref.watch(appDatabaseProvider).getBook(sourceId, bookId);
  if (book != null) return true;
  final archive =
      await ref.watch(offlineCacheManagerProvider).archivePath(sourceId, bookId);
  return archive != null;
}
