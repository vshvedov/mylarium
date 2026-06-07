import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/theme/theme_controller.dart' show appDatabaseProvider;
import '../../core/db/database.dart';
import '../../core/network/content_exception.dart';
import '../../core/security/app_lock.dart';
import '../../data/source/models/book_dto.dart';
import '../../data/source/models/collection_dto.dart';
import '../../data/source/models/mappers.dart';
import '../../data/source/models/readlist_dto.dart';
import '../../data/source/models/series_dto.dart';
import '../../data/source/models/series_search.dart';
import '../../data/source/source_providers.dart';
import 'rail_item.dart';

part 'library_browse_controllers.g.dart';

/// Keep-reading books for the active source: the user's in-progress books first
/// (most recently read), then on-deck (the next book in a series with a
/// completed book) appended and de-duplicated. Books in a locked library are
/// hidden. Komga's `/books/ondeck` alone only surfaces next-after-completed, so a
/// reader mid-book would see an empty rail; the in-progress query fixes it.
@riverpod
Stream<List<RailItem>> keepReading(Ref ref, String sourceId) async* {
  if (sourceId.isEmpty) {
    yield const [];
    return;
  }
  final lock = await ref.watch(appLockProvider.future);
  final cached = await _resolveSnapshot(ref, sourceId, 'keepReading', lock);
  if (cached != null) yield cached; // warm: instant render

  final api = await ref.watch(contentApiForProvider(sourceId).future);
  if (api == null) {
    if (cached == null) yield const [];
    return;
  }
  try {
    final inProgress = (await api.listBooks(
      page: 0,
      size: 20,
      sort: 'readDate,desc',
      search: const SeriesSearch(readStatus: ['IN_PROGRESS']),
    ))
        .content;
    final deck = (await api.onDeck(size: 20)).content;
    final seen = {for (final b in inProgress) b.id};
    final result = [
      ...inProgress,
      for (final b in deck)
        if (seen.add(b.id)) b,
    ].where((b) => !lock.isLocked(b.libraryId)).take(20).toList();
    await _cacheBooks(ref, sourceId, result);
    await _writeSnapshot(ref, sourceId, 'keepReading',
        [for (final b in result) (ownerType: 'book', ownerId: b.id)]);
    yield [for (final b in result) RailItem.fromBookDto(b)];
  } on ContentException {
    if (cached == null) yield const [];
  }
}

/// Recently added series. Age-gated by each series' own ageRating + its
/// library's prefs (no series cache needed, so no leak on a fresh install).
@riverpod
Stream<List<RailItem>> recentlyAddedSeries(Ref ref, String sourceId) async* {
  if (sourceId.isEmpty) {
    yield const [];
    return;
  }
  final lock = await ref.watch(appLockProvider.future);
  final cached =
      await _resolveSnapshot(ref, sourceId, 'recentlyAddedSeries', lock);
  if (cached != null) yield cached;

  final api = await ref.watch(contentApiForProvider(sourceId).future);
  if (api == null) {
    if (cached == null) yield const [];
    return;
  }
  try {
    final page = await api.listSeriesNew(size: 20);
    await _cacheSeries(ref, sourceId, page.content);
    await _writeSnapshot(ref, sourceId, 'recentlyAddedSeries',
        [for (final s in page.content) (ownerType: 'series', ownerId: s.id)]);
    yield [for (final s in _gate(page.content, lock)) RailItem.fromSeriesDto(s)];
  } on ContentException {
    if (cached == null) yield const [];
  }
}

/// Recently updated series. Age-gated like [recentlyAddedSeries].
@riverpod
Stream<List<RailItem>> recentlyUpdatedSeries(Ref ref, String sourceId) async* {
  if (sourceId.isEmpty) {
    yield const [];
    return;
  }
  final lock = await ref.watch(appLockProvider.future);
  final cached =
      await _resolveSnapshot(ref, sourceId, 'recentlyUpdatedSeries', lock);
  if (cached != null) yield cached;

  final api = await ref.watch(contentApiForProvider(sourceId).future);
  if (api == null) {
    if (cached == null) yield const [];
    return;
  }
  try {
    final page = await api.listSeriesUpdated(size: 20);
    await _cacheSeries(ref, sourceId, page.content);
    await _writeSnapshot(ref, sourceId, 'recentlyUpdatedSeries',
        [for (final s in page.content) (ownerType: 'series', ownerId: s.id)]);
    yield [for (final s in _gate(page.content, lock)) RailItem.fromSeriesDto(s)];
  } on ContentException {
    if (cached == null) yield const [];
  }
}

