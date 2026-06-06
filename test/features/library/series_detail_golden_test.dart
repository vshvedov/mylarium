import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/theme/app_theme.dart';
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/data/source/source_providers.dart';
import 'package:mylarium/features/integrations/comic_vine/comic_vine_providers.dart';
import 'package:mylarium/features/library/library_browse_controllers.dart';
import 'package:mylarium/features/library/pin_controllers.dart';
import 'package:mylarium/features/library/series_detail.dart';
import 'package:mylarium/features/offline/offline_providers.dart';

import '../../support/test_scope.dart';

SeriesRow _seriesRow() => SeriesRow(
  sourceId: 's1',
  id: 'se1',
  libraryId: 'lib1',
  title: 'Test Series',
  titleSort: 'test series',
  status: 'ONGOING',
  summary: 'A short test summary for the series detail header.',
  booksCount: 4,
);

Book _book(int i) => Book(
  sourceId: 's1',
  id: 'bk$i',
  seriesId: 'se1',
  libraryId: 'lib1',
  title: 'Book $i',
  number: '$i',
  pagesCount: 20,
  completed: false,
);

/// Overrides the detail data providers directly (instead of seeding the DB and
/// relying on the repo chain) so the screen renders deterministically without a
/// server; covers fall back to the placeholder / hero gradient.
Future<void> _pump(WidgetTester tester, ThemeData theme) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final scope = await TestScope.create();
  addTearDown(scope.db.close);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...scope.overrides,
        komgaApiForProvider('s1').overrideWith((ref) async => null),
        comicVineApiKeyProvider.overrideWith((ref) async => null),
        seriesDetailProvider(
          's1',
          'se1',
        ).overrideWith((ref) async => _seriesRow()),
        seriesBooksProvider('s1', 'se1').overrideWith(
          (ref) => Stream.value([for (var i = 0; i < 4; i++) _book(i)]),
        ),
        // T3 detail providers: deterministic empty/offline so the golden is
        // stable (no live db stream, no network metadata).
        seriesReadStatesProvider('s1', 'se1')
            .overrideWith((ref) => Stream.value(const <BookStateRow>[])),
        seriesDetailDtoProvider('s1', 'se1').overrideWith((ref) async => null),
        seriesRatingProvider('s1', 'se1').overrideWith((ref) async => null),
        // Offline providers: stub the live db streams so the golden is stable.
        seriesDownloadStatusProvider('s1', 'se1').overrideWith(
          (ref) => Stream.value((total: 0, downloaded: 0)),
        ),
        // The hero pin toggle opens a live db stream; stub it so the golden is
        // stable and no timer outlives the test.
        isPinnedProvider('s1', 'series', 'se1')
            .overrideWith((ref) => Stream.value(false)),
        for (var i = 0; i < 4; i++)
          cachedAssetProvider('s1', 'bk$i')
              .overrideWith((ref) => Stream.value(null)),
      ],
      child: MaterialApp(
        theme: theme,
        home: const SeriesDetailScreen(sourceId: 's1', seriesId: 'se1'),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('series detail renders in light theme', (tester) async {
    await _pump(tester, lightTheme);
    await expectLater(
      find.byType(SeriesDetailScreen),
      matchesGoldenFile('goldens/series_detail_light.png'),
    );
  });

  testWidgets('series detail renders in dark theme', (tester) async {
    await _pump(tester, darkTheme);
    await expectLater(
      find.byType(SeriesDetailScreen),
      matchesGoldenFile('goldens/series_detail_dark.png'),
    );
  });
}
