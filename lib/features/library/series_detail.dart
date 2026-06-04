import 'package:flutter/material.dart';
import '../../app/theme/app_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/design_tokens.dart';
import 'library_browse_controllers.dart';
import 'widgets/cover_image.dart';
import 'widgets/library_tiles.dart';

/// Series detail: metadata header plus the series' books as a grid. Books are
/// streamed from the cache (refreshed online on open).
class SeriesDetailScreen extends ConsumerWidget {
  const SeriesDetailScreen({
    super.key,
    required this.sourceId,
    required this.seriesId,
  });

  final String sourceId;
  final String seriesId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(seriesDetailProvider(sourceId, seriesId));
    final books = ref.watch(seriesBooksProvider(sourceId, seriesId));
    final tokens = Theme.of(context).extension<DesignTokens>()!;
    final series = detail.valueOrNull;

    return Scaffold(
      appBar: AppBar(title: Text(series?.title ?? 'Series')),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120,
                    height: 180,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(tokens.coverRadius),
                      child: CoverImage(
                        sourceId: sourceId,
                        ownerType: 'series',
                        ownerId: seriesId,
                        title: series?.title ?? '',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(series?.title ?? '',
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 4),
                        if (series?.status != null)
                          Text(series!.status!,
                              style: Theme.of(context).textTheme.labelMedium),
                        const SizedBox(height: 8),
                        if (series?.summary != null)
                          Text(
                            series!.summary!,
                            maxLines: 6,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(12),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 160,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.58,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final list = books.valueOrNull ?? const [];
                  final b = list[i];
                  return CoverTile(
                    sourceId: sourceId,
                    ownerType: 'book',
                    ownerId: b.id,
                    title: b.title,
                    subtitle: b.number.isEmpty ? null : 'No. ${b.number}',
                    badge: b.completed
                        ? const _CheckBadge()
                        : null,
                    onTap: () => context.push('/book/$sourceId/${b.id}'),
                  );
                },
                childCount: (books.valueOrNull ?? const []).length,
              ),
            ),
          ),
          if (books.isLoading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
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
        child: Icon(AppIcons.check,
            size: 14, color: Theme.of(context).colorScheme.onPrimary),
      );
}
