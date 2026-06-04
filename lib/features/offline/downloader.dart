import 'dart:async';

import 'package:background_downloader/background_downloader.dart';

/// A download lifecycle event from the [Downloader] seam.
enum DownloadEventKind { progress, complete, failed }

class DownloadEvent {
  const DownloadEvent(
    this.kind, {
    this.progress = 0,
    this.totalBytes,
    this.error,
  });

  final DownloadEventKind kind;

  /// 0..1 fraction (when known).
  final double progress;
  final int? totalBytes;
  final String? error;
}

/// Seam over the platform background-download service so [DownloadManager] is
/// testable without platform channels. Files are written under
/// applicationSupport at [relativeDirectory]/[filename].
abstract class Downloader {
  Stream<DownloadEvent> download({
    required String taskId,
    required String url,
    required Map<String, String> headers,
    required String relativeDirectory,
    required String filename,
    required bool requiresWifi,
  });

  Future<void> cancel(String taskId);
}

/// Real [Downloader] backed by `background_downloader` (resumable, Wi-Fi-aware,
/// survives app restarts). Not exercised in tests (platform channels); verified
/// on device.
class BackgroundDownloaderAdapter implements Downloader {
  BackgroundDownloaderAdapter() {
    // Track tasks so they can resume across launches.
    FileDownloader().trackTasks();
  }

  @override
  Stream<DownloadEvent> download({
    required String taskId,
    required String url,
    required Map<String, String> headers,
    required String relativeDirectory,
    required String filename,
    required bool requiresWifi,
  }) {
    final controller = StreamController<DownloadEvent>();
    final task = DownloadTask(
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
    );

    FileDownloader().download(
      task,
      onProgress: (p) => controller.add(
          DownloadEvent(DownloadEventKind.progress, progress: p)),
      onStatus: (status) {
        switch (status) {
          case TaskStatus.complete:
            controller.add(const DownloadEvent(DownloadEventKind.complete));
          case TaskStatus.failed:
          case TaskStatus.canceled:
          case TaskStatus.notFound:
            controller.add(DownloadEvent(DownloadEventKind.failed,
                error: status.name));
          case TaskStatus.enqueued:
          case TaskStatus.running:
          case TaskStatus.waitingToRetry:
          case TaskStatus.paused:
            break;
        }
      },
    ).whenComplete(controller.close);

    return controller.stream;
  }

  @override
  Future<void> cancel(String taskId) =>
      FileDownloader().cancelTaskWithId(taskId);
}
