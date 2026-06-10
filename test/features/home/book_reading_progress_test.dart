import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/theme/app_theme.dart';
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/features/home/home_progress_providers.dart';
import 'package:mylarium/features/library/library_browse_controllers.dart';
import 'package:mylarium/features/library/widgets/reading_progress.dart';

BookStateRow _state({required int currentPage}) => BookStateRow(
      sourceId: 's1',
      bookId: 'b1',
      status: 'inProgress',
      currentPage: currentPage,
      timesReread: 0,
      isRereading: false,
      visibility: 'private',
      shareToFeed: false,
      updatedAt: 0,
    );

Widget _host({BookStateRow? state, int? pagesCount}) => ProviderScope(
      overrides: [
        bookReadStateProvider('s1', 'b1')
            .overrideWith((ref) => Stream<BookStateRow?>.value(state)),
        cachedBookPagesCountProvider('s1', 'b1')
            .overrideWith((ref) async => pagesCount),
      ],
      child: MaterialApp(
        theme: lightTheme,
        home: const Scaffold(
          body: Center(
            child: SizedBox(
              width: 156,
              child: BookReadingProgress(sourceId: 's1', bookId: 'b1'),
            ),
          ),
        ),
      ),
    );

void main() {
  testWidgets('renders the 1-based caption from the 0-based read state',
      (tester) async {
    await tester
        .pumpWidget(_host(state: _state(currentPage: 132), pagesCount: 219));
    await tester.pumpAndSettle();

    expect(find.text('p. 133 of 219'), findsOneWidget);
    expect(find.byType(ReadingProgressBar), findsOneWidget);
  });

  testWidgets('renders nothing without a read state (e.g. on-deck books)',
      (tester) async {
    await tester.pumpWidget(_host(state: null, pagesCount: 219));
    await tester.pumpAndSettle();

    expect(find.byType(ReadingProgressBar), findsNothing);
    expect(find.textContaining('p. '), findsNothing);
  });

  testWidgets('renders nothing when the page count is not cached',
      (tester) async {
    await tester
        .pumpWidget(_host(state: _state(currentPage: 3), pagesCount: null));
    await tester.pumpAndSettle();

    expect(find.byType(ReadingProgressBar), findsNothing);
    expect(find.textContaining('p. '), findsNothing);
  });
}
