import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_icons.dart';
import '../../app/theme/theme_controller.dart' show appDatabaseProvider;
import '../../app/widgets/app_loading.dart';
import '../../core/db/database.dart';
import '../../features/sync/sync_providers.dart';
import '../integrations/comic_vine/comic_vine_panel.dart';
import '../offline/offline_providers.dart';
import 'library_browse_controllers.dart';
import 'widgets/add_to_collection_sheet.dart';
import 'widgets/detail_header.dart';
import 'widgets/detail_metadata.dart';
import 'widgets/library_tiles.dart';
import 'widgets/star_rating.dart';

/// Series detail: a cover-forward hero, status/summary, then the series' books
/// as a grid. Books are streamed from the cache (refreshed online on open). Runs
/// [embedded] (no back button) inside the two-pane browse shell.
class SeriesDetailScreen extends ConsumerWidget {
  const SeriesDetailScreen({
    super.key,
    required this.sourceId,
    required this.seriesId,
    this.embedded = false,
  });

  final String sourceId;
  final String seriesId;
  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(seriesDetailProvider(sourceId, seriesId));
    final books = ref.watch(seriesBooksProvider(sourceId, seriesId));
    final dto = ref.watch(seriesDetailDtoProvider(sourceId, seriesId)).valueOrNull;
    final rating = ref.watch(seriesRatingProvider(sourceId, seriesId)).valueOrNull;
    final states =
        ref.watch(seriesReadStatesProvider(sourceId, seriesId)).valueOrNull ??
            const <BookStateRow>[];
    final series = detail.valueOrNull;
    final bookRows = books.valueOrNull ?? const [];
    final summary = series?.summary;
    final status = series?.status;
    final count = series?.booksCount ?? 0;

    // BookState wins for the badge when a row exists; otherwise fall back to the
    // cached Books.completed (which the server refresh may overwrite).
    final stateById = {for (final s in states) s.bookId: s};
    bool isCompleted(Book b) => stateById.containsKey(b.id)
        ? stateById[b.id]!.status == 'completed'
        : b.completed;
    final seriesCompleted =
        bookRows.isNotEmpty && bookRows.every(isCompleted);

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
                      ownerType: 'series',
                      ownerId: seriesId,
                      title: series?.title ?? 'Series',
                      pills: [
                        if (status != null && status.isNotEmpty)
                          DetailPill(_titleCase(status)),
                        if (count > 0)
                          DetailPill(count == 1 ? '1 book' : '$count books'),
                      ],
                      actions: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _MarkSeriesControl(
                            sourceId: sourceId,
                            seriesId: seriesId,
                            completed: seriesCompleted,
                            empty: bookRows.isEmpty,
                          ),
                          const SizedBox(height: 12),
                          HeroAction(
                            label: 'Add to collection',
                            icon: AppIcons.collections,
                            style: HeroActionStyle.ghost,
                            onPressed: () => AddToCollectionSheet.show(
                              context,
                              ref,
                              mode: 'collection',
                              sourceId: sourceId,
                              itemId: seriesId,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _SeriesDownloadControl(
                            sourceId: sourceId,
                            seriesId: seriesId,
                          ),
                        ],
                      ),
                      summary: (summary != null && summary.isNotEmpty)
                          ? Text(
                              summary,
                              maxLines: 6,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium,
                            )
                          : null,
                      details: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DetailMetadata.series(dto),
                          const SizedBox(height: 18),
                          RatingRow(
                            value: rating,
                            onChanged: (v) async {
                              await ref
                                  .read(appDatabaseProvider)
                                  .setSeriesRating(sourceId, seriesId, v);
                              ref.invalidate(
                                  seriesRatingProvider(sourceId, seriesId));
                            },
                          ),
                          const SizedBox(height: 18),
                          ComicVineDetailsPanel(
                            ownerKind: 'series',
                            sourceId: sourceId,
                            ownerId: seriesId,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 160,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.58,
                          ),
                      delegate: SliverChildBuilderDelegate((context, i) {
                        final b = bookRows[i];
                        return CoverTile(
                          sourceId: sourceId,
                          ownerType: 'book',
                          ownerId: b.id,
                          title: b.title,
                          subtitle: b.number.isEmpty ? null : 'No. ${b.number}',
                          badge: isCompleted(b) ? const _CheckBadge() : null,
                          leadingBadge: OfflineBadge(
                            sourceId: sourceId,
                            bookId: b.id,
                          ),
                          onTap: () => context.push('/book/$sourceId/${b.id}'),
                        );
                      }, childCount: bookRows.length),
                    ),
                  ),
                  if (books.isLoading)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: AppLoadingIndicator(),
                      ),
                    ),
                  const SliverToBoxAdapter(
                    child: SafeArea(top: false, child: SizedBox(height: 20)),
                  ),
                ],
              ),
            ),
          ),
          if (!embedded) const Positioned(top: 0, left: 4, child: HeroBackButton()),
          Positioned(
            top: 0,
            right: 4,
            child: HeroPinButton(
              sourceId: sourceId,
              ownerType: 'series',
              ownerId: seriesId,
            ),
          ),
        ],
      ),
    );
  }
}

