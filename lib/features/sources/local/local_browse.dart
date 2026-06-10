import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_icons.dart';
import '../../../app/widgets/adaptive_layout.dart';
import '../../../core/db/database.dart';
import '../../library/widgets/library_tiles.dart';
import 'import_controller.dart';
import 'import_results_sheet.dart';
import 'local_providers.dart';

/// Selected series (by name) in the two-pane local browse shell, keyed per
/// source so a stale selection never leaks across sources. autoDispose: reset
/// on leaving browse.
final selectedLocalSeriesProvider =
    StateProvider.autoDispose.family<String?, String>((ref, sourceId) => null);

/// Browse shell for the Local files source: a series grid that becomes a
/// master-detail layout at >= 840px, mirroring the server [BrowseShell].
class LocalBrowseShell extends ConsumerWidget {
  const LocalBrowseShell({super.key, required this.sourceId});

  final String sourceId;

  /// Below this width [AdaptiveLayout] hides the detail pane and shows only
  /// the master grid, so a tap must push the detail route instead of selecting
  /// into an invisible pane. Kept in sync with [AdaptiveLayout.breakpoint].
  static const double _detailBreakpoint = 840;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local files'),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.importComics),
            tooltip: 'Import comics',
            onPressed: () async {
              final result = await ref
                  .read(importControllerProvider.notifier)
                  .pickAndImport();
              if (result != null && context.mounted) {
                await ImportResultsSheet.show(context, result);
              }
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Only wire in-pane selection when the detail pane is actually
          // shown. On phone widths the pane is collapsed, so taps fall through
          // to a route push (the null callback path in _LocalSeriesGrid).
          final showsDetail = constraints.maxWidth >= _detailBreakpoint;
          return AdaptiveLayout(
            breakpoint: _detailBreakpoint,
            master: _LocalSeriesGrid(
              sourceId: sourceId,
              onSelectSeries: showsDetail
                  ? (series) => ref
                      .read(selectedLocalSeriesProvider(sourceId).notifier)
                      .state = series
                  : null,
            ),
            detail: Consumer(
              builder: (context, ref, _) {
                final series =
                    ref.watch(selectedLocalSeriesProvider(sourceId));
                return series == null
                    ? const _SelectSeriesPlaceholder()
                    : LocalSeriesDetailScreen(
                        sourceId: sourceId,
                        series: series,
                        embedded: true,
                      );
              },
            ),
          );
        },
      ),
    );
  }
}

class _LocalSeriesGrid extends ConsumerWidget {
  const _LocalSeriesGrid({required this.sourceId, this.onSelectSeries});

  final String sourceId;
  final ValueChanged<String>? onSelectSeries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups =
        ref.watch(localSeriesProvider(sourceId)).valueOrNull ??
            const <LocalSeriesRaw>[];
    if (groups.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(48),
          child: Text('No series here yet.'),
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 160,
        childAspectRatio: 0.58,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: groups.length,
      itemBuilder: (context, i) {
        final g = groups[i];
        return CoverTile(
          sourceId: sourceId,
          ownerType: 'book',
          ownerId: g.coverComicId,
          title: g.series,
          subtitle: g.booksCount == 1 ? '1 book' : '${g.booksCount} books',
          stacked: g.booksCount > 1,
          onTap: () {
            final select = onSelectSeries;
            if (select != null) {
              select(g.series);
            } else {
              // The series name travels as a query parameter, never a path
              // segment (series names may contain '/').
              context.push(Uri(
                path: '/local-series/$sourceId',
                queryParameters: {'series': g.series},
              ).toString());
            }
          },
        );
      },
    );
  }
}

/// Books of one local series. [embedded] suppresses the back app bar inside
/// the two-pane shell, mirroring the server series detail.
class LocalSeriesDetailScreen extends ConsumerWidget {
  const LocalSeriesDetailScreen({
    super.key,
    required this.sourceId,
    required this.series,
    this.embedded = false,
  });

  final String sourceId;
  final String series;
  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final books =
        ref.watch(localBooksProvider(sourceId, series)).valueOrNull ??
            const <LocalComic>[];
    final body = CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          sliver: SliverToBoxAdapter(
            child: Text(
              books.length == 1 ? '1 book' : '${books.length} books',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(12),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 160,
              childAspectRatio: 0.58,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final b = books[i];
                return CoverTile(
                  sourceId: sourceId,
                  ownerType: 'book',
                  ownerId: b.id,
                  title: b.title,
                  subtitle: b.number,
                  onTap: () => context.push('/local-book/$sourceId/${b.id}'),
                );
              },
              childCount: books.length,
            ),
          ),
        ),
      ],
    );
    if (embedded) return body;
    return Scaffold(
      appBar: AppBar(title: Text(series)),
      body: body,
    );
  }
}

class _SelectSeriesPlaceholder extends StatelessWidget {
  const _SelectSeriesPlaceholder();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.browse, size: 40, color: scheme.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(
            'Select a series',
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
