// Cross-file named params cannot be private initializing formals.
// ignore_for_file: prefer_initializing_formals
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:path/path.dart' as p;

import '../../core/db/database.dart';
import '../../core/fs/app_paths.dart';
import '../../core/fs/backup_exclusion.dart';
import '../../core/network/komga_exception.dart';
import '../../data/komga/auth/komga_credential.dart';
import '../../data/komga/komga_api.dart';
import '../../data/komga/models/mappers.dart';
import 'downloader.dart';

/// Display-facing download progress for a book.
class DownloadProgress {
  const DownloadProgress({
    required this.state,
    required this.bytesDownloaded,
    this.totalBytes,
  });

  final String state; // enqueued|running|paused|complete|failed
  final int bytesDownloaded;
  final int? totalBytes;

  bool get isComplete => state == 'complete';
}

/// Resolves a [KomgaApi] for a source (used to persist book metadata at enqueue).
typedef ApiResolver = Future<KomgaApi?> Function(String sourceId);

/// Queues and runs background full-chapter downloads, persists their state for
/// resume-on-launch, and on completion records a CachedAsset (excluded from
/// backup) atomically. Wraps the injected [Downloader] seam.
class DownloadManager {
  DownloadManager({
    required AppDatabase db,
    required Downloader downloader,
    required KomgaCredentialStore credentialStore,
    required ApiResolver apiResolver,
    Future<void> Function()? onAssetAdded,
    int Function()? nowMillis,
  })  : _db = db,
        _downloader = downloader,
        _credentials = credentialStore,
        _apiResolver = apiResolver,
        _onAssetAdded = onAssetAdded,
        _now = nowMillis ?? (() => DateTime.now().millisecondsSinceEpoch);

  final AppDatabase _db;
  final Downloader _downloader;
  final KomgaCredentialStore _credentials;
  final ApiResolver _apiResolver;
  final Future<void> Function()? _onAssetAdded;
  final int Function() _now;

  static String _taskId(String sourceId, String bookId) => '$sourceId|$bookId';

  /// Enqueues a book for offline download.
  ///
  /// [manual] true = an explicit user "Download": goes to the permanent
  /// downloads pool, ignores the Wi-Fi-only setting, and runs even when
  /// auto-cache is disabled. [manual] false = the on-open auto-cache: skipped
  /// when auto-cache is disabled and gated by the Wi-Fi-only setting.
  ///
  /// Idempotent: a manual request promotes an existing auto-cached copy to the
  /// downloads pool; otherwise an existing cache/active task is a no-op. Never
  /// throws (network errors write a `failed` row instead).
  Future<void> enqueueBook(
    String sourceId,
    String bookId, {
    bool manual = false,
  }) async {
    try {
      final cached = await _db.getCachedAsset(sourceId, bookId);
      if (cached != null) {
        // Promote an auto-cached copy to the permanent downloads pool. Isolate
        // its errors: a failed promote must NOT mark the (still-valid) cached
        // book as failed.
        if (manual && !cached.permanent) {
          try {
            await _promote(sourceId, bookId, cached);
          } catch (_) {
            // Leave the auto-cached entry intact.
          }
        }
        return;
      }
      final existing = await _db.getDownloadTask(sourceId, bookId);
      if (existing != null && existing.state != 'failed') return;

      final settings = await _db.getOrCreateSettings();
      if (!manual && !settings.autoCacheEnabled) return;

      final source = await _db.getSource(sourceId);
      final baseUrl = source?.baseUrl;
      if (baseUrl == null) return;
      final credential = await _credentials.read(sourceId);
      if (credential == null) return;

      // Persist book metadata so an offline open can resolve seriesId.
      if (await _db.getBook(sourceId, bookId) == null) {
        final api = await _apiResolver(sourceId);
        if (api != null) {
          try {
            await _db.upsertBook(bookToRow(sourceId, await api.getBook(bookId)));
          } on KomgaException {
            // Non-fatal; the download can still proceed.
          }
        }
      }

      final rel = manual
          ? AppPaths.downloadRelativePath(sourceId, bookId)
          : AppPaths.archiveRelativePath(sourceId, bookId);
      final requiresWifi = manual ? false : settings.downloadWifiOnly;
      final taskId = _taskId(sourceId, bookId);
      await _db.upsertDownloadTask(DownloadTasksCompanion(
        sourceId: Value(sourceId),
        bookId: Value(bookId),
        taskId: Value(taskId),
        state: const Value('enqueued'),
        requiresWifi: Value(requiresWifi),
        permanent: Value(manual),
        updatedAt: Value(_now()),
      ));

      _run(
        sourceId: sourceId,
        bookId: bookId,
        taskId: taskId,
        url: '$baseUrl/api/v1/books/$bookId/file',
        headers: credential.toAuth().headers(),
        relativePath: rel,
        permanent: manual,
        requiresWifi: requiresWifi,
      );
    } catch (_) {
      await _markFailed(sourceId, bookId);
    }
  }

