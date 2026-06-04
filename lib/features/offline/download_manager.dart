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

  /// Enqueues a book for offline download. Idempotent: no-ops when already
  /// cached or a non-failed task exists, or when the source/credential is
  /// missing. Never throws (network errors write a `failed` row instead).
  Future<void> enqueueBook(
    String sourceId,
    String bookId, {
    bool pin = false,
  }) async {
    try {
      if (await _db.getCachedAsset(sourceId, bookId) != null) return;
      final existing = await _db.getDownloadTask(sourceId, bookId);
      if (existing != null && existing.state != 'failed') return;

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

      final rel = AppPaths.archiveRelativePath(sourceId, bookId);
      final taskId = _taskId(sourceId, bookId);
      await _db.upsertDownloadTask(DownloadTasksCompanion(
        sourceId: Value(sourceId),
        bookId: Value(bookId),
        taskId: Value(taskId),
        state: const Value('enqueued'),
        requiresWifi: const Value(true),
        updatedAt: Value(_now()),
      ));

      _run(
        sourceId: sourceId,
        bookId: bookId,
        taskId: taskId,
        url: '$baseUrl/api/v1/books/$bookId/file',
        headers: credential.toAuth().headers(),
        relativePath: rel,
        pin: pin,
      );
    } catch (_) {
      await _markFailed(sourceId, bookId);
    }
  }

  void _run({
    required String sourceId,
    required String bookId,
    required String taskId,
    required String url,
    required Map<String, String> headers,
    required String relativePath,
    required bool pin,
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
          // T5 always requires Wi-Fi; a user toggle (persisted in the row's
          // requiresWifi column) is a follow-up.
          requiresWifi: true,
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
              await _complete(sourceId, bookId, taskId, relativePath, pin);
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
    bool pin,
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
        updatedAt: Value(_now()),
      ));
      await _db.upsertCachedAsset(CachedAssetsCompanion(
        sourceId: Value(sourceId),
        bookId: Value(bookId),
        kind: const Value('archive'),
        relativePath: Value(relativePath),
        sizeBytes: Value(size),
        lastAccessedAt: Value(_now()),
        pinned: Value(pin),
      ));
    });
    await _onAssetAdded?.call();
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

  /// Re-enqueues every unfinished task on launch.
  Future<void> resumeAll() async {
    for (final task in await _db.unfinishedDownloadTasks()) {
      await enqueueBook(task.sourceId, task.bookId);
    }
  }
}
