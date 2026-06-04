import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/theme/theme_controller.dart' show appDatabaseProvider;
import '../../core/archive/archive_extractor.dart';
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
  return DownloadManager(
    db: ref.watch(appDatabaseProvider),
    downloader: ref.watch(downloaderProvider),
    credentialStore: ref.watch(komgaCredentialStoreProvider),
    apiResolver: (sourceId) =>
        ref.read(komgaApiForProvider(sourceId).future),
    onAssetAdded: cache.evictToCap,
  );
}

/// Whether a book is available offline, reactive to cache changes (streams the
/// cached-asset set and maps to this book's presence).
@riverpod
Stream<bool> offlineAvailable(Ref ref, String sourceId, String bookId) {
  return ref.watch(appDatabaseProvider).watchCachedAssets().map(
        (assets) =>
            assets.any((a) => a.sourceId == sourceId && a.bookId == bookId),
      );
}