String _titleCase(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();

/// Marks the whole series read or unread (routed through the T6 queue).
class _MarkSeriesControl extends ConsumerWidget {
  const _MarkSeriesControl({
    required this.sourceId,
    required this.seriesId,
    required this.completed,
    required this.empty,
  });

  final String sourceId;
  final String seriesId;
  final bool completed;
  final bool empty;

  @override
  Widget build(BuildContext context, WidgetRef ref) => HeroAction(
        label: completed ? 'Mark series unread' : 'Mark series read',
        icon: completed ? AppIcons.markUnread : AppIcons.markRead,
        style: HeroActionStyle.ghost,
        onPressed: empty
            ? null
            : () async {
                final engine = await ref.read(syncEngineProvider.future);
                if (completed) {
                  await engine.markSeriesUnread(sourceId, seriesId);
                } else {
                  await engine.markSeriesRead(sourceId, seriesId);
                }
              },
      );
}

/// Download / remove the whole series. Permanent (pinned) downloads, so they
/// are never auto-evicted. Three states: none -> Download, partial -> a disabled
/// progress label, all -> Remove.
class _SeriesDownloadControl extends ConsumerWidget {
  const _SeriesDownloadControl({required this.sourceId, required this.seriesId});

  final String sourceId;
  final String seriesId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status =
        ref.watch(seriesDownloadStatusProvider(sourceId, seriesId)).valueOrNull;
    if (status == null) return const SizedBox.shrink();
    final total = status.total;
    final downloaded = status.downloaded;

    if (total > 0 && downloaded >= total) {
      return HeroAction(
        label: 'Remove downloads',
        icon: AppIcons.delete,
        style: HeroActionStyle.ghost,
        onPressed: () => ref
            .read(offlineCacheManagerProvider)
            .deleteSeries(sourceId, seriesId),
      );
    }
    if (downloaded > 0 && downloaded < total) {
      return HeroAction(
        label: 'Downloading $downloaded/$total...',
        icon: AppIcons.download,
        style: HeroActionStyle.ghost,
        onPressed: null,
      );
    }
    return HeroAction(
      label: 'Download series',
      icon: AppIcons.download,
      style: HeroActionStyle.ghost,
      onPressed: () =>
          ref.read(downloadManagerProvider).enqueueSeries(sourceId, seriesId),
    );
  }
}

class _CheckBadge extends StatelessWidget {
  const _CheckBadge();

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primary,
      shape: BoxShape.circle,
    ),
    padding: const EdgeInsets.all(2),
    child: Icon(
      AppIcons.check,
      size: 14,
      color: Theme.of(context).colorScheme.onPrimary,
    ),
  );
}
