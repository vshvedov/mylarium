import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/theme/app_theme.dart';
import 'package:mylarium/app/widgets/app_loading.dart';
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/data/source/source_providers.dart';
import 'package:mylarium/features/library/series_grid.dart';
import 'package:mylarium/features/library/series_sync.dart';
import 'package:mylarium/features/library/thumbnail_cache.dart';

import '../../support/test_scope.dart';

/// Seeds three series (Alpha/Bravo/Charlie) into the cache for source 's1'.
Future<void> _seed(AppDatabase db) async {
  for (final (sort, id, title) in const [
    ('alpha', 'ida', 'Alpha'),
    ('bravo', 'idb', 'Bravo'),
    ('charlie', 'idc', 'Charlie'),
  ]) {
    await db.upsertSeries(SeriesCompanion(
      sourceId: const Value('s1'),
      id: Value(id),
      libraryId: const Value('lib1'),
      title: Value(title),
      titleSort: Value(sort),
      booksCount: const Value(2),
    ));
  }
}

Future<TestScope> _pump(WidgetTester tester, {Size? size}) async {
  if (size != null) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }
  final scope = await TestScope.create();
  addTearDown(scope.db.close);
  await _seed(scope.db);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...scope.overrides,
        // No background sync (and no network): the seeded cache is the data.
        seriesSyncProvider('s1', null).overrideWith((ref) async => null),
        // Covers resolve to the deterministic placeholder.
        for (final id in const ['ida', 'idb', 'idc'])
          coverImageProvider('s1', 'series', id)
              .overrideWith((ref) async => null),
      ],
      child: MaterialApp(
        theme: lightTheme,
        home: const SeriesGridScreen(sourceId: 's1'),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return scope;
}

void main() {
  testWidgets('renders a tile for every cached series', (tester) async {
    await _pump(tester, size: const Size(900, 1400));

    expect(find.text('Alpha'), findsOneWidget);
    expect(find.text('Bravo'), findsOneWidget);
    expect(find.text('Charlie'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });

  testWidgets('Title Z-A sort reverses the order', (tester) async {
    // A narrow viewport forces a single column, so vertical position == order.
    await _pump(tester, size: const Size(190, 1600));

    // Ascending by default: Alpha sits above Charlie.
    expect(tester.getTopLeft(find.text('Alpha')).dy,
        lessThan(tester.getTopLeft(find.text('Charlie')).dy));

    // Open the sort menu and pick Title Z-A.
    await tester.tap(find.byType(SortButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Title Z-A'));
    await tester.pumpAndSettle();

    // Descending now: Charlie sits above Alpha.
    expect(tester.getTopLeft(find.text('Charlie')).dy,
        lessThan(tester.getTopLeft(find.text('Alpha')).dy));

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });

  testWidgets('long-pressing a series opens the Pin sheet', (tester) async {
    await _pump(tester, size: const Size(900, 1400));

    await tester.longPress(find.text('Alpha'));
    await tester.pumpAndSettle();

    // The context menu (same as the home rails) offers Pin.
    expect(find.text('Pin'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });

  testWidgets('empty library shows the empty message once the sync completes',
      (tester) async {
    final scope = await TestScope.create();
    addTearDown(scope.db.close);
    // No series seeded; the sync is complete (nothing to fetch).
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...scope.overrides,
          seriesSyncProvider('s1', null).overrideWith((ref) async => null),
        ],
        child: MaterialApp(
          theme: lightTheme,
          home: const SeriesGridScreen(sourceId: 's1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No series here yet.'), findsOneWidget);
    expect(find.byType(AppLoadingIndicator), findsNothing);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });

  testWidgets('A-Z scrubber jumps the grid to the tapped letter',
      (tester) async {
    tester.view.physicalSize = const Size(400, 700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final scope = await TestScope.create();
    addTearDown(scope.db.close);
    final controller = ScrollController();
    addTearDown(controller.dispose);

    // One series per letter A..Z, sorted, enough to scroll past one screen.
    final items = [
      for (var i = 0; i < 26; i++)
        SeriesRow(
          sourceId: 's1',
          id: 'id$i',
          libraryId: 'lib1',
          title: '${String.fromCharCode(65 + i)} Series',
          titleSort: String.fromCharCode(97 + i),
          booksCount: 1,
        ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...scope.overrides,
          // No server: covers resolve to the deterministic placeholder.
          contentApiForProvider('s1').overrideWith((ref) async => null),
        ],
        child: MaterialApp(
          theme: lightTheme,
          home: Scaffold(
            body: SeriesGridBody(
              items: items,
              syncComplete: true,
              onTap: (_) {},
              controller: controller,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(controller.offset, 0);

    // Tap the scrubber's 'Z' (exact-text match hits the rail letter, not a
    // series title) -> the grid jumps down to the Z row.
    await tester.tap(find.text('Z'));
    await tester.pumpAndSettle();

    expect(controller.offset, greaterThan(0),
        reason: 'tapping Z should scroll toward the end of the list');

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
}
