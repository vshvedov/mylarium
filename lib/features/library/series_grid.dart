import 'package:flutter/material.dart';
import '../../app/theme/app_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../app/theme/design_tokens.dart';
import '../../app/theme/theme_controller.dart' show appDatabaseProvider;
import '../../core/db/database.dart';
import '../../data/source/source_providers.dart';
import 'series_grid_controller.dart';
import 'widgets/library_tiles.dart';

/// Virtualized series grid backed by keyset pagination over the local cache
/// (filled on demand from the network). Handles 50k+ series at a fixed tile
/// extent.
class SeriesGridScreen extends ConsumerStatefulWidget {
  const SeriesGridScreen({
    super.key,
    required this.sourceId,
    this.libraryId,
    this.title = 'Library',
    this.includeRestricted = false,
  });

  final String sourceId;
  final String? libraryId;
  final String title;
  final bool includeRestricted;

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
    return SeriesGridController(
      db: ref.read(appDatabaseProvider),
      repo: repo,
      sourceId: widget.sourceId,
      libraryId: widget.libraryId,
      includeRestricted: widget.includeRestricted,
    );
  }

  @override
  void dispose() {
    _paging.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gutter = Theme.of(context).extension<DesignTokens>()!.gridGutter;
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
      body: RefreshIndicator(
        onRefresh: () async {
          _controller = null;
          _paging.refresh();
        },
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.all(gutter),
              sliver: PagedSliverGrid<SeriesCursor, SeriesRow>(
                pagingController: _paging,
                gridDelegate:
                    const SliverGridDelegateWithMaxCrossAxisExtent(
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
                    onTap: () => context.push(
                      '/series/${series.sourceId}/${series.id}',
                    ),
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
        ),
      ),
    );
  }
}
