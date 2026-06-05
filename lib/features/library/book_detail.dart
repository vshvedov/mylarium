import 'package:flutter/material.dart';
import '../../app/theme/app_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/theme_controller.dart' show appDatabaseProvider;
import '../../core/db/database.dart';
import '../integrations/comic_vine/comic_vine_panel.dart';
import '../offline/offline_providers.dart';
import 'widgets/detail_header.dart';

/// Book detail: a cover-forward hero (cover over its own blurred art), the
/// metadata, a Read action that opens the reader, and the offline control.
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
    final bookAsync = ref.watch(_bookProvider((sourceId, bookId)));
    final book = bookAsync.valueOrNull;
    final readPage = book?.readPage ?? 0;
    final percent = (book != null && book.pagesCount > 0 && readPage > 0)
        ? (readPage / book.pagesCount * 100).clamp(0, 100).round()
        : null;

    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: DetailHeader(
                      sourceId: sourceId,
                      ownerType: 'book',
                      ownerId: bookId,
                      title: book?.title ?? 'Book',
                      pills: [
                        if (book != null && book.number.isNotEmpty)
                          DetailPill('No. ${book.number}'),
                        if (book != null && book.pagesCount > 0)
                          DetailPill('${book.pagesCount} pages'),
                        if (percent != null)
                          DetailPill('$percent% read', accent: true),
                      ],
                      actions: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          HeroAction(
                            label: readPage > 0 ? 'Continue reading' : 'Read',
                            icon: AppIcons.read,
                            onPressed: () =>
                                context.push('/reader/$sourceId/$bookId'),
                          ),
                          const SizedBox(height: 12),
                          _DownloadControl(sourceId: sourceId, bookId: bookId),
                        ],
                      ),
                      details: ComicVineDetailsPanel(
                        ownerKind: 'book',
                        sourceId: sourceId,
                        ownerId: bookId,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SafeArea(top: false, child: SizedBox(height: 28)),
                  ),
                ],
              ),
            ),
          ),
          const Positioned(top: 0, left: 4, child: HeroBackButton()),
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
        return _StatusRow(
          icon: AppIcons.downloaded,
          label: 'Downloaded',
          action: HeroAction(
            label: 'Remove',
            icon: AppIcons.delete,
            style: HeroActionStyle.ghost,
            compact: true,
            onPressed: () => cache.delete(sourceId, bookId),
          ),
        );
      }
      return _StatusRow(
        icon: AppIcons.savedOffline,
        label: 'Saved offline',
        action: HeroAction(
          label: 'Keep',
          icon: AppIcons.download,
          style: HeroActionStyle.ghost,
          compact: true,
          onPressed: () => manager.enqueueBook(sourceId, bookId, manual: true),
        ),
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
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(value: frac, minHeight: 6),
            ),
          ),
          const SizedBox(width: 12),
          const Text('Downloading...'),
        ],
      );
    }

    return HeroAction(
      label: state == 'failed' ? 'Retry download' : 'Download',
      icon: AppIcons.download,
      style: HeroActionStyle.ghost,
      onPressed: () => manager.enqueueBook(sourceId, bookId, manual: true),
    );
  }
}

/// A cached-state row: a status icon and label on the left, an action on the
/// right (Remove / Keep).
class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.icon,
    required this.label,
    required this.action,
  });

  final IconData icon;
  final String label;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: scheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ),
        action,
      ],
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
