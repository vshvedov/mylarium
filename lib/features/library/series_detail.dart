import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_icons.dart';
import '../integrations/comic_vine/comic_vine_panel.dart';
import 'library_browse_controllers.dart';
import 'widgets/detail_header.dart';
import 'widgets/library_tiles.dart';

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
    final series = detail.valueOrNull;
    final bookRows = books.valueOrNull ?? const [];
    final summary = series?.summary;
    final status = series?.status;
    final count = series?.booksCount ?? 0;

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
                      summary: (summary != null && summary.isNotEmpty)
                          ? Text(
                              summary,
                              maxLines: 6,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium,
                            )
                          : null,
                      details: ComicVineDetailsPanel(
                        ownerKind: 'series',
                        sourceId: sourceId,
                        ownerId: seriesId,
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
                          badge: b.completed ? const _CheckBadge() : null,
                          onTap: () => context.push('/book/$sourceId/${b.id}'),
                        );
                      }, childCount: bookRows.length),
                    ),
                  ),
                  if (books.isLoading)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: CircularProgressIndicator()),
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
        ],
      ),
    );
  }
}

String _titleCase(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();

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
