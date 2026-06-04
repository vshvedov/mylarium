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
import '../../data/source/source_providers.dart';

part 'library_browse_controllers.g.dart';

/// On-Deck / Keep-Reading books for the active source. NOT age-gated: this is
/// the user's own in-progress reading.
@riverpod
Future<List<BookDto>> onDeck(Ref ref) async {
  final api = await ref.watch(activeKomgaApiProvider.future);
  if (api == null) return const [];
  try {
    return (await api.onDeck(size: 20)).content;
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

/// A single cached series row (for the series-detail header).
@riverpod
Future<SeriesRow?> seriesDetail(Ref ref, String sourceId, String seriesId) {
  return ref.watch(appDatabaseProvider).getSeries(sourceId, seriesId);
}