/// Hides series whose library is locked.
List<SeriesDto> _gate(List<SeriesDto> series, AppLockState lock) =>
    [for (final s in series) if (!lock.isLocked(s.libraryId)) s];

/// Persists series fetched for a home rail into the local cache (title +
/// ageRating + libraryId + booksCount), so anything shown on Home can be pinned
/// and rendered/gated offline by the Pinned rail. Caches the full (ungated) set:
/// the cache is the source of truth, and the rail's own gate still hides
/// restricted entries at display time. Best-effort; a write failure is ignored.
Future<void> _cacheSeries(Ref ref, String sourceId, List<SeriesDto> series) async {
  if (series.isEmpty) return;
  try {
    final db = ref.read(appDatabaseProvider);
    for (final s in series) {
      await db.upsertSeries(seriesToRow(sourceId, s));
      await db.upsertSeriesMeta(seriesMetaToRow(sourceId, s));
    }
  } catch (_) {
    // Best-effort: a cache write must never break the rail it backs.
  }
}

/// Persists books fetched for a home rail into the local cache, so a pinned
/// chapter resolves its title/number on the Pinned rail. Best-effort.
Future<void> _cacheBooks(Ref ref, String sourceId, List<BookDto> books) async {
  if (books.isEmpty) return;
  try {
    final db = ref.read(appDatabaseProvider);
    for (final b in books) {
      await db.upsertBook(bookToRow(sourceId, b));
    }
  } catch (_) {
    // Best-effort: a cache write must never break the rail it backs.
  }
}

/// Resolves a rail's saved snapshot into gated [RailItem]s for an instant warm
/// render. Returns null only when no snapshot exists at all (cold launch -> the
/// provider stays in loading and the home shows a skeleton); a snapshot that
/// exists but whose owner rows are not (yet) cached resolves to a shorter list,
/// not null, since those individual rows are silently dropped. Re-gates by the
/// owner's library so a now-locked library's item never shows from a stale
/// snapshot.
Future<List<RailItem>?> _resolveSnapshot(
  Ref ref,
  String sourceId,
  String railKind,
  AppLockState lock,
) async {
  final raw = await ref.read(appDatabaseProvider).getRailSnapshot(
        sourceId,
        railKind,
      );
  if (raw.isEmpty) return null; // no snapshot -> cold
  return [
    for (final r in raw)
      if (r.title != null &&
          r.libraryId != null &&
          !lock.isLocked(r.libraryId!))
        r.ownerType == 'series'
            ? RailItem(
                ownerType: 'series',
                ownerId: r.ownerId,
                title: r.title!,
                stacked: r.booksCount > 1,
              )
            : RailItem(
                ownerType: 'book',
                ownerId: r.ownerId,
                title: r.title!,
                subtitle: (r.number == null || r.number!.isEmpty)
                    ? null
                    : 'No. ${r.number}',
              ),
  ];
}

/// Persists a rail's fresh membership so the next launch renders it instantly.
Future<void> _writeSnapshot(
  Ref ref,
  String sourceId,
  String railKind,
  List<({String ownerType, String ownerId})> items,
) async {
  try {
    await ref
        .read(appDatabaseProvider)
        .replaceRailSnapshot(sourceId, railKind, items);
  } catch (_) {
    // Best-effort: a snapshot write must never break the rail it backs.
  }
}

