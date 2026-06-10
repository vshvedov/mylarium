import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/theme/app_theme.dart';
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/features/library/library_browse_controllers.dart'
    show bookReadStateProvider;
import 'package:mylarium/features/library/thumbnail_cache.dart';
import 'package:mylarium/features/sources/local/local_book_detail.dart';
import 'package:mylarium/features/sources/local/local_providers.dart';

void main() {
  final comic = LocalComic(
    id: 'c1',
    sourceId: 'l1',
    kind: 'localCopy',
    managedPath: 'media/local/l1/c1.archive',
    treeDocPath: null,
    series: 'Berserk',
    seriesSort: 'berserk',
    number: '3',
    numberSort: 3,
    volume: null,
    title: 'The Fall',
    ageRating: 17,
    readingDirection: 'rtl',
    pageOrder: '["p1.jpg","p2.jpg"]',
    pagesCount: 2,
    sizeBytes: 5 * 1024 * 1024,
    contentHash: 'h',
    lastModified: null,
    importedAt: DateTime(2026, 6, 9).millisecondsSinceEpoch,
  );

  Future<void> pump(WidgetTester tester, {LocalComic? override}) async {
    final c = override ?? comic;
    await tester.pumpWidget(ProviderScope(
      overrides: [
        localComicProvider('c1').overrideWith((ref) async => c),
        coverImageProvider('l1', 'book', 'c1')
            .overrideWith((ref) async => null),
        bookReadStateProvider('l1', 'c1')
            .overrideWith((ref) => Stream.value(null)),
      ],
      child: MaterialApp(
        theme: lightTheme,
        home: const LocalBookDetailScreen(sourceId: 'l1', comicId: 'c1'),
      ),
    ));
    await tester.pumpAndSettle();
  }

  Future<void> scrollTo(WidgetTester tester, Finder finder) =>
      tester.scrollUntilVisible(finder, 80,
          scrollable: find.byType(Scrollable));

  testWidgets('shows the local facts and the T3 Read action', (tester) async {
    await pump(tester);

    expect(find.text('The Fall'), findsOneWidget);
    expect(find.text('Berserk'), findsOneWidget);
    expect(find.text('5.0 MB'), findsOneWidget);
    expect(find.text('Right to left'), findsOneWidget);
    expect(find.text('2026-06-09'), findsOneWidget);
    await scrollTo(tester, find.text('Read'));
    expect(find.text('Read'), findsOneWidget);
    await scrollTo(tester, find.text('Remove from library'));
    expect(find.text('Remove from library'), findsOneWidget);
  });

  testWidgets('remove asks for confirmation', (tester) async {
    await pump(tester);

    await scrollTo(tester, find.text('Remove from library'));
    await tester.tap(find.text('Remove from library'));
    await tester.pumpAndSettle();
    expect(find.text('Remove this comic?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Remove this comic?'), findsNothing);
  });

  testWidgets('a tree (in-place) book hides remove: rescan manages it',
      (tester) async {
    final treeComic = LocalComic(
      id: 'c1',
      sourceId: 'l1',
      kind: 'safTree',
      managedPath: null,
      treeDocPath: 'content://tree/doc',
      series: comic.series,
      seriesSort: comic.seriesSort,
      number: comic.number,
      numberSort: comic.numberSort,
      volume: null,
      title: comic.title,
      ageRating: comic.ageRating,
      readingDirection: comic.readingDirection,
      pageOrder: comic.pageOrder,
      pagesCount: comic.pagesCount,
      sizeBytes: comic.sizeBytes,
      contentHash: null,
      lastModified: 123,
      importedAt: comic.importedAt,
    );
    await pump(tester, override: treeComic);

    await scrollTo(tester, find.text('Read'));
    expect(find.text('Read'), findsOneWidget);
    expect(find.text('Remove from library'), findsNothing);
  });
}
