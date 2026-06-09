import 'package:flutter/material.dart';
import '../../app/theme/app_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/theme_controller.dart' show appDatabaseProvider;
import '../../core/db/database.dart';
import '../../features/sync/sync_providers.dart';
import '../integrations/comic_vine/comic_vine_panel.dart';
import '../offline/offline_providers.dart';
import 'library_browse_controllers.dart';
import 'widgets/add_to_collection_sheet.dart';
import 'widgets/detail_header.dart';
import 'widgets/detail_metadata.dart';
import 'widgets/star_rating.dart';

/// Book detail: a cover-forward hero (cover over its own blurred art), the
/// metadata, a Read action that opens the reader, and the offline control. T3
/// adds mark read/unread, a local star rating, an add-to-read-list action, and
/// a richer metadata block. The completed badge / percent read from [BookState]
/// (the authoritative local state) so an optimistic mark survives a cache
/// refresh; the rich metadata comes from the live DTO (hidden offline).
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
    final book = ref.watch(_bookProvider((sourceId, bookId))).valueOrNull;
    final state = ref.watch(bookReadStateProvider(sourceId, bookId)).valueOrNull;
    final dto = ref.watch(bookDetailDtoProvider(sourceId, bookId)).valueOrNull;
    final rating = ref.watch(bookRatingProvider(sourceId, bookId)).valueOrNull;

    final pagesCount = dto?.pagesCount ?? book?.pagesCount ?? 0;
    final completed =
        state != null ? state.status == 'completed' : (book?.completed ?? false);
    final double? frac;
    if (completed) {
      frac = 1;
    } else if (state != null && pagesCount > 0 && state.currentPage > 0) {
      frac = ((state.currentPage + 1) / pagesCount).clamp(0, 1).toDouble();
    } else if (book != null && pagesCount > 0 && (book.readPage ?? 0) > 0) {
      frac = (book.readPage! / pagesCount).clamp(0, 1).toDouble();
    } else {
      frac = null;
    }
    final percent = frac == null ? null : (frac * 100).round();
    final inProgress = frac != null && !completed && frac > 0;

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
                      title: book?.title ?? dto?.title ?? 'Book',
                      pills: [
                        if (book != null && book.number.isNotEmpty)
                          DetailPill('No. ${book.number}'),
                        if (pagesCount > 0) DetailPill('$pagesCount pages'),
                        if (completed)
                          const DetailPill('Read', accent: true)
                        else if (percent != null)
                          DetailPill('$percent% read', accent: true),
                      ],
                      actions: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: HeroAction(
                                  label:
                                      inProgress ? 'Continue reading' : 'Read',
                                  icon: AppIcons.read,
                                  onPressed: () => context
                                      .push('/reader/$sourceId/$bookId'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Same non-committal peek as the long-press
                              // Preview: opens the reader without reporting
                              // progress or marking it "reading now".
                              Expanded(
                                flex: 1,
                                child: HeroAction(
                                  label: 'Preview',
                                  icon: AppIcons.preview,
                                  style: HeroActionStyle.ghost,
                                  onPressed: () => context.push(
                                      '/reader/$sourceId/$bookId?preview=true'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _MarkReadControl(
                            sourceId: sourceId,
                            bookId: bookId,
                            completed: completed,
                            pagesCount: pagesCount,
                          ),
                          const SizedBox(height: 12),
                          HeroAction(
                            label: 'Add to read list',
                            icon: AppIcons.readList,
                            style: HeroActionStyle.ghost,
                            onPressed: () => AddToCollectionSheet.show(
                              context,
                              ref,
                              mode: 'readlist',
                              sourceId: sourceId,
                              itemId: bookId,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _DownloadControl(sourceId: sourceId, bookId: bookId),
                        ],
                      ),
                      details: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DetailMetadata.book(dto),
                          const SizedBox(height: 18),
                          RatingRow(
                            value: rating,
                            onChanged: (v) async {
                              await ref.read(appDatabaseProvider).setBookRating(
                                    sourceId,
                                    bookId,
                                    v,
                                    DateTime.now().millisecondsSinceEpoch,
                                  );
                              ref.invalidate(
                                  bookRatingProvider(sourceId, bookId));
                            },
                          ),
                          const SizedBox(height: 18),
                          ComicVineDetailsPanel(
                            ownerKind: 'book',
                            sourceId: sourceId,
                            ownerId: bookId,
                          ),
                        ],
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

/// The mark read / unread toggle, routed through the T6 write-back queue.
class _MarkReadControl extends ConsumerWidget {
  const _MarkReadControl({
    required this.sourceId,
    required this.bookId,
    required this.completed,
    required this.pagesCount,
  });

  final String sourceId;
  final String bookId;
  final bool completed;
  final int pagesCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) => HeroAction(
        label: completed ? 'Mark unread' : 'Mark read',
        icon: completed ? AppIcons.markUnread : AppIcons.markRead,
        style: HeroActionStyle.ghost,
        onPressed: pagesCount == 0
            ? null
            : () async {
                final engine = await ref.read(syncEngineProvider.future);
                if (completed) {
                  await engine.markUnread(sourceId, bookId);
                } else {
                  await engine.markRead(sourceId, bookId, pagesCount - 1);
                }
              },
      );
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
