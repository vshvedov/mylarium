import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/theme/theme_controller.dart' show appDatabaseProvider;
import '../../core/network/komga_exception.dart';
import '../../data/repositories/book_repository.dart';
import '../../data/source/source_providers.dart';

part 'reader_navigation.g.dart';

/// The previous/next book of the current series, for in-reader chapter navigation
/// and the end-of-book seam (T4). Either side is null at a boundary or when the
/// neighbor is not in the cached series order.
class BookNeighbors {
  const BookNeighbors({
    this.prevId,
    this.prevTitle,
    this.nextId,
    this.nextTitle,
  });

  final String? prevId;
  final String? prevTitle;
  final String? nextId;
  final String? nextTitle;

  bool get hasNext => nextId != null;
  bool get hasPrev => prevId != null;
}

/// Resolves the prev/next book within a series, ordered exactly like the series
/// detail list (numberSort, then number). Best-effort online refresh first (so a
/// partially-cached series fills in) using a SOURCE-SCOPED api (a book may live on
/// a non-active server); offline it resolves from the cache alone. Returns empty
/// neighbors when the book is not found in the cached order.
@riverpod
Future<BookNeighbors> bookNeighbors(
  Ref ref,
  String sourceId,
  String seriesId,
  String bookId,
) async {
  final db = ref.watch(appDatabaseProvider);
  final api = await ref.watch(komgaApiForProvider(sourceId).future);
  if (api != null) {
    try {
      await BookRepository(db, api)
          .refresh(sourceId, seriesId: seriesId, size: 100);
    } on KomgaException {
      // Server unreachable / auth expired: resolve from the cache below.
    }
  }

  final books = await db.getBooksForSeriesOrdered(sourceId, seriesId);
  final i = books.indexWhere((b) => b.id == bookId);
  if (i < 0) return const BookNeighbors();
  return BookNeighbors(
    prevId: i > 0 ? books[i - 1].id : null,
    prevTitle: i > 0 ? books[i - 1].title : null,
    nextId: i < books.length - 1 ? books[i + 1].id : null,
    nextTitle: i < books.length - 1 ? books[i + 1].title : null,
  );
}
