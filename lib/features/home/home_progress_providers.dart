import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/theme/theme_controller.dart' show appDatabaseProvider;
import '../library/library_browse_controllers.dart' show bookReadStateProvider;
import '../library/widgets/reading_progress.dart';

part 'home_progress_providers.g.dart';

/// The cached page count for a server book (from the Books row the home rails
/// and detail screens cache), or null when the book is not cached yet or
/// reports no pages. Backs the keep-reading rail's "p. X of Y" caption; a null
/// simply omits the bar + caption.
@riverpod
Future<int?> cachedBookPagesCount(
  Ref ref,
  String sourceId,
  String bookId,
) async {
  final book = await ref.watch(appDatabaseProvider).getBook(sourceId, bookId);
  final pages = book?.pagesCount ?? 0;
  return pages > 0 ? pages : null;
}

/// The page-progress footer for a keep-reading tile: resolves the authoritative
/// local read state ([bookReadStateProvider]) plus the cached page count and
/// renders the thin bar + "p. X of Y" caption. Renders nothing while either is
/// missing (e.g. an on-deck book with no progress yet, or a book whose row has
/// not been cached), so tiles degrade gracefully.
class BookReadingProgress extends ConsumerWidget {
  const BookReadingProgress({
    super.key,
    required this.sourceId,
    required this.bookId,
  });

  final String sourceId;
  final String bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state =
        ref.watch(bookReadStateProvider(sourceId, bookId)).valueOrNull;
    final total =
        ref.watch(cachedBookPagesCountProvider(sourceId, bookId)).valueOrNull;
    if (state == null || total == null) return const SizedBox.shrink();
    // BookState.currentPage is 0-based (reader-native); the caption is 1-based.
    return ReadingProgressLabel(current: state.currentPage + 1, total: total);
  }
}
