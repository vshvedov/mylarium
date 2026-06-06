import 'package:flutter/material.dart';
import '../../app/theme/app_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../app/theme/design_tokens.dart';
import '../../app/theme/theme_controller.dart' show appDatabaseProvider;
import '../../core/security/app_lock.dart';
import '../../app/widgets/adaptive_layout.dart';
import '../../core/db/database.dart';
import '../../data/source/source_providers.dart';
import 'series_detail.dart';
import 'series_grid_controller.dart';
import 'widgets/library_tiles.dart';

/// The selected series in the two-pane browse shell, keyed per source so a stale
/// selection never leaks across sources. autoDispose: reset on leaving browse.
final selectedSeriesProvider = StateProvider.autoDispose
    .family<String?, String>((ref, sourceId) => null);

/// Virtualized series grid backed by keyset pagination over the local cache
/// (filled on demand from the network). Handles 50k+ series at a fixed tile
/// extent. In a two-pane shell it runs [embedded] (no Scaffold) and reports taps
/// via [onSelectSeries] instead of pushing a route.
class SeriesGridScreen extends ConsumerStatefulWidget {
  const SeriesGridScreen({
    super.key,
    required this.sourceId,
    this.libraryId,
    this.title = 'Library',
    this.onSelectSeries,
    this.embedded = false,
  });

  final String sourceId;
  final String? libraryId;
  final String title;
  final void Function(String seriesId)? onSelectSeries;
  final bool embedded;

  @override
  ConsumerState<SeriesGridScreen> createState() => _SeriesGridScreenState();
}

class _SeriesGridScreenState extends ConsumerState<SeriesGridScreen> {
  final _paging = PagingController<SeriesCursor, SeriesRow>(
    firstPageKey: const SeriesCursor.start(),
  );
  SeriesGridController? _controller;

  @override
  void initState() {
    super.initState();
    _paging.addPageRequestListener(_fetch);
  }

  Future<void> _fetch(SeriesCursor cursor) async {
    try {
      final controller = _controller ??= await _buildController();
      if (controller == null) {
        _paging.appendLastPage(const []);
        return;
      }
      final result = await controller.page(cursor);
      if (result.last || result.content.isEmpty) {
        _paging.appendLastPage(result.content);
      } else {
        _paging.appendPage(
          result.content,
          SeriesCursor.after(result.content.last),
        );
      }
    } catch (e) {
      _paging.error = e;
    }
  }

  Future<SeriesGridController?> _buildController() async {
    final repo = await ref.read(seriesRepositoryProvider.future);
    if (repo == null) return null;
    final lock = await ref.read(appLockProvider.future);
    return SeriesGridController(
      db: ref.read(appDatabaseProvider),
      repo: repo,
      sourceId: widget.sourceId,
      libraryId: widget.libraryId,
      hiddenLibraryIds: lock.hiddenLibraryIds,
    );
  }

  @override
  void dispose() {
    _paging.dispose();
    super.dispose();
  }

  void _onTap(SeriesRow series) {
    final onSelect = widget.onSelectSeries;
    if (onSelect != null) {
      onSelect(series.id);
    } else {
      context.push('/series/${series.sourceId}/${series.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = RefreshIndicator(
      onRefresh: () async {
        _controller = null;
        _paging.refresh();
      },
      child: SeriesGridBody(paging: _paging, onTap: _onTap),
    );
    if (widget.embedded) return body;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.search),
            onPressed: () => context.push('/search'),
          ),
        ],
      ),
      body: body,
    );
  }
}

/// The grid body (no Scaffold): a paginated sliver grid of [CoverTile]s. Shared
/// by [SeriesGridScreen] (route and embedded master) so the visual is identical
/// and golden-testable with a pre-filled controller.
class SeriesGridBody extends StatelessWidget {
  const SeriesGridBody({super.key, required this.paging, required this.onTap});

  final PagingController<SeriesCursor, SeriesRow> paging;
  final void Function(SeriesRow series) onTap;

  @override
  Widget build(BuildContext context) {
    final gutter = Theme.of(context).extension<DesignTokens>()!.gridGutter;
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.all(gutter),
          sliver: PagedSliverGrid<SeriesCursor, SeriesRow>(
            pagingController: paging,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 160,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.58,
            ),
            builderDelegate: PagedChildBuilderDelegate<SeriesRow>(
              itemBuilder: (context, series, _) => CoverTile(
                sourceId: series.sourceId,
                ownerType: 'series',
                ownerId: series.id,
                title: series.title,
                subtitle: series.booksCount == 1
                    ? '1 book'
                    : '${series.booksCount} books',
                stacked: series.booksCount > 1,
                onTap: () => onTap(series),
              ),
              noItemsFoundIndicatorBuilder: (_) => const Center(
                child: Padding(
                  padding: EdgeInsets.all(48),
                  child: Text('No series here yet.'),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Two-pane browse shell: the series grid (master) beside the selected series'
/// detail. [AdaptiveLayout] collapses to the grid alone on phone widths, where
/// taps push the detail route as before. Only the detail [Consumer] rebuilds on
/// selection, so the master grid's paging and scroll state are preserved.
class BrowseShell extends ConsumerWidget {
  const BrowseShell({
    super.key,
    required this.sourceId,
    this.title = 'All series',
  });

  final String sourceId;
  final String title;

  /// Below this width [AdaptiveLayout] hides the detail pane and shows only the
  /// master grid, so a tap must push the detail route instead of selecting into
  /// an invisible pane. Kept in sync with the [AdaptiveLayout.breakpoint] below.
  static const double _detailBreakpoint = 840;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.search),
            onPressed: () => context.push('/search'),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Only wire in-pane selection when the detail pane is actually shown.
          // On phone widths the pane is collapsed, so taps fall through to a
          // route push (the null callback path in SeriesGridScreen._onTap).
          final showsDetail = constraints.maxWidth >= _detailBreakpoint;
          return AdaptiveLayout(
            breakpoint: _detailBreakpoint,
            master: SeriesGridScreen(
              sourceId: sourceId,
              embedded: true,
              onSelectSeries: showsDetail
                  ? (id) => ref
                      .read(selectedSeriesProvider(sourceId).notifier)
                      .state = id
                  : null,
            ),
            detail: Consumer(
              builder: (context, ref, _) {
                final selected = ref.watch(selectedSeriesProvider(sourceId));
                return selected == null
                    ? const _SelectSeriesPlaceholder()
                    : SeriesDetailScreen(
                        sourceId: sourceId,
                        seriesId: selected,
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
