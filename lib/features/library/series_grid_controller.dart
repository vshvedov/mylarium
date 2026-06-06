import '../../core/db/database.dart';
import '../../core/network/content_exception.dart';
import '../../data/repositories/series_repository.dart';

/// Keyset cursor over `(titleSort, id)`. A start cursor (both null) is the first
/// page.
class SeriesCursor {
  const SeriesCursor({this.titleSort, this.id});
  const SeriesCursor.start()
      : titleSort = null,
        id = null;

  final String? titleSort;
  final String? id;

  bool get isStart => titleSort == null || id == null;

  /// The cursor positioned after [row].
  factory SeriesCursor.after(SeriesRow row) =>
      SeriesCursor(titleSort: row.titleSort, id: row.id);
}

/// A keyset page result. Named distinctly from the Komga `Page<T>` envelope
/// (`lib/data/source/models/page.dart`) to avoid the collision.
class KeysetPage<T> {
  const KeysetPage(this.content, {required this.last});
  final List<T> content;
  final bool last;
}

/// Pages series from the LOCAL Drift cache via keyset, filling the cache on
/// demand from the network (OFFSET) when a requested page runs past what is
/// cached. This keeps the 50k-row scroll as pure SQLite keyset while network
/// sync is demand-driven (no unbounded background job).
///
/// `KeysetPage.last` is true only when the cache yields fewer than [pageSize]
/// rows AND the network sync is complete, so the grid never reports a false end
/// of list while the cache is still filling.
class SeriesGridController {
  SeriesGridController({
    required this.db,
    required this.repo,
    required this.sourceId,
    this.libraryId,
    this.hiddenLibraryIds = const {},
    this.pageSize = 60,
  });

  final AppDatabase db;
  final SeriesRepository repo;
  final String sourceId;
  final String? libraryId;

  /// Libraries whose series are excluded (locked).
  final Set<String> hiddenLibraryIds;
  final int pageSize;

  int _syncedPages = 0;
  int? _totalElements;
  bool _networkFailed = false;

  Future<bool> _syncComplete() async {
    if (_networkFailed) return true; // degrade to whatever is cached.
    final total = _totalElements;
    if (total == null) return false;
    // Bounded two ways so an inconsistent server (duplicate ids that collapse
    // on upsert, an over-counted total) can never loop forever: stop once the
    // cache holds every row OR we have fetched every server page.
    if (_syncedPages * pageSize >= total) return true;
    final cached = await db.seriesCount(sourceId, libraryId: libraryId);
    return cached >= total;
  }

  Future<List<SeriesRow>> _query(SeriesCursor after) => db.seriesPage(
        sourceId: sourceId,
        libraryId: libraryId,
        afterTitleSort: after.titleSort,
        afterId: after.id,
        limit: pageSize,
        hiddenLibraryIds: hiddenLibraryIds,
      );

  Future<void> _syncNextPage() async {
    try {
      _totalElements = await repo.refresh(
        sourceId,
        page: _syncedPages,
        size: pageSize,
        libraryId: libraryId,
      );
      _syncedPages++;
    } on ContentException {
      _networkFailed = true;
    }
  }

  Future<KeysetPage<SeriesRow>> page(SeriesCursor after) async {
    var rows = await _query(after);
    while (rows.length < pageSize && !await _syncComplete()) {
      await _syncNextPage();
      if (_networkFailed) break;
      rows = await _query(after);
    }
    final last = rows.length < pageSize && await _syncComplete();
    return KeysetPage(rows, last: last);
  }
}
