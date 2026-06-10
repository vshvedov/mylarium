import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/theme/app_theme.dart';
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/features/library/thumbnail_cache.dart';
import 'package:mylarium/features/sources/local/local_browse.dart';
import 'package:mylarium/features/sources/local/local_providers.dart';

LocalComic _comic(String id, String series, String readingDirection) =>
    LocalComic(
      id: id,
      sourceId: 'l1',
      kind: 'localCopy',
      managedPath: 'media/local/l1/$id.cbz',
      series: series,
      seriesSort: series.toLowerCase(),
      number: '1',
      title: '$series 1',
      readingDirection: readingDirection,
      pageOrder: '["p1.jpg"]',
      pagesCount: 1,
      importedAt: 0,
    );

void main() {
  testWidgets('series grid renders groups with counts', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        localSeriesProvider('l1').overrideWith((ref) => Stream.value(const [
              (
                series: 'Akira',
                seriesSort: 'akira',
                booksCount: 1,
                coverComicId: 'a1',
              ),
              (
                series: 'Berserk',
                seriesSort: 'berserk',
                booksCount: 3,
                coverComicId: 'b1',
              ),
            ])),
        coverImageProvider('l1', 'book', 'a1')
            .overrideWith((ref) async => null),
        coverImageProvider('l1', 'book', 'b1')
            .overrideWith((ref) async => null),
      ],
      child: MaterialApp(
        theme: lightTheme,
        home: const LocalBrowseShell(sourceId: 'l1'),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Akira'), findsOneWidget);
    expect(find.text('Berserk'), findsOneWidget);
    expect(find.text('1 book'), findsOneWidget);
    expect(find.text('3 books'), findsOneWidget);
  });

  testWidgets('RTL badge appears on rtl books only', (tester) async {
    const sourceId = 'l1';
    const series = 'Akira';
    final rtlComic = _comic('a1', series, 'rtl');
    final ltrComic = _comic('a2', series, 'ltr');

    await tester.pumpWidget(ProviderScope(
      overrides: [
        localBooksProvider(sourceId, series)
            .overrideWith((ref) => Stream.value([rtlComic, ltrComic])),
        coverImageProvider(sourceId, 'book', 'a1')
            .overrideWith((ref) async => null),
        coverImageProvider(sourceId, 'book', 'a2')
            .overrideWith((ref) async => null),
      ],
      child: MaterialApp(
        theme: lightTheme,
        home: LocalSeriesDetailScreen(
          sourceId: sourceId,
          series: series,
          embedded: false,
        ),
      ),
    ));
    await tester.pumpAndSettle();

    // One RTL badge for the rtl comic, none for the ltr comic.
    expect(find.text('RTL'), findsOneWidget);
  });
}
