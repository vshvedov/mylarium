import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mylarium/app/theme/app_theme.dart';
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/data/source/source_providers.dart';
import 'package:mylarium/features/library/series_grid.dart';
import 'package:mylarium/features/library/series_grid_controller.dart';

import '../../support/test_scope.dart';

SeriesRow _series(int i) {
  final key = i.toString().padLeft(2, '0');
  return SeriesRow(
    sourceId: 's1',
    id: 'id$key',
    libraryId: 'lib1',
    title: 'Series $key',
    titleSort: 'series $key',
    booksCount: i + 1,
  );
}

Future<void> _pump(WidgetTester tester, ThemeData theme) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final scope = await TestScope.create();
  addTearDown(scope.db.close);

  final paging = PagingController<SeriesCursor, SeriesRow>(
    firstPageKey: const SeriesCursor.start(),
  );
  addTearDown(paging.dispose);
  paging.appendLastPage([for (var i = 0; i < 8; i++) _series(i)]);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...scope.overrides,
        // No server: every cover resolves to the placeholder (deterministic).
        contentApiForProvider('s1').overrideWith((ref) async => null),
      ],
      child: MaterialApp(
        theme: theme,
        home: Scaffold(
          body: SeriesGridBody(paging: paging, onTap: (_) {}),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('series grid renders in light theme', (tester) async {
    await _pump(tester, lightTheme);
    await expectLater(
      find.byType(SeriesGridBody),
      matchesGoldenFile('goldens/series_grid_light.png'),
    );
  });

  testWidgets('series grid renders in dark theme', (tester) async {
    await _pump(tester, darkTheme);
    await expectLater(
      find.byType(SeriesGridBody),
      matchesGoldenFile('goldens/series_grid_dark.png'),
    );
  });
}
