import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/theme/theme_controller.dart' show appDatabaseProvider;
import '../../core/age_rating.dart';
import '../../core/db/database.dart';
import '../../core/network/komga_exception.dart';
import '../../core/security/app_lock.dart';
import '../../data/komga/models/book_dto.dart';
import '../../data/komga/models/collection_dto.dart';
import '../../data/komga/models/readlist_dto.dart';
import '../../data/komga/models/series_dto.dart';
import '../../data/komga/models/series_search.dart';
import '../../data/source/source_providers.dart';

part 'library_browse_controllers.g.dart';

/// Keep-reading books for the active source: the user's in-progress books first
/// (most recently read), then on-deck (the next book in a series with a
/// completed book) appended and de-duplicated. NOT age-gated (the user's own
/// reading). Komga's `/books/ondeck` alone only surfaces next-after-completed,
/// so a reader mid-book would see an empty rail; the in-progress query fixes it.
@riverpod
Future<List<BookDto>> keepReading(Ref ref) async {
  final api = await ref.watch(activeKomgaApiProvider.future);
  if (api == null) return const [];
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
    return [
      ...inProgress,
      for (final b in deck)
        if (seen.add(b.id)) b,
    ].take(20).toList();
  } on KomgaException {
    return const [];
  }
}

/// Recently added series. Age-gated by each series' own ageRating + its
/// library's prefs (no series cache needed, so no leak on a fresh install).
@riverpod
Future<List<SeriesDto>> recentlyAddedSeries(Ref ref) async {
  final api = await ref.watch(activeKomgaApiProvider.future);
  if (api == null) return const [];
  final lock = await ref.watch(appLockProvider.future);
  try {
    final page = await api.listSeriesNew(size: 20);
    return _gate(page.content, lock);
  } on KomgaException {
    return const [];
  }
}

/// Recently updated series. Age-gated like [recentlyAddedSeries].
@riverpod
Future<List<SeriesDto>> recentlyUpdatedSeries(Ref ref) async {
  final api = await ref.watch(activeKomgaApiProvider.future);
  if (api == null) return const [];
  final lock = await ref.watch(appLockProvider.future);
  try {
    final page = await api.listSeriesUpdated(size: 20);
    return _gate(page.content, lock);
  } on KomgaException {
    return const [];
  }
}

List<SeriesDto> _gate(List<SeriesDto> series, AppLockState lock) => [
      for (final s in series)
        if (!isRestrictedAgeRating(s.ageRating) ||
            lock.restrictedVisible(s.libraryId))
          s,
    ];

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
  final api = await ref.watch(activeKomgaApiProvider.future);
  if (api == null) return const [];
  final lock = await ref.watch(appLockProvider.future);
  try {
    final page = await api.collectionSeries(collectionId);
    return _gate(page.content, lock);
  } on KomgaException {
    return const [];
  }
}

/// Books in a read list (not age-gated; a curated reading order).
@riverpod
Future<List<BookDto>> readListBooks(Ref ref, String readListId) async {
  final api = await ref.watch(activeKomgaApiProvider.future);
  if (api == null) return const [];
  try {
    final page = await api.readListBooks(readListId);
    return page.content;
  } on KomgaException {
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
    } on KomgaException {
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
    } on KomgaException {
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
  final api = await ref.watch(komgaApiForProvider(sourceId).future);
  if (api == null) return null;
  try {
    return await api.getBook(bookId);
  } on KomgaException {
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
  final api = await ref.watch(komgaApiForProvider(sourceId).future);
  if (api == null) return null;
  try {
    return await api.getSeries(seriesId);
  } on KomgaException {
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
  final api = await ref.watch(activeKomgaApiProvider.future);
  if (api == null) return const [];
  try {
    return await api.listGenres();
  } on KomgaException {
    return const [];
  }
}

/// All tags on the active source (filter chips). Empty on any error/offline.
@riverpod
Future<List<String>> tags(Ref ref) async {
  final api = await ref.watch(activeKomgaApiProvider.future);
  if (api == null) return const [];
  try {
    return await api.listTags();
  } on KomgaException {
    return const [];
  }
}

/// All publishers on the active source (filter chips). Empty on error/offline.
@riverpod
Future<List<String>> publishers(Ref ref) async {
  final api = await ref.watch(activeKomgaApiProvider.future);
  if (api == null) return const [];
  try {
    return await api.listPublishers();
  } on KomgaException {
    return const [];
  }
}

/// Age ratings present on the active source (filter chips). Empty hides the
/// group (there is no fixed Komga age ladder).
@riverpod
Future<List<int>> ageRatings(Ref ref) async {
  final api = await ref.watch(activeKomgaApiProvider.future);
  if (api == null) return const [];
  try {
    final list = await api.listAgeRatings();
    return list..sort();
  } on KomgaException {
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
  } on KomgaException {
    return null;
  }
}
