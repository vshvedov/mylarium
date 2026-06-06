import '../../core/db/database.dart';
import '../source/content_api.dart';
import '../source/models/mappers.dart';

/// Fetches books for a source and upserts them with [sourceId] attached.
class BookRepository {
  const BookRepository(this._db, this._api);

  final AppDatabase _db;
  final ContentApi _api;

  /// Refreshes one page of books (optionally scoped to [seriesId]); returns the
  /// server's total element count.
  Future<int> refresh(
    String sourceId, {
    String? seriesId,
    int page = 0,
    int size = 50,
    String? sort,
  }) async {
    final result = await _api.listBooks(
      page: page,
      size: size,
      sort: sort,
      seriesId: seriesId,
    );
    for (final dto in result.content) {
      await _db.upsertBook(bookToRow(sourceId, dto));
    }
    return result.totalElements;
  }
}
