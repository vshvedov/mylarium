import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/l10n.dart';
import '../../app/theme/app_icons.dart';
import '../../app/theme/design_tokens.dart';
import '../../app/widgets/adaptive_layout.dart';
import '../../app/widgets/app_loading.dart';
import '../../core/db/database.dart';
import 'book_detail.dart';
import 'library_browse_controllers.dart';
import 'series_detail.dart';
import 'series_sync.dart';
import 'widgets/alphabet_scrubber.dart';
import 'widgets/item_context_menu.dart';
import 'widgets/library_tiles.dart';

/// The selected series in the two-pane browse shell, keyed per source so a stale
/// selection never leaks across sources. autoDispose: reset on leaving browse.
final selectedSeriesProvider = StateProvider.autoDispose
    .family<String?, String>((ref, sourceId) => null);

/// The book opened in-pane from the embedded series detail (one level deeper
/// than [selectedSeriesProvider], same keying). Null shows the series detail;
/// the pane's back affordance and a new series selection both reset it.
/// autoDispose: reset on leaving browse.
final selectedBookProvider = StateProvider.autoDispose
    .family<String?, String>((ref, sourceId) => null);

/// Virtualized series grid over the whole locally-cached library for a source. A
/// shared background full sync (see [seriesSyncProvider]) fills the cache once;
/// this grid renders the sorted rows from [browseSeriesProvider] as they land,
/// so scrolling (and the A-Z scrubber) are pure local reads with no per-scroll
/// network paging. In a two-pane shell it runs [embedded] (no Scaffold) and
/// reports taps via [onSelectSeries] instead of pushing a route.
class SeriesGridScreen extends ConsumerStatefulWidget {
  const SeriesGridScreen({
    super.key,
    required this.sourceId,
    this.libraryId,
    this.title,
    this.onSelectSeries,
    this.embedded = false,
  });

  final String sourceId;
  final String? libraryId;

  /// App-bar title. When null, falls back to the localized "Library".
  final String? title;
  final void Function(String seriesId)? onSelectSeries;
  final bool embedded;

  @override
  ConsumerState<SeriesGridScreen> createState() => _SeriesGridScreenState();
}

class _SeriesGridScreenState extends ConsumerState<SeriesGridScreen> {
  // Owned here so the A-Z scrubber can drive it.
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
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
    final sort = ref.watch(browseSortProvider(widget.sourceId));
    final async = sort == BrowseSort.mostBooks
        ? ref.watch(browseSeriesByBooksProvider(
            (sourceId: widget.sourceId, libraryId: widget.libraryId)))
        : ref.watch(browseSeriesProvider(
            widget.sourceId, widget.libraryId, sort.titleDescending));
    // Observable completion (not SeriesSync.complete, which mutates in place and
    // would never rebuild the grid - leaving an empty library on the loader
    // forever). Resolves true once the background fill finishes or degrades.
    final syncComplete = ref
            .watch(seriesSyncCompleteProvider(widget.sourceId, widget.libraryId))
            .valueOrNull ??
        false;

    final body = RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(seriesSyncProvider(widget.sourceId, widget.libraryId));
      },
      child: SeriesGridBody(
        items: async.valueOrNull,
        syncComplete: syncComplete,
        onTap: _onTap,
        controller: _scroll,
        alphabetical: sort.alphabetical,
      ),
    );
    if (widget.embedded) return body;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? context.l10n.libraryFallbackName),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.search),
            onPressed: () => context.push('/search'),
          ),
          SortButton(sourceId: widget.sourceId),
        ],
      ),
      body: body,
    );
  }
}

/// The grid body (no Scaffold): a virtualized sliver grid of [CoverTile]s over
/// the fully-synced [items]. Shows the branded loader while the cache is still
/// filling (empty + sync incomplete) and a friendly message once the sync is
/// complete and still empty. Kept separate so it stays golden/widget-testable
/// with a fixed list.
class SeriesGridBody extends StatelessWidget {
  const SeriesGridBody({
    super.key,
    required this.items,
    required this.syncComplete,
    required this.onTap,
    this.controller,
    this.alphabetical = true,
  });

  /// The sorted series, or null before the first cache emission.
  final List<SeriesRow>? items;

  /// Whether the background full sync has finished (so an empty list is a true
  /// empty, not "still loading").
  final bool syncComplete;
  final void Function(SeriesRow series) onTap;

  /// Drives the scroll position (the A-Z scrubber jumps it).
  final ScrollController? controller;

  /// Whether [items] are in alphabetical order. A non-title sort (Most books)
  /// hides the A-Z scrubber, whose letter jumps assume an alphabetical list.
  final bool alphabetical;

