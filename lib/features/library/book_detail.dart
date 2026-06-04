import 'package:flutter/material.dart';
import '../../app/theme/app_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/cover_palette.dart';
import '../../app/theme/design_tokens.dart';
import '../../app/theme/theme_controller.dart' show appDatabaseProvider;
import '../../app/widgets/app_button.dart';
import '../../core/db/database.dart';
import '../offline/offline_providers.dart';
import 'widgets/cover_image.dart';

/// Dark cinematic hero band behind the detail header (both themes).
const _heroBarColor = Color(0xFF1A1820);

/// Book detail: a cover-derived hero, the cover and metadata, then a Read action
/// that opens the reader.
class BookDetailScreen extends ConsumerWidget {
  const BookDetailScreen({
    super.key,
    required this.sourceId,
    required this.bookId,
  });

  final String sourceId;
  final String bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<DesignTokens>()!;
    final bookAsync = ref.watch(_bookProvider((sourceId, bookId)));
    final book = bookAsync.valueOrNull;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 168,
            backgroundColor: _heroBarColor,
            foregroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsetsDirectional.only(
                start: 56,
                bottom: 14,
              ),
              title: Text(
                book?.title ?? 'Book',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              background: CoverBackground(
                sourceId: sourceId,
                ownerType: 'book',
                ownerId: bookId,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 180,
                      height: 270,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(tokens.coverRadius),
                        boxShadow: tokens.elevation.hero,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(tokens.coverRadius),
                        child: CoverImage(
                          sourceId: sourceId,
                          ownerType: 'book',
                          ownerId: bookId,
                          title: book?.title ?? '',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    book?.title ?? '',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (book != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      [
                        if (book.number.isNotEmpty) 'No. ${book.number}',
                        if (book.pagesCount > 0) '${book.pagesCount} pages',
                      ].join('  -  '),
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                  const SizedBox(height: 16),
                  AppButton(
                    label: (book?.readPage ?? 0) > 0
                        ? 'Continue reading'
                        : 'Read',
                    icon: AppIcons.read,
                    onPressed: () => context.push('/reader/$sourceId/$bookId'),
                  ),
                  const SizedBox(height: 8),
                  _DownloadControl(sourceId: sourceId, bookId: bookId),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Download / offline-state control. Shows: Download (not cached), a progress
/// bar (downloading), "Saved offline" + Keep (auto-cached), or "Downloaded" +
/// remove (manual download).
class _DownloadControl extends ConsumerWidget {
  const _DownloadControl({required this.sourceId, required this.bookId});

  final String sourceId;
  final String bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asset = ref.watch(cachedAssetProvider(sourceId, bookId)).valueOrNull;
    final manager = ref.read(downloadManagerProvider);
    final cache = ref.read(offlineCacheManagerProvider);

    if (asset != null) {
      if (asset.permanent) {
        return Row(
          children: [
            const Icon(AppIcons.downloaded, size: 20),
            const SizedBox(width: 8),
            const Expanded(child: Text('Downloaded')),
            TextButton.icon(
              icon: const Icon(AppIcons.delete),
              label: const Text('Remove'),
              onPressed: () => cache.delete(sourceId, bookId),
            ),
          ],
        );
      }
      return Row(
        children: [
          const Icon(AppIcons.savedOffline, size: 20),
          const SizedBox(width: 8),
          const Expanded(child: Text('Saved offline (auto-cache)')),
          TextButton.icon(
            icon: const Icon(AppIcons.download),
            label: const Text('Keep'),
            onPressed: () =>
                manager.enqueueBook(sourceId, bookId, manual: true),
          ),
        ],
      );
    }

    final progress = ref.watch(downloadProgressProvider(sourceId, bookId));
    final state = progress.valueOrNull?.state ?? 'none';
    if (state == 'running' || state == 'enqueued') {
      final p = progress.valueOrNull;
      final frac = (p?.totalBytes ?? 0) > 0
          ? p!.bytesDownloaded / p.totalBytes!
          : null;
      return Row(
        children: [
          Expanded(child: LinearProgressIndicator(value: frac)),
          const SizedBox(width: 12),
          const Text('Downloading...'),
        ],
      );
    }

    return OutlinedButton.icon(
      icon: const Icon(AppIcons.download),
      label: Text(state == 'failed' ? 'Retry download' : 'Download'),
      onPressed: () => manager.enqueueBook(sourceId, bookId, manual: true),
    );
  }
}

/// A cached book row (the series grid refreshed it on the way in).
final _bookProvider = FutureProvider.family<Book?, (String, String)>((
  ref,
  key,
) {
  return ref.watch(appDatabaseProvider).getBook(key.$1, key.$2);
});