/// Recently added chapters (Komga `books/latest`). Books in a locked library are
/// hidden (by the book's own libraryId). Degrades to empty on a Komga error.
///
/// The snapshot key is `recentlyAddedChapters` (matching
/// `HomeRailKind.recentlyAddedChapters.name`, the rail this provider backs), not
/// the provider name `recentlyAddedBooks`. Keep them in sync with the enum, not
/// with each other.
@riverpod
Stream<List<RailItem>> recentlyAddedBooks(Ref ref, String sourceId) async* {
  if (sourceId.isEmpty) {
    yield const [];
    return;
  }
  final lock = await ref.watch(appLockProvider.future);
  final cached =
      await _resolveSnapshot(ref, sourceId, 'recentlyAddedChapters', lock);
  if (cached != null) yield cached;

  final api = await ref.watch(contentApiForProvider(sourceId).future);
  if (api == null) {
    if (cached == null) yield const [];
    return;
  }
  try {
    final books = (await api.listBooksLatest(size: 20)).content;
    await _cacheBooks(ref, sourceId, books);
    await _writeSnapshot(ref, sourceId, 'recentlyAddedChapters',
        [for (final b in books) (ownerType: 'book', ownerId: b.id)]);
    yield [
      for (final b in books)
        if (!lock.isLocked(b.libraryId)) RailItem.fromBookDto(b),
    ];
  } on ContentException {
    if (cached == null) yield const [];
  }
}

/// Recently finished chapters for the active source, newest first. Cache-backed
/// (local completed state via [AppDatabase.watchRecentlyReadBooks]), so it works
/// offline. Books in a locked library are hidden.
@riverpod
Stream<List<Book>> recentlyRead(Ref ref, String sourceId) async* {
  if (sourceId.isEmpty) {
    yield const [];
    return;
  }
  final lock = await ref.watch(appLockProvider.future);
  yield* ref.watch(appDatabaseProvider).watchRecentlyReadBooks(sourceId).map(
        (books) => [for (final b in books) if (!lock.isLocked(b.libraryId)) b],
      );
}

@riverpod
Future<List<CollectionDto>> collections(Ref ref) async {
  final repo = await ref.watch(collectionRepositoryProvider.future);
  if (repo == null) return const [];
  return repo.list();
}

@riverpod
Future<List<ReadListDto>> readLists(Ref ref) async {
  final repo = await ref.watch(readListRepositoryProvider.future);
  if (repo == null) return const [];
  return repo.list();
}

/// Series in a collection, age-gated like the rails (by each series' own
/// ageRating + its library prefs).
@riverpod
Future<List<SeriesDto>> collectionSeries(Ref ref, String collectionId) async {
  final api = await ref.watch(activeContentApiProvider.future);
  if (api == null) return const [];
  final lock = await ref.watch(appLockProvider.future);
  try {
    final page = await api.collectionSeries(collectionId);
    return _gate(page.content, lock);
  } on ContentException {
    return const [];
  }
}

/// Books in a read list (not age-gated; a curated reading order).
@riverpod
Future<List<BookDto>> readListBooks(Ref ref, String readListId) async {
  final api = await ref.watch(activeContentApiProvider.future);
  if (api == null) return const [];
  try {
    final page = await api.readListBooks(readListId);
    return page.content;
  } on ContentException {
    return const [];
  }
}

/// Libraries for the active source (drives the lock-settings screen and library
/// grid entry). Refreshes from the server on first watch, then streams the
/// cache.
@riverpod
Stream<List<Library>> libraries(Ref ref) async* {
  final sourceId = await ref.watch(activeSourceIdProvider.future);
  if (sourceId == null) {
    yield const [];
    return;
  }
  final repo = await ref.watch(libraryRepositoryProvider.future);
  if (repo != null) {
    try {
      await repo.refresh(sourceId);
    } on ContentException {
      // Fall back to whatever is cached.
    }
  }
  yield* ref.watch(appDatabaseProvider).watchLibraries(sourceId);
}

/// A series' books, streamed from the cache. Kicks an online refresh first.
@riverpod
Stream<List<Book>> seriesBooks(Ref ref, String sourceId, String seriesId) async* {
  final repo = await ref.watch(bookRepositoryProvider.future);
  if (repo != null) {
    try {
      await repo.refresh(sourceId, seriesId: seriesId, size: 100);
    } on ContentException {
      // Cached books still stream below.
    }
  }
  yield* ref.watch(appDatabaseProvider).watchBooksForSeries(sourceId, seriesId);
}

