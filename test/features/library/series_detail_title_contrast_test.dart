import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/theme/app_theme.dart';
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/data/source/source_providers.dart';
import 'package:mylarium/features/library/library_browse_controllers.dart';
import 'package:mylarium/features/library/series_detail.dart';

import '../../support/test_scope.dart';

void main() {
  test('hero title ink contrasts the band', () {
    // Dark band -> light text; light band -> dark ink.
    expect(heroTitleColorFor(const Color(0xFF1A1820)), Colors.white);
    expect(heroTitleColorFor(const Color(0xFFEDEDED)), isNot(Colors.white));
  });

  testWidgets('hero title uses a light ink on the dark hero (not onSurface)', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final scope = await TestScope.create();
    addTearDown(scope.db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...scope.overrides,
          // No server -> no cover -> palette null -> the dark hero fallback.
          komgaApiForProvider('s1').overrideWith((ref) async => null),
          seriesDetailProvider('s1', 'se1').overrideWith(
            (ref) async => SeriesRow(
              sourceId: 's1',
              id: 'se1',
              libraryId: 'lib1',
              title: 'Test Series',
              titleSort: 'test series',
              booksCount: 0,
            ),
          ),
          seriesBooksProvider(
            's1',
            'se1',
          ).overrideWith((ref) => Stream.value(const <Book>[])),
        ],
        child: MaterialApp(
          theme: lightTheme,
          home: const SeriesDetailScreen(sourceId: 's1', seriesId: 'se1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // The pinned hero title (inside the FlexibleSpaceBar), not the body header.
    final title = tester.widget<Text>(
      find.descendant(
        of: find.byType(FlexibleSpaceBar),
        matching: find.text('Test Series'),
      ),
    );
    expect(title.style?.color, Colors.white);
  });
}
