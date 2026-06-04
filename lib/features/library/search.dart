import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/age_rating.dart';
import '../../data/komga/models/series_dto.dart';
import '../../data/komga/models/series_search.dart';
import '../../data/source/source_providers.dart';
import 'library_browse_controllers.dart';
import 'widgets/library_tiles.dart';

/// Sort options for series search.
enum SeriesSort {
  relevance('Relevance', null),
  titleAsc('Title A-Z', 'metadata.titleSort,asc'),
  titleDesc('Title Z-A', 'metadata.titleSort,desc');

  const SeriesSort(this.label, this.value);
  final String label;
  final String? value;
}

/// Online search over series with text + library + age filters and a sort.
/// Results are not auto age-gated: an explicit query (and an explicit age chip)
/// is a user action.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';
  final Set<String> _libraryIds = {};
  SeriesSort _sort = SeriesSort.relevance;

  AsyncValue<List<SeriesDto>> _results = const AsyncData([]);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    final repo = await ref.read(searchRepositoryProvider.future);
    if (repo == null) {
      setState(() => _results = const AsyncData([]));
      return;
    }
    setState(() => _results = const AsyncLoading());
    try {
      final search = SeriesSearch(
        fullText: _query.isEmpty ? null : _query,
        libraryIds: _libraryIds.isEmpty ? null : _libraryIds.toList(),
      );
      final page = await repo.searchSeriesWith(
        search,
        size: 60,
        sort: _sort.value,
      );
      // Restricted series are never surfaced in search: revealing them requires
      // unlocking their library and browsing it (the lock is the only gate).
      final results = [
        for (final s in page.content)
          if (!isRestrictedAgeRating(s.ageRating)) s,
      ];
      if (mounted) setState(() => _results = AsyncData(results));
    } catch (e, st) {
      if (mounted) setState(() => _results = AsyncError(e, st));
    }
  }

  @override
  Widget build(BuildContext context) {
    final libraries = ref.watch(librariesProvider).valueOrNull ?? const [];
    final sourceId = ref.watch(activeSourceIdProvider).valueOrNull ?? '';
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'Search series',
            border: InputBorder.none,
          ),
          onChanged: (v) => _query = v,
          onSubmitted: (_) => _run(),
        ),
        actions: [
          PopupMenuButton<SeriesSort>(
            icon: const Icon(Icons.sort),
            initialValue: _sort,
            onSelected: (s) {
              setState(() => _sort = s);
              _run();
            },
            itemBuilder: (_) => [
              for (final s in SeriesSort.values)
                PopupMenuItem(value: s, child: Text(s.label)),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                for (final lib in libraries)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      label: Text(lib.name),
                      selected: _libraryIds.contains(lib.id),
                      onSelected: (sel) {
                        setState(() => sel
                            ? _libraryIds.add(lib.id)
                            : _libraryIds.remove(lib.id));
                        _run();
                      },
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _results.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Search failed: $e')),
              data: (series) => series.isEmpty
                  ? const Center(child: Text('No results.'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 160,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.58,
                      ),
                      itemCount: series.length,
                      itemBuilder: (context, i) {
                        final s = series[i];
                        return CoverTile(
                          sourceId: sourceId,
                          ownerType: 'series',
                          ownerId: s.id,
                          title: s.title,
                          onTap: () => _openSeries(context, s),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openSeries(BuildContext context, SeriesDto s) async {
    final sourceId = await ref.read(activeSourceIdProvider.future);
    if (sourceId == null || !context.mounted) return;
    context.push('/series/$sourceId/${s.id}');
  }
}
