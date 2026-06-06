import 'package:flutter/material.dart';
import '../../app/theme/app_icons.dart';
import '../../app/widgets/app_text_field.dart';
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
  titleDesc('Title Z-A', 'metadata.titleSort,desc'),
  recentlyAdded('Recently added', 'createdDate,desc'),
  recentlyUpdated('Recently updated', 'lastModifiedDate,desc');

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
  final Set<String> _status = {};
  final Set<String> _readStatus = {};
  final Set<String> _genres = {};
  final Set<String> _tags = {};
  final Set<String> _publishers = {};
  final Set<int> _ageRatings = {};
  SeriesSort _sort = SeriesSort.relevance;

  // Komga series and read statuses.
  static const _statusOptions = {
    'ONGOING': 'Ongoing',
    'ENDED': 'Ended',
    'HIATUS': 'Hiatus',
    'ABANDONED': 'Abandoned',
  };
  static const _readStatusOptions = {
    'UNREAD': 'Unread',
    'IN_PROGRESS': 'In progress',
    'READ': 'Read',
  };

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
        status: _status.isEmpty ? null : _status.toList(),
        readStatus: _readStatus.isEmpty ? null : _readStatus.toList(),
        genres: _genres.isEmpty ? null : _genres.toList(),
        tags: _tags.isEmpty ? null : _tags.toList(),
        publishers: _publishers.isEmpty ? null : _publishers.toList(),
        ageRatings: _ageRatings.isEmpty ? null : _ageRatings.toList(),
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
        title: AppTextField(
          controller: _controller,
          autofocus: true,
          dense: true,
          hint: 'Search series',
          prefixIcon: AppIcons.search,
          textInputAction: TextInputAction.search,
          onChanged: (v) => _query = v,
          onSubmitted: (_) => _run(),
        ),
        actions: [
          PopupMenuButton<SeriesSort>(
            icon: const Icon(AppIcons.sort),
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
          _filterRow([
            for (final lib in libraries)
              _chip(lib.name, _libraryIds.contains(lib.id), (sel) {
                setState(() => sel
                    ? _libraryIds.add(lib.id)
                    : _libraryIds.remove(lib.id));
                _run();
              }),
          ]),
          _filterRow([
            for (final e in _statusOptions.entries)
              _chip(e.value, _status.contains(e.key), (sel) {
                setState(() =>
                    sel ? _status.add(e.key) : _status.remove(e.key));
                _run();
              }),
            for (final e in _readStatusOptions.entries)
              _chip(e.value, _readStatus.contains(e.key), (sel) {
                setState(() => sel
                    ? _readStatus.add(e.key)
                    : _readStatus.remove(e.key));
                _run();
              }),
          ]),
          _stringFilterRow(
            ref.watch(genresProvider).valueOrNull ?? const [],
            _genres,
          ),
          _stringFilterRow(
            ref.watch(tagsProvider).valueOrNull ?? const [],
            _tags,
          ),
          _stringFilterRow(
            ref.watch(publishersProvider).valueOrNull ?? const [],
            _publishers,
          ),
          _ageFilterRow(ref.watch(ageRatingsProvider).valueOrNull ?? const []),
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
                          stacked: s.booksCount > 1,
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

  Widget _filterRow(List<Widget> chips) {
    if (chips.isEmpty) return const SizedBox.shrink();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(children: chips),
    );
  }

  /// A filter row over a referential string list (genres / tags / publishers).
  /// Renders nothing when the list is empty (e.g. offline).
  Widget _stringFilterRow(List<String> options, Set<String> selected) =>
      _filterRow([
        for (final o in options)
          _chip(o, selected.contains(o), (sel) {
            setState(() => sel ? selected.add(o) : selected.remove(o));
            _run();
          }),
      ]);

  /// The age-rating filter row. Hidden when the server reports none.
  Widget _ageFilterRow(List<int> options) => _filterRow([
        for (final a in options)
          _chip('$a+', _ageRatings.contains(a), (sel) {
            setState(() => sel ? _ageRatings.add(a) : _ageRatings.remove(a));
            _run();
          }),
      ]);

  Widget _chip(String label, bool selected, ValueChanged<bool> onSelected) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: FilterChip(
          label: Text(label),
          selected: selected,
          onSelected: onSelected,
        ),
      );

  Future<void> _openSeries(BuildContext context, SeriesDto s) async {
    final sourceId = await ref.read(activeSourceIdProvider.future);
    if (sourceId == null || !context.mounted) return;
    context.push('/series/$sourceId/${s.id}');
  }
}