  /// Moves an auto-cached archive into the permanent downloads pool.
  ///
  /// Crash-safe ordering: COPY to the downloads path, then update the row, then
  /// delete the source. At every step a valid file backs the row (either the
  /// archives copy, or the downloads copy), so a crash can never strand the book
  /// as "available but missing"; the worst case is a harmless orphaned file.
  Future<void> _promote(
      String sourceId, String bookId, CachedAsset cached) async {
    final fromAbs = await AppPaths.resolve(cached.relativePath);
    final toRel = AppPaths.downloadRelativePath(sourceId, bookId);
    final toFile = await AppPaths.prepareFile(toRel);
    final fromFile = File(fromAbs);
    if (!fromFile.existsSync()) return; // nothing to promote
    await fromFile.copy(toFile.path);
    await BackupExclusion.exclude(toFile.path);
    await _db.upsertCachedAsset(CachedAssetsCompanion(
      sourceId: Value(sourceId),
      bookId: Value(bookId),
      kind: Value(cached.kind),
      relativePath: Value(toRel),
      sizeBytes: Value(cached.sizeBytes),
      lastAccessedAt: Value(cached.lastAccessedAt),
      permanent: const Value(true),
    ));
    // Row now points at the downloads copy; remove the old archives copy.
    if (fromFile.existsSync()) await fromFile.delete();
  }

  void _run({
    required String sourceId,
    required String bookId,
    required String taskId,
    required String url,
    required Map<String, String> headers,
    required String relativePath,
    required bool permanent,
    required bool requiresWifi,
  }) {
    final dir = p.dirname(relativePath);
    final filename = p.basename(relativePath);
    _downloader
        .download(
          taskId: taskId,
          url: url,
          headers: headers,
          relativeDirectory: dir,
          filename: filename,
          requiresWifi: requiresWifi,
        )
        .listen(
      (event) async {
        try {
          switch (event.kind) {
            case DownloadEventKind.progress:
              final total = event.totalBytes;
              await _db.upsertDownloadTask(DownloadTasksCompanion(
                sourceId: Value(sourceId),
                bookId: Value(bookId),
                taskId: Value(taskId),
                state: const Value('running'),
                bytesDownloaded: Value(
                    total == null ? 0 : (event.progress * total).round()),
                totalBytes: Value(total),
                updatedAt: Value(_now()),
              ));
            case DownloadEventKind.complete:
              await _complete(
                  sourceId, bookId, taskId, relativePath, permanent);
            case DownloadEventKind.failed:
              await _markFailed(sourceId, bookId);
          }
        } catch (_) {
          await _markFailed(sourceId, bookId);
        }
      },
      onError: (_) => _markFailed(sourceId, bookId),
    );
  }

  Future<void> _complete(
    String sourceId,
    String bookId,
    String taskId,
    String relativePath,
    bool permanent,
  ) async {
    final abs = await AppPaths.resolve(relativePath);
    await BackupExclusion.exclude(abs);
    final file = File(abs);
    final size = file.existsSync() ? file.lengthSync() : 0;
    await _db.transaction(() async {
      await _db.upsertDownloadTask(DownloadTasksCompanion(
        sourceId: Value(sourceId),
        bookId: Value(bookId),
        taskId: Value(taskId),
        state: const Value('complete'),
        permanent: Value(permanent),
        updatedAt: Value(_now()),
      ));
      await _db.upsertCachedAsset(CachedAssetsCompanion(
        sourceId: Value(sourceId),
        bookId: Value(bookId),
        kind: const Value('archive'),
        relativePath: Value(relativePath),
        sizeBytes: Value(size),
        lastAccessedAt: Value(_now()),
        permanent: Value(permanent),
      ));
    });
    // Auto-cache downloads are subject to the cap; manual downloads are not.
    if (!permanent) await _onAssetAdded?.call();
  }

  Future<void> _markFailed(String sourceId, String bookId) async {
    final existing = await _db.getDownloadTask(sourceId, bookId);
    await _db.upsertDownloadTask(DownloadTasksCompanion(
      sourceId: Value(sourceId),
      bookId: Value(bookId),
      taskId: Value(existing?.taskId ?? _taskId(sourceId, bookId)),
      state: const Value('failed'),
      updatedAt: Value(_now()),
    ));
  }

  Stream<DownloadProgress> watch(String sourceId, String bookId) =>
      _db.watchDownloadTask(sourceId, bookId).map((t) => DownloadProgress(
            state: t?.state ?? 'none',
            bytesDownloaded: t?.bytesDownloaded ?? 0,
            totalBytes: t?.totalBytes,
          ));

  /// Re-runs FAILED tasks on launch, honoring each task's stored pool
  /// (auto/manual) and Wi-Fi requirement. Running/enqueued/paused tasks are left
  /// to background_downloader's own tracking (configured via trackTasks), which
  /// resumes them natively; re-enqueuing those would duplicate the task.
  Future<void> resumeAll() async {
    for (final task in await _db.unfinishedDownloadTasks()) {
      if (task.state == 'failed') await _resume(task);
    }
  }

  Future<void> _resume(DownloadTask task) async {
    try {
      if (await _db.getCachedAsset(task.sourceId, task.bookId) != null) return;
      final source = await _db.getSource(task.sourceId);
      final baseUrl = source?.baseUrl;
      final credential = await _credentials.read(task.sourceId);
      if (baseUrl == null || credential == null) {
        await _markFailed(task.sourceId, task.bookId);
        return;
      }
      final rel = task.permanent
          ? AppPaths.downloadRelativePath(task.sourceId, task.bookId)
          : AppPaths.archiveRelativePath(task.sourceId, task.bookId);
      _run(
        sourceId: task.sourceId,
        bookId: task.bookId,
        taskId: task.taskId,
        url: '$baseUrl/api/v1/books/${task.bookId}/file',
        headers: credential.toAuth().headers(),
        relativePath: rel,
        permanent: task.permanent,
        requiresWifi: task.requiresWifi,
      );
    } catch (_) {
      await _markFailed(task.sourceId, task.bookId);
    }
  }
}
