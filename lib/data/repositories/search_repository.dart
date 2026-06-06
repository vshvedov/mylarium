import '../source/content_api.dart';
import '../source/models/book_dto.dart';
import '../source/models/page.dart';
import '../source/models/series_dto.dart';
import '../source/models/series_search.dart';

/// Online-only full-text search over a source (results are not persisted in
/// T2). Wraps the list endpoints with a [SeriesSearch] carrying the query.
class SearchRepository {
  const SearchRepository(this._api);

  final ContentApi _api;

  Future<Page<SeriesDto>> searchSeries(
    String query, {
    int page = 0,
    int size = 50,
  }) =>
      _api.listSeries(
        page: page,
        size: size,
        search: SeriesSearch(fullText: query),
      );

  /// Search with structured filters (library, status, age, etc.). The age
  /// filter here is an explicit user choice, distinct from the automatic
  /// hide-restricted gate applied to the grid/rails.
  Future<Page<SeriesDto>> searchSeriesWith(
    SeriesSearch search, {
    int page = 0,
    int size = 50,
    String? sort,
  }) =>
      _api.listSeries(page: page, size: size, sort: sort, search: search);

  Future<Page<BookDto>> searchBooks(
    String query, {
    int page = 0,
    int size = 50,
  }) =>
      _api.listBooks(
        page: page,
        size: size,
        search: SeriesSearch(fullText: query),
      );
}
