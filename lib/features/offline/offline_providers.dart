import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/theme/theme_controller.dart' show appDatabaseProvider;
import '../../core/archive/archive_extractor.dart';
import '../../core/db/database.dart';
import '../../core/security/app_lock.dart';
import '../../data/komga/komga_providers.dart';
import '../../data/source/source_providers.dart';
import 'download_manager.dart';
import 'downloader.dart';
import 'offline_cache.dart';

part 'offline_providers.g.dart';

@Riverpod(keepAlive: true)
ArchiveExtractor archiveExtractor(Ref ref) => const ArchiveExtractor();

/// The platform download backend. Overridden with a fake in tests.
@Riverpod(keepAlive: true)
Downloader downloader(Ref ref) => BackgroundDownloaderAdapter();

@Riverpod(keepAlive: true)
OfflineCacheManager offlineCacheManager(Ref ref) =>
    OfflineCacheManager(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
DownloadManager downloadManager(Ref ref) {
  final cache = ref.watch(offlineCacheManagerProvider);
  final manager = DownloadManager(
    db: ref.watch(appDatabaseProvider),
    downloader: ref.watch(downloaderProvider),
    credentialStore: ref.watch(komgaCredentialStoreProvider),
    apiResolver: (sourceId) =>
        ref.read(komgaApiForProvider(sourceId).future),
    onAssetAdded: cache.evictToCap,
  );
  ref.onDispose(manager.dispose);
  return manager;
}

/// The cached asset for a book (or null), reactive. Drives the per-book offline
/// indicator and Download control.
@riverpod
Stream<CachedAsset?> cachedAsset(Ref ref, String sourceId, String bookId) =>
    ref.watch(appDatabaseProvider).watchCachedAsset(sourceId, bookId);

/// Live download progress for a book.
@riverpod
Stream<DownloadProgress> downloadProgress(
  Ref ref,
  String sourceId,
  String bookId,
) =>
    ref.watch(downloadManagerProvider).watch(sourceId, bookId);

/// Books available offline for the active source, most-recent first (the
/// "Downloaded" home rail). Books in a locked library are hidden. Empty when
/// there is no active source.
@riverpod
Stream<List<Book>> downloadedBooks(Ref ref) async* {
  final sourceId = await ref.watch(activeSourceIdProvider.future);
  if (sourceId == null) {
    yield const [];
    return;
  }
  final lock = await ref.watch(appLockProvider.future);
  yield* ref.watch(appDatabaseProvider).watchDownloadedBooks(sourceId).map(
        (books) => [for (final b in books) if (!lock.isLocked(b.libraryId)) b],
      );
}

/// Live (total, downloaded) book counts for a series (the series-detail download
/// control). Reactive to both the books cache and cached assets.
@riverpod
Stream<({int total, int downloaded})> seriesDownloadStatus(
  Ref ref,
  String sourceId,
  String seriesId,
) =>
    ref.watch(appDatabaseProvider).watchSeriesDownloadCounts(sourceId, seriesId);
