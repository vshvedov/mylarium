import '../komga/komga_api.dart';
import '../komga/models/book_dto.dart';
import '../komga/models/page.dart';
import '../komga/models/series_dto.dart';
import '../komga/models/series_search.dart';

/// Online-only full-text search over a source (results are not persisted in
/// T2). Wraps the list endpoints with a [SeriesSearch] carrying the query.
class SearchRepository {
  const SearchRepository(this._api);

  final KomgaApi _api;

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
