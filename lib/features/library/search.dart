import 'dart:async';

import 'package:flutter/material.dart';
import '../../app/l10n.dart';
import '../../app/theme/app_icons.dart';
import '../../app/widgets/app_loading.dart';
import '../../app/widgets/app_text_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/security/app_lock.dart';
import '../../data/source/models/series_dto.dart';
import '../../data/source/models/series_search.dart';
import '../../data/source/source_providers.dart';
import 'library_browse_controllers.dart';
import 'widgets/item_context_menu.dart';
import 'widgets/library_tiles.dart';

/// Sort options for series search.
enum SeriesSort {
  relevance('Relevance', null),
  titleAsc('Title A-Z', 'metadata.titleSort,asc'),
  titleDesc('Title Z-A', 'metadata.titleSort,desc'),
  recentlyAdded('Recently added', 'createdDate,desc'),
  recentlyUpdated('Recently updated', 'lastModifiedDate,desc');

  const SeriesSort(this.label, this.value);

  /// English label, retained for non-UI/debug use; the UI uses
  /// [localizedLabel].
  final String label;
  final String? value;

  /// Localized menu label.
  String localizedLabel(BuildContext context) => switch (this) {
        SeriesSort.relevance => context.l10n.searchSortRelevance,
        SeriesSort.titleAsc => context.l10n.sortTitleAsc,
        SeriesSort.titleDesc => context.l10n.sortTitleDesc,
        SeriesSort.recentlyAdded => context.l10n.searchSortRecentlyAdded,
        SeriesSort.recentlyUpdated => context.l10n.searchSortRecentlyUpdated,
      };
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

  // Komga series and read status codes (the API values; labels are localized
  // at render via [_statusLabel] / [_readStatusLabel]).
  static const _statusCodes = ['ONGOING', 'ENDED', 'HIATUS', 'ABANDONED'];
  static const _readStatusCodes = ['UNREAD', 'IN_PROGRESS', 'READ'];

  String _statusLabel(BuildContext context, String code) => switch (code) {
        'ONGOING' => context.l10n.statusOngoing,
        'ENDED' => context.l10n.statusEnded,
        'HIATUS' => context.l10n.statusHiatus,
        'ABANDONED' => context.l10n.statusAbandoned,
        _ => code,
      };

  String _readStatusLabel(BuildContext context, String code) => switch (code) {
        'UNREAD' => context.l10n.readStatusUnread,
        'IN_PROGRESS' => context.l10n.readStatusInProgress,
        'READ' => context.l10n.readStatusRead,
        _ => code,
      };

  AsyncValue<List<SeriesDto>> _results = const AsyncData([]);

  /// Debounce for live, as-you-type querying: each keystroke reschedules the
  /// run so we only hit the server once typing settles.
  static const _debounceDelay = Duration(milliseconds: 300);
  Timer? _debounce;

  /// Monotonic id of the latest requested search. A slow earlier request whose
  /// id no longer matches is discarded so out-of-order responses cannot clobber
  /// the results of a newer query.
  int _searchSeq = 0;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// Reschedules a debounced live search as the user types.
  void _onQueryChanged(String v) {
    _query = v;
    _debounce?.cancel();
    _debounce = Timer(_debounceDelay, _run);
  }

  /// True when at least one filter chip is active. A filter-only selection
  /// (no text) is still a real query worth running.
  bool get _hasFilters =>
      _libraryIds.isNotEmpty ||
      _status.isNotEmpty ||
      _readStatus.isNotEmpty ||
      _genres.isNotEmpty ||
      _tags.isNotEmpty ||
      _publishers.isNotEmpty ||
      _ageRatings.isNotEmpty;

  Future<void> _run() async {
    _debounce?.cancel();
    final seq = ++_searchSeq;
    // With nothing typed and no filter active, stay idle rather than listing
    // the whole library.
    if (_query.trim().isEmpty && !_hasFilters) {
      setState(() => _results = const AsyncData([]));
      return;
    }
    final repo = await ref.read(searchRepositoryProvider.future);
    if (seq != _searchSeq) return;
    if (repo == null) {
      setState(() => _results = const AsyncData([]));
      return;
    }
    final lock = await ref.read(appLockProvider.future);
    if (seq != _searchSeq) return;
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
      // Series in a locked library are never surfaced in search; revealing them
      // requires unlocking the library.
      if (seq != _searchSeq) return;
      final results = [
        for (final s in page.content)
          if (!lock.isLocked(s.libraryId)) s,
      ];
      if (mounted) setState(() => _results = AsyncData(results));
    } catch (e, st) {
      if (seq != _searchSeq) return;
      if (mounted) setState(() => _results = AsyncError(e, st));
    }
  }

  @override
  Widget build(BuildContext context) {
    final libraries = ref.watch(librariesProvider).valueOrNull ?? const [];
    final sourceId = ref.watch(activeSourceIdProvider).valueOrNull ?? '';
    // A locked library is hidden everywhere: no chip until the lock state has
    // resolved (null while loading), and a selected filter pointing at a
    // now-locked library is dropped so the query cannot keep targeting it
    // (re-running so stale results do not linger). Results are independently
    // lock-filtered in [_run].
    final lock = ref.watch(appLockProvider).valueOrNull;
    if (lock != null && _libraryIds.any(lock.isLocked)) {
      _libraryIds.removeWhere(lock.isLocked);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _run();
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: AppTextField(
          controller: _controller,
          autofocus: true,
          dense: true,
          hint: context.l10n.searchHint,
          prefixIcon: AppIcons.search,
          textInputAction: TextInputAction.search,
          onChanged: _onQueryChanged,
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
                PopupMenuItem(value: s, child: Text(s.localizedLabel(context))),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _filterRow([
            if (lock != null)
              for (final lib in libraries)
                if (!lock.isLocked(lib.id))
                  _chip(lib.name, _libraryIds.contains(lib.id), (sel) {
                    setState(() => sel
                        ? _libraryIds.add(lib.id)
                        : _libraryIds.remove(lib.id));
                    _run();
                  }),
          ]),
          _filterRow([
            for (final code in _statusCodes)
              _chip(_statusLabel(context, code), _status.contains(code), (sel) {
                setState(() =>
                    sel ? _status.add(code) : _status.remove(code));
                _run();
              }),
            for (final code in _readStatusCodes)
              _chip(_readStatusLabel(context, code), _readStatus.contains(code),
                  (sel) {
                setState(() => sel
                    ? _readStatus.add(code)
                    : _readStatus.remove(code));
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
                  const AppLoadingIndicator(),
              error: (e, _) =>
                  Center(child: Text(context.l10n.searchFailed('$e'))),
              data: (series) => series.isEmpty
                  ? Center(
                      child: Text(
                        _query.trim().isEmpty && !_hasFilters
                            ? context.l10n.searchPrompt
                            : context.l10n.searchNoResults,
                      ),
                    )
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
                          onLongPress: () => showItemContextMenu(
                            context,
                            sourceId: sourceId,
                            ownerType: 'series',
                            ownerId: s.id,
                            title: s.title,
                          ),
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
