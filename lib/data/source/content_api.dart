import 'dart:typed_data';

import '../source/models/book_dto.dart';
import '../source/models/collection_dto.dart';
import '../source/models/library_dto.dart';
import '../source/models/page.dart';
import '../source/models/page_dto.dart';
import '../source/models/readlist_dto.dart';
import '../source/models/series_dto.dart';
import '../source/models/series_search.dart';
import '../source/models/server_info.dart';

/// Transport-agnostic content backend. Both `KomgaApi` and `KavitaApi` implement
/// this so repositories, the reader, sync, and offline never assume a single
/// server kind (CLAUDE.md: never assume a single source or a single server).
///
/// The signatures are exactly Komga's current ones; the shared `*Dto` types and
/// `ServerInfo` / `ContentException` are reused as the neutral transfer/error
/// contract (renaming to source-neutral names is a deferred cleanup). A backend
/// that does not support a given capability returns an empty result for list
/// reads and throws `ContentException` for mutations it cannot honour.
abstract class ContentApi {
  /// Probes the server: build version (nullable) plus the account's roles.
  Future<ServerInfo> validate();

  /// Best-effort build version; null when unavailable. Never throws.
  Future<String?> fetchVersion();

  /// Lightweight reachability probe for THIS server (not the internet). Returns
  /// true when the server answers (any HTTP status), false on a network/TLS
  /// error. Never throws.
  Future<bool> ping();

  Future<List<LibraryDto>> listLibraries();

  Future<Page<SeriesDto>> listSeries({
    required int page,
    int size,
    String? sort,
    SeriesSearch? search,
  });

  Future<Page<SeriesDto>> listSeriesNew({int page, int size});

  Future<Page<SeriesDto>> listSeriesUpdated({int page, int size});

  Future<SeriesDto> getSeries(String seriesId);

  Future<Page<BookDto>> listBooks({
    required int page,
    int size,
    String? sort,
    String? seriesId,
    SeriesSearch? search,
  });

  Future<Page<BookDto>> listBooksLatest({int page, int size});

  Future<BookDto> getBook(String bookId);

  Future<Page<BookDto>> onDeck({int page, int size});

  Future<List<PageDto>> bookPages(String bookId);

  Future<Uint8List> getPage(
    String bookId,
    int n, {
    bool zeroBased,
    String? convert,
    bool raw,
  });

  Future<Stream<List<int>>> downloadBookFile(String bookId);

  Future<void> patchReadProgress(
    String bookId, {
    required int page,
    required bool completed,
  });

  Future<void> deleteReadProgress(String bookId);

  Future<void> markSeriesRead(String seriesId);

  Future<void> markSeriesUnread(String seriesId);

  Future<(Uint8List, String?)> seriesThumbnail(String seriesId);

  Future<(Uint8List, String?)> bookThumbnail(String bookId);

  // Collections / read lists / referential data: Komga full; Kavita returns
  // empty for list reads and throws for mutations (UI gated to Komga sources).
  Future<Page<CollectionDto>> listCollections({int page, int size});

  Future<CollectionDto> getCollection(String id);

  Future<CollectionDto> createCollection({
    required String name,
    required List<String> seriesIds,
  });

  Future<void> updateCollection(
    String id, {
    required String name,
    required bool ordered,
    required List<String> seriesIds,
  });

  Future<void> deleteCollection(String id);

  Future<Page<SeriesDto>> collectionSeries(String collectionId,
      {int page, int size});

  Future<Page<ReadListDto>> listReadLists({int page, int size});

  Future<ReadListDto> getReadList(String id);

  Future<ReadListDto> createReadList({
    required String name,
    required List<String> bookIds,
  });

  Future<void> updateReadList(
    String id, {
    required String name,
    required bool ordered,
    required List<String> bookIds,
  });

  Future<void> deleteReadList(String id);

  Future<Page<BookDto>> readListBooks(String readListId, {int page, int size});

  Future<List<String>> listGenres();

  Future<List<String>> listTags();

  Future<List<String>> listPublishers();

  Future<List<int>> listAgeRatings();
}