  @override
  Widget build(BuildContext context) {
    final list = items ?? const <SeriesRow>[];
    if (list.isEmpty) {
      if (!syncComplete) return const AppLoadingIndicator();
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Text(context.l10n.localNoSeries),
        ),
      );
    }
    final gutter = Theme.of(context).extension<DesignTokens>()!.gridGutter;
    // Grid metrics, shared between the delegate and the scrubber's row-offset
    // math so a letter jump lands exactly.
    const maxExtent = 160.0;
    const spacing = 12.0;
    const aspect = 0.58;
    const scrubberWidth = 22.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossExtent =
            (constraints.maxWidth - gutter * 2 - scrubberWidth)
                .clamp(1.0, double.infinity);
        final cols = (crossExtent / (maxExtent + spacing)).ceil();
        final columns = cols < 1 ? 1 : cols;
        final childWidth = (crossExtent - (columns - 1) * spacing) / columns;
        final rowStride = childWidth / aspect + spacing;

        void jumpToLetter(String letter) {
          final c = controller;
          if (c == null || !c.hasClients) return;
          final idx =
              list.indexWhere((s) => letterBucket(s.titleSort) == letter);
          if (idx < 0) return;
          final offset = gutter + (idx ~/ columns) * rowStride;
          c.jumpTo(offset.clamp(0.0, c.position.maxScrollExtent));
        }

        return Stack(
          children: [
            CustomScrollView(
              controller: controller,
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                      gutter, gutter, gutter + scrubberWidth, gutter),
                  sliver: SliverGrid.builder(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: maxExtent,
                      mainAxisSpacing: spacing,
                      crossAxisSpacing: spacing,
                      childAspectRatio: aspect,
                    ),
                    itemCount: list.length,
                    itemBuilder: (context, i) {
                      final s = list[i];
                      return CoverTile(
                        sourceId: s.sourceId,
                        ownerType: 'series',
                        ownerId: s.id,
                        title: s.title,
                        // Unknown count (e.g. a Kavita series not yet browsed;
                        // its list endpoint omits counts) shows no subtitle
                        // rather than "0 books".
                        subtitle: s.booksCount <= 0
                            ? null
                            : s.booksCount == 1
                                ? '1 book'
                                : '${s.booksCount} books',
                        stacked: s.booksCount > 1,
                        onTap: () => onTap(s),
                        onLongPress: () => showItemContextMenu(
                          context,
                          sourceId: s.sourceId,
                          ownerType: 'series',
                          ownerId: s.id,
                          title: s.title,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            if (alphabetical)
              Positioned(
                top: 0,
                bottom: 0,
                right: 0,
                width: scrubberWidth,
                child: AlphabetScrubber(
                  present: {for (final s in list) letterBucket(s.titleSort)},
                  onLetter: jumpToLetter,
                ),
              ),
          ],
        );
      },
    );
  }
}

/// The sort control for the browse grid: one entry per [BrowseSort], the
/// active one marked with a check.
class SortButton extends ConsumerWidget {
  const SortButton({super.key, required this.sourceId});

  final String sourceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sort = ref.watch(browseSortProvider(sourceId));
    return PopupMenuButton<BrowseSort>(
      icon: const Icon(AppIcons.sort),
      initialValue: sort,
      tooltip: context.l10n.sortTooltip,
      onSelected: (v) =>
          ref.read(browseSortProvider(sourceId).notifier).state = v,
      itemBuilder: (_) => [
        for (final s in BrowseSort.values)
          PopupMenuItem(
            value: s,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // A fixed leading check slot (not CheckedPopupMenuItem, which
                // draws a Material icon; see CLAUDE.md "Iconography").
                SizedBox(
                  width: 28,
                  child: s == sort
                      ? const Icon(AppIcons.check, size: 18)
                      : null,
                ),
                Flexible(
                  child: Text(
                    s.localizedLabel(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Two-pane browse shell: the series grid (master) beside the selected series'
/// detail. [AdaptiveLayout] collapses to the grid alone on phone widths, where
/// taps push the detail route as before. Only the detail [Consumer] rebuilds on
/// selection, so the master grid's scroll state is preserved.
class BrowseShell extends ConsumerWidget {
  const BrowseShell({
    super.key,
    required this.sourceId,
    this.title,
  });

  final String sourceId;

  /// App-bar title. When null, falls back to the localized "All series".
  final String? title;

  /// Below this width [AdaptiveLayout] hides the detail pane and shows only the
  /// master grid, so a tap must push the detail route instead of selecting into
  /// an invisible pane. Kept in sync with the [AdaptiveLayout.breakpoint] below.
  static const double _detailBreakpoint = 840;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? context.l10n.allSeries),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.search),
            onPressed: () => context.push('/search'),
          ),
          SortButton(sourceId: sourceId),
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
                  ? (id) {
                      // A new series selection always lands on the series
                      // detail, never on a book left over from the previous
                      // selection.
                      ref.read(selectedBookProvider(sourceId).notifier).state =
                          null;
                      ref
                          .read(selectedSeriesProvider(sourceId).notifier)
                          .state = id;
                    }
                  : null,
            ),
            detail: Consumer(
              builder: (context, ref, _) {
                final selected = ref.watch(selectedSeriesProvider(sourceId));
                if (selected == null) return const _SelectSeriesPlaceholder();
                // One level of pane-local navigation: a tapped book replaces
                // the series detail in this pane (reading itself still pushes
                // the full-screen reader route from inside the book detail).
                final book = ref.watch(selectedBookProvider(sourceId));
                if (book != null) {
                  return BookDetailScreen(
                    sourceId: sourceId,
                    bookId: book,
                    onEmbeddedBack: () => ref
                        .read(selectedBookProvider(sourceId).notifier)
                        .state = null,
                  );
                }
                return SeriesDetailScreen(
                  sourceId: sourceId,
                  seriesId: selected,
                  embedded: true,
                  onSelectBook: (id) => ref
                      .read(selectedBookProvider(sourceId).notifier)
                      .state = id,
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
            context.l10n.selectSeries,
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
