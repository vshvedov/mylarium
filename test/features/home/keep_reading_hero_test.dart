import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/theme/app_theme.dart';
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/features/home/home_progress_providers.dart';
import 'package:mylarium/features/home/home_screen.dart';
import 'package:mylarium/features/library/library_browse_controllers.dart';
import 'package:mylarium/features/library/rail_item.dart';
import 'package:mylarium/features/library/thumbnail_cache.dart';
import 'package:mylarium/features/library/widgets/library_tiles.dart';
import 'package:mylarium/features/library/widgets/rail.dart';

import '../../support/test_scope.dart';

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

void main() {
  testWidgets(
      'the keep-reading rail renders hero tiles with the page-progress '
      'caption; other rails keep the standard tile', (tester) async {
    tester.view.physicalSize = const Size(430, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final scope = await TestScope.create();
    addTearDown(scope.db.close);
    await scope.db.upsertSource(const SourcesCompanion(
      id: Value('s1'), kind: Value('komga'), label: Value('T')));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...scope.overrides,
          keepReadingProvider('s1').overrideWith(
            (ref) => Stream.value(const [
              RailItem(ownerType: 'book', ownerId: 'b1', title: 'Hero book'),
            ]),
          ),
          recentlyAddedBooksProvider('s1').overrideWith(
            (ref) => Stream.value(const [
              RailItem(ownerType: 'book', ownerId: 'b2', title: 'Plain book'),
            ]),
          ),
          recentlyAddedSeriesProvider('s1')
              .overrideWith((ref) => Stream.value(const <RailItem>[])),
          recentlyUpdatedSeriesProvider('s1')
              .overrideWith((ref) => Stream.value(const <RailItem>[])),
          // currentPage is 0-based; page 1 reads as "p. 2 of 10".
          bookReadStateProvider('s1', 'b1').overrideWith(
              (ref) => Stream<BookStateRow?>.value(_state(currentPage: 1))),
          cachedBookPagesCountProvider('s1', 'b1')
              .overrideWith((ref) async => 10),
          // Keep tiles on the placeholder path (no real cover fetch).
          coverImageProvider('s1', 'book', 'b1')
              .overrideWith((ref) async => null),
          coverImageProvider('s1', 'book', 'b2')
              .overrideWith((ref) async => null),
        ],
        child: MaterialApp(theme: lightTheme, home: const HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // The keep-reading tile carries the bar + caption at the hero width.
    expect(find.text('p. 2 of 10'), findsOneWidget);
    final heroTile = tester.getSize(
      find.widgetWithText(CoverTile, 'Hero book'),
    );
    expect(heroTile.width, kHeroRailTileWidth);

    // Other rails keep the standard tile width and no caption.
    final plainTile = tester.getSize(
      find.widgetWithText(CoverTile, 'Plain book'),
    );
    expect(plainTile.width, kRailTileWidth);

    // Dispose the tree so stream subscriptions are torn down before the
    // pending-timer invariant runs.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
}