// --- T3: read-state, detail DTOs, ratings, filter referentials -----------

/// The book's local read state (the authoritative source for the completed
/// badge and percent; survives a Books-cache refresh).
@riverpod
Stream<BookStateRow?> bookReadState(Ref ref, String sourceId, String bookId) =>
    ref.watch(appDatabaseProvider).watchBookState(sourceId, bookId);

/// The local read state of every book of a series that has one, for the series
/// grid badges (books without a row fall back to the cached `Books.completed`).
@riverpod
Stream<List<BookStateRow>> seriesReadStates(
  Ref ref,
  String sourceId,
  String seriesId,
) =>
    ref.watch(appDatabaseProvider).watchSeriesReadStates(sourceId, seriesId);

/// The live Komga book, fetched for the richer detail metadata. Null offline
/// (the screen falls back to the cached row).
@riverpod
Future<BookDto?> bookDetailDto(Ref ref, String sourceId, String bookId) async {
  final api = await ref.watch(contentApiForProvider(sourceId).future);
  if (api == null) return null;
  try {
    return await api.getBook(bookId);
  } on ContentException {
    return null;
  }
}

/// The live Komga series, fetched for the richer detail metadata. Null offline.
@riverpod
Future<SeriesDto?> seriesDetailDto(
  Ref ref,
  String sourceId,
  String seriesId,
) async {
  final api = await ref.watch(contentApiForProvider(sourceId).future);
  if (api == null) return null;
  try {
    return await api.getSeries(seriesId);
  } on ContentException {
    return null;
  }
}

/// The local star rating for a book (null when unset).
@riverpod
Future<int?> bookRating(Ref ref, String sourceId, String bookId) async =>
    (await ref.watch(appDatabaseProvider).getBookState(sourceId, bookId))
        ?.rating;

/// The local star rating for a series (null when unset).
@riverpod
Future<int?> seriesRating(Ref ref, String sourceId, String seriesId) async =>
    (await ref.watch(appDatabaseProvider).getSeriesMeta(sourceId, seriesId))
        ?.rating;

/// All genres on the active source (filter chips). Empty on any error/offline.
@riverpod
Future<List<String>> genres(Ref ref) async {
  final api = await ref.watch(activeContentApiProvider.future);
  if (api == null) return const [];
  try {
    return await api.listGenres();
  } on ContentException {
    return const [];
  }
}

/// All tags on the active source (filter chips). Empty on any error/offline.
@riverpod
Future<List<String>> tags(Ref ref) async {
  final api = await ref.watch(activeContentApiProvider.future);
  if (api == null) return const [];
  try {
    return await api.listTags();
  } on ContentException {
    return const [];
  }
}

/// All publishers on the active source (filter chips). Empty on error/offline.
@riverpod
Future<List<String>> publishers(Ref ref) async {
  final api = await ref.watch(activeContentApiProvider.future);
  if (api == null) return const [];
  try {
    return await api.listPublishers();
  } on ContentException {
    return const [];
  }
}

/// Age ratings present on the active source (filter chips). Empty hides the
/// group (there is no fixed Komga age ladder).
@riverpod
Future<List<int>> ageRatings(Ref ref) async {
  final api = await ref.watch(activeContentApiProvider.future);
  if (api == null) return const [];
  try {
    final list = await api.listAgeRatings();
    return list..sort();
  } on ContentException {
    return const [];
  }
}

/// A single cached series row (for the series-detail header).
@riverpod
Future<SeriesRow?> seriesDetail(
  Ref ref,
  String sourceId,
  String seriesId,
) async {
  final db = ref.watch(appDatabaseProvider);
  final cached = await db.getSeries(sourceId, seriesId);
  if (cached != null) return cached;
  // Cache miss (series opened without its row synced, e.g. via search or a deep
  // link): fetch the single series so the real Komga title/metadata shows
  // instead of a fallback. Offline stays graceful (returns null).
  final repo = await ref.watch(seriesRepositoryProvider.future);
  if (repo == null) return null;
  try {
    return await repo.fetchSeries(sourceId, seriesId);
  } on ContentException {
    return null;
  }
}
