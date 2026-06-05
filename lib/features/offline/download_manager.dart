// Cross-file named params cannot be private initializing formals.
// ignore_for_file: prefer_initializing_formals
import 'dart:async';
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

/// Queues background full-chapter downloads and records a CachedAsset on
/// completion. Completion/progress are handled via the [Downloader]'s GLOBAL
/// updates stream (subscribed once here), so tasks that finish or resume after
/// an app restart are still persisted - the session-bound download() future is
/// not relied upon. On launch [resumeAll] reconciles tasks whose file is already
/// fully on disk and re-enqueues the rest.
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
        _now = nowMillis ?? (() => DateTime.now().millisecondsSinceEpoch) {
    _sub = _downloader.updates.listen(_onUpdate);
  }

  final AppDatabase _db;
  final Downloader _downloader;
  final KomgaCredentialStore _credentials;
  final ApiResolver _apiResolver;
  final Future<void> Function()? _onAssetAdded;
  final int Function() _now;
  StreamSubscription<DownloadUpdate>? _sub;

  void dispose() => _sub?.cancel();

  static String _taskId(String sourceId, String bookId) => '$sourceId|$bookId';

  String _relPathFor(String sourceId, String bookId, bool permanent) =>
      permanent
          ? AppPaths.downloadRelativePath(sourceId, bookId)
          : AppPaths.archiveRelativePath(sourceId, bookId);

  /// Enqueues a book for offline download.
  ///
  /// [manual] true = an explicit user "Download": goes to the permanent
  /// downloads pool, ignores the Wi-Fi-only setting, and runs even when
  /// auto-cache is disabled. [manual] false = the on-open auto-cache: skipped
  /// when auto-cache is disabled and gated by the Wi-Fi-only setting.
  ///
  /// Idempotent: a manual request promotes an existing auto-cached copy; an
  /// existing cache or active task is otherwise a no-op. Never throws.
  Future<void> enqueueBook(
    String sourceId,
    String bookId, {
    bool manual = false,
  }) async {
    try {
      final cached = await _db.getCachedAsset(sourceId, bookId);
      if (cached != null) {
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

      if (await _db.getBook(sourceId, bookId) == null) {
        final api = await _apiResolver(sourceId);
        if (api != null) {
          try {
            await _db.upsertBook(bookToRow(sourceId, await api.getBook(bookId)));
          } on KomgaException {
            // Non-fatal.
          }
        }
      }

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

      await _enqueue(
        sourceId: sourceId,
        bookId: bookId,
        taskId: taskId,
        baseUrl: baseUrl,
        headers: credential.toAuth().headers(),
        permanent: manual,
        requiresWifi: requiresWifi,
      );
    } catch (_) {
      await _markFailed(sourceId, bookId);
    }
  }

  /// Enqueues every cached book of a series for permanent offline download
  /// (each as a manual download, so they are pinned against LRU eviction).
  Future<void> enqueueSeries(String sourceId, String seriesId) async {
    for (final b in await _db.getBooksForSeries(sourceId, seriesId)) {
      await enqueueBook(sourceId, b.id, manual: true);
    }
  }

  Future<void> _enqueue({
    required String sourceId,
    required String bookId,
    required String taskId,
    required String baseUrl,
    required Map<String, String> headers,
    required bool permanent,
    required bool requiresWifi,
  }) async {
    final rel = _relPathFor(sourceId, bookId, permanent);
    await _downloader.enqueue(
      taskId: taskId,
      url: '$baseUrl/api/v1/books/$bookId/file',
      headers: headers,
      relativeDirectory: p.dirname(rel),
      filename: p.basename(rel),
      requiresWifi: requiresWifi,
    );
  }

  /// Routes a global download update (status/progress) to its book.
  Future<void> _onUpdate(DownloadUpdate u) async {
    final task = await _db.getDownloadTaskByTaskId(u.taskId);
    if (task == null) return;
    switch (u.kind) {
      case DownloadEventKind.progress:
        await _db.upsertDownloadTask(DownloadTasksCompanion(
          sourceId: Value(task.sourceId),
          bookId: Value(task.bookId),
          taskId: Value(task.taskId),
          state: const Value('running'),
          bytesDownloaded: Value(u.totalBytes == null
              ? task.bytesDownloaded
              : (u.progress * u.totalBytes!).round()),
          totalBytes: Value(u.totalBytes ?? task.totalBytes),
          permanent: Value(task.permanent),
          updatedAt: Value(_now()),
        ));
      case DownloadEventKind.complete:
        await _complete(task.sourceId, task.bookId, task.taskId,
            _relPathFor(task.sourceId, task.bookId, task.permanent),
            task.permanent);
      case DownloadEventKind.failed:
        await _markFailed(task.sourceId, task.bookId);
    }
  }

  /// Moves an auto-cached archive into the permanent downloads pool, crash-safe
  /// (copy -> update row -> delete source), so a valid file always backs the row.
  Future<void> _promote(
      String sourceId, String bookId, CachedAsset cached) async {
    final fromAbs = await AppPaths.resolve(cached.relativePath);
    final toRel = AppPaths.downloadRelativePath(sourceId, bookId);
    final toFile = await AppPaths.prepareFile(toRel);
    final fromFile = File(fromAbs);
    if (!fromFile.existsSync()) return;
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
    if (fromFile.existsSync()) await fromFile.delete();
  }

  Future<void> _complete(
    String sourceId,
    String bookId,
    String taskId,
    String relativePath,
    bool permanent,
  ) async {
    final abs = await AppPaths.resolve(relativePath);
    final file = File(abs);
    if (!file.existsSync()) {
      // Completed signal but no file: treat as failed so it can be retried.
      await _markFailed(sourceId, bookId);
      return;
    }
    await BackupExclusion.exclude(abs);
    final size = file.lengthSync();
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
    if (!permanent) await _onAssetAdded?.call();
  }

  Future<void> _markFailed(String sourceId, String bookId) async {
    final existing = await _db.getDownloadTask(sourceId, bookId);
    await _db.upsertDownloadTask(DownloadTasksCompanion(
      sourceId: Value(sourceId),
      bookId: Value(bookId),
      taskId: Value(existing?.taskId ?? _taskId(sourceId, bookId)),
      state: const Value('failed'),
      permanent: Value(existing?.permanent ?? false),
      updatedAt: Value(_now()),
    ));
  }

  Stream<DownloadProgress> watch(String sourceId, String bookId) =>
      _db.watchDownloadTask(sourceId, bookId).map((t) => DownloadProgress(
            state: t?.state ?? 'none',
            bytesDownloaded: t?.bytesDownloaded ?? 0,
            totalBytes: t?.totalBytes,
          ));

  /// On launch: reconcile each unfinished task. If the archive is already fully
  /// on disk (downloaded while the app was dead, or completed but not yet
  /// recorded), mark it complete; otherwise re-enqueue it.
  Future<void> resumeAll() async {
    for (final task in await _db.unfinishedDownloadTasks()) {
      try {
        if (await _db.getCachedAsset(task.sourceId, task.bookId) != null) {
          continue;
        }
        final rel =
            _relPathFor(task.sourceId, task.bookId, task.permanent);
        final file = File(await AppPaths.resolve(rel));
        if (file.existsSync() && file.lengthSync() > 0) {
          await _complete(
              task.sourceId, task.bookId, task.taskId, rel, task.permanent);
          continue;
        }
        final source = await _db.getSource(task.sourceId);
        final baseUrl = source?.baseUrl;
        final credential = await _credentials.read(task.sourceId);
        if (baseUrl == null || credential == null) {
          await _markFailed(task.sourceId, task.bookId);
          continue;
        }
        await _enqueue(
          sourceId: task.sourceId,
          bookId: task.bookId,
          taskId: task.taskId,
          baseUrl: baseUrl,
          headers: credential.toAuth().headers(),
          permanent: task.permanent,
          requiresWifi: task.requiresWifi,
        );
      } catch (_) {
        await _markFailed(task.sourceId, task.bookId);
      }
    }
  }
}
