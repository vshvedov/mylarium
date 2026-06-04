import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/design_tokens.dart';
import '../../app/theme/theme_controller.dart' show appDatabaseProvider;
import '../../core/db/database.dart';
import 'widgets/cover_image.dart';

/// Book detail: metadata plus a Read action that opens the reader.
class BookDetailScreen extends ConsumerWidget {
  const BookDetailScreen({
    super.key,
    required this.sourceId,
    required this.bookId,
  });

  final String sourceId;
  final String bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<DesignTokens>()!;
    final bookAsync = ref.watch(_bookProvider((sourceId, bookId)));
    final book = bookAsync.valueOrNull;

    return Scaffold(
      appBar: AppBar(title: Text(book?.title ?? 'Book')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: SizedBox(
              width: 180,
              height: 270,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(tokens.coverRadius),
                child: CoverImage(
                  sourceId: sourceId,
                  ownerType: 'book',
                  ownerId: bookId,
                  title: book?.title ?? '',
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(book?.title ?? '',
              style: Theme.of(context).textTheme.titleLarge),
          if (book != null) ...[
            const SizedBox(height: 4),
            Text(
              [
                if (book.number.isNotEmpty) 'No. ${book.number}',
                if (book.pagesCount > 0) '${book.pagesCount} pages',
              ].join('  -  '),
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
          const SizedBox(height: 16),
          FilledButton.icon(
            icon: const Icon(Icons.menu_book),
            label: Text(
              (book?.readPage ?? 0) > 0 ? 'Continue reading' : 'Read',
            ),
            onPressed: () => context.push('/reader/$sourceId/$bookId'),
          ),
        ],
      ),
    );
  }
}

/// A cached book row (the series grid refreshed it on the way in).
final _bookProvider =
    FutureProvider.family<Book?, (String, String)>((ref, key) {
  return ref.watch(appDatabaseProvider).getBook(key.$1, key.$2);
});
