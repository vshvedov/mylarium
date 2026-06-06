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

void main() {
  testWidgets('the Pinned rail shows pinned items and long-press unpins',
      (tester) async {
    tester.view.physicalSize = const Size(430, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final scope = await TestScope.create();
    addTearDown(scope.db.close);
    await scope.db.upsertSource(const SourcesCompanion(
      id: Value('s1'),
      kind: Value('komga'),
      label: Value('T'),
    ));
    // A cached series row so the pin resolves its title + gating, plus the pin.
    await scope.db.upsertSeries(const SeriesCompanion(
      sourceId: Value('s1'),
      id: Value('serP'),
      libraryId: Value('lib1'),
      title: Value('Pinned Series'),
      titleSort: Value('Pinned Series'),
      booksCount: Value(3),
    ));
    await scope.db.setPinned('s1', 'series', 'serP', pinned: true, now: 100);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...scope.overrides,
          keepReadingProvider('s1')
              .overrideWith((ref) async => const <BookDto>[]),
          recentlyAddedBooksProvider('s1')
              .overrideWith((ref) async => const <BookDto>[]),
          recentlyAddedSeriesProvider('s1')
              .overrideWith((ref) async => const <SeriesDto>[]),
          recentlyUpdatedSeriesProvider('s1')
              .overrideWith((ref) async => const <SeriesDto>[]),
          coverImageProvider('s1', 'series', 'serP')
              .overrideWith((ref) async => null),
        ],
        child: MaterialApp(theme: lightTheme, home: const HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // The Pinned rail and its tile render.
    expect(find.text('Pinned'), findsOneWidget);
    expect(find.text('Pinned Series'), findsOneWidget);

    // Long-pressing the tile opens the context menu showing "Unpin".
    await tester.longPress(find.text('Pinned Series'));
    await tester.pumpAndSettle();
    expect(find.text('Unpin'), findsOneWidget);

    // Tapping "Unpin" removes the pin; the rail (now empty) disappears.
    await tester.tap(find.text('Unpin'));
    await tester.pumpAndSettle();
    expect(find.text('Pinned'), findsNothing);
    expect(find.text('Pinned Series'), findsNothing);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
}
