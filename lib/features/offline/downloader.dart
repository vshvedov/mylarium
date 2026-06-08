import 'package:background_downloader/background_downloader.dart';

/// A download lifecycle update for a task, from the [Downloader] seam's global
/// stream (so updates for tasks that resume after an app restart are handled).
enum DownloadEventKind { progress, complete, failed }

class DownloadUpdate {
  const DownloadUpdate(
    this.taskId,
    this.kind, {
    this.progress = 0,
    this.totalBytes,
    this.error,
  });

  final String taskId;
  final DownloadEventKind kind;
  final double progress; // 0..1 when known
  final int? totalBytes;
  final String? error;
}

/// Seam over the platform background-download service. A SINGLE global [updates]
/// stream carries events for every task (including ones resumed natively after
/// a restart); [enqueue] starts a task that persists across app launches. Files
/// are written under applicationSupport at [relativeDirectory]/[filename].
abstract class Downloader {
  Stream<DownloadUpdate> get updates;

  Future<void> enqueue({
    required String taskId,
    required String url,
    required Map<String, String> headers,
    required String relativeDirectory,
    required String filename,
    required bool requiresWifi,
  });

  Future<void> cancel(String taskId);

  /// Recovers downloads after the app returns from the background. Flushes
  /// status/progress updates that the platform recorded while the app was
  /// suspended, resumes tasks the OS paused (e.g. on device sleep / Doze), and
  /// re-enqueues tasks the OS killed but that the platform still has on record.
  /// Called on every foreground return so a download is never left stuck.
  Future<void> recoverPending();
}

/// Real [Downloader] backed by `background_downloader`. Resumable, Wi-Fi-aware,
/// survives app restarts: `trackTasks` persists tasks and re-emits their updates
/// on the global stream after relaunch. Not exercised in tests (platform
/// channels); verified on device.
class BackgroundDownloaderAdapter implements Downloader {
  BackgroundDownloaderAdapter() {
    // Persist tasks and mark fully-downloaded ones complete on resume.
    FileDownloader().trackTasks();
  }

  @override
  Stream<DownloadUpdate> get updates =>
      FileDownloader().updates.map((u) {
        final taskId = u.task.taskId;
        if (u is TaskStatusUpdate) {
          return switch (u.status) {
            TaskStatus.complete =>
              DownloadUpdate(taskId, DownloadEventKind.complete),
            TaskStatus.failed ||
            TaskStatus.canceled ||
            TaskStatus.notFound =>
              DownloadUpdate(taskId, DownloadEventKind.failed,
                  error: u.status.name),
            _ => DownloadUpdate(taskId, DownloadEventKind.progress),
          };
        }
        if (u is TaskProgressUpdate) {
          return DownloadUpdate(
            taskId,
            DownloadEventKind.progress,
            progress: u.progress < 0 ? 0 : u.progress,
            totalBytes: u.hasExpectedFileSize ? u.expectedFileSize : null,
          );
        }
        return DownloadUpdate(taskId, DownloadEventKind.progress);
      });

  @override
  Future<void> enqueue({
    required String taskId,
    required String url,
    required Map<String, String> headers,
    required String relativeDirectory,
    required String filename,
    required bool requiresWifi,
  }) async {
    await FileDownloader().enqueue(DownloadTask(
      taskId: taskId,
      url: url,
      headers: headers,
      filename: filename,
      directory: relativeDirectory,
      baseDirectory: BaseDirectory.applicationSupport,
      updates: Updates.statusAndProgress,
      requiresWiFi: requiresWifi,
      allowPause: true,
      retries: 3,
    ));
  }

  @override
  Future<void> cancel(String taskId) =>
      FileDownloader().cancelTaskWithId(taskId);

  @override
  Future<void> recoverPending() async {
    // Flush updates (incl. a `complete` that fired natively) accrued while
    // suspended, then revive paused tasks, then re-enqueue OS-killed ones.
    // `rescheduleKilledTasks` requires tracking, which the constructor enables.
    await FileDownloader().resumeFromBackground();
    await FileDownloader().resumeAll();
    await FileDownloader().rescheduleKilledTasks();
  }
}
