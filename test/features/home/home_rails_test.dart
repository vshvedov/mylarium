import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/theme/app_theme.dart';
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/data/source/models/book_dto.dart';
import 'package:mylarium/data/source/models/series_dto.dart';
import 'package:mylarium/features/home/home_screen.dart';
import 'package:mylarium/features/library/library_browse_controllers.dart';
import 'package:mylarium/features/library/thumbnail_cache.dart';

import '../../support/test_scope.dart';

SeriesDto _series(String id, {required int booksCount}) => SeriesDto(
      id: id,
      libraryId: 'lib1',
      name: id,
      title: id,
      titleSort: id,
      booksCount: booksCount,
    );

BookDto _book(String id) => BookDto(
      id: id,
      seriesId: 'serA',
      libraryId: 'lib1',
      name: id,
      title: id,
      number: '1',
    );

void main() {
  testWidgets('home renames the series rails, adds a chapters rail, and decks '
      'only multi-book series', (tester) async {
    tester.view.physicalSize = const Size(430, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final scope = await TestScope.create();
    addTearDown(scope.db.close);
    // A source so the home resolves an active source (not the no-source state).
    await scope.db.upsertSource(const SourcesCompanion(
      id: Value('s1'),
      kind: Value('komga'),
      label: Value('T'),
    ));

    final multiAdded = _series('smA', booksCount: 3);
    final singleAdded = _series('sgA', booksCount: 1);
    final multiUpdated = _series('smU', booksCount: 2);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...scope.overrides,
          keepReadingProvider('s1')
              .overrideWith((ref) async => const <BookDto>[]),
          recentlyAddedBooksProvider('s1')
              .overrideWith((ref) async => [_book('b1')]),
          recentlyAddedSeriesProvider('s1')
              .overrideWith((ref) async => [multiAdded, singleAdded]),
          recentlyUpdatedSeriesProvider('s1')
              .overrideWith((ref) async => [multiUpdated]),
          // Keep tiles on the placeholder path (no real cover fetch).
          coverImageProvider('s1', 'book', 'b1').overrideWith((ref) async => null),
          coverImageProvider('s1', 'series', 'smA')
              .overrideWith((ref) async => null),
          coverImageProvider('s1', 'series', 'sgA')
              .overrideWith((ref) async => null),
          coverImageProvider('s1', 'series', 'smU')
              .overrideWith((ref) async => null),
        ],
        child: MaterialApp(theme: lightTheme, home: const HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // Renamed series rails + the new chapters rail.
    expect(find.text('Recently added chapters'), findsOneWidget);
    expect(find.text('Recently added series'), findsOneWidget);
    expect(find.text('Recently updated series'), findsOneWidget);
    expect(find.text('Recently added'), findsNothing);
    expect(find.text('Recently updated'), findsNothing);

    // Exactly the two multi-book series tiles are decked; the single-book series
    // and the chapter tile are flat.
    expect(find.byKey(const ValueKey('coverDeck')), findsNWidgets(2));

    // Dispose the tree so stream subscriptions are torn down before the
    // pending-timer invariant runs.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
}
