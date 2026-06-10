import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/theme/app_theme.dart';
import 'package:mylarium/core/db/database.dart';
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

  testWidgets('shows the local facts', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        localComicProvider('c1').overrideWith((ref) async => comic),
        coverImageProvider('l1', 'book', 'c1')
            .overrideWith((ref) async => null),
      ],
      child: MaterialApp(
        theme: lightTheme,
        home: const LocalBookDetailScreen(sourceId: 'l1', comicId: 'c1'),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('The Fall'), findsOneWidget);
    expect(find.text('Berserk'), findsOneWidget);
    expect(find.text('5.0 MB'), findsOneWidget);
    expect(find.text('Right to left'), findsOneWidget);
    expect(find.text('2026-06-09'), findsOneWidget);
    expect(find.text('Remove from library'), findsOneWidget);
    // No Read action until T3 wires the local page source.
    expect(find.text('Read'), findsNothing);
  });

  testWidgets('remove asks for confirmation', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        localComicProvider('c1').overrideWith((ref) async => comic),
        coverImageProvider('l1', 'book', 'c1')
            .overrideWith((ref) async => null),
      ],
      child: MaterialApp(
        theme: lightTheme,
        home: const LocalBookDetailScreen(sourceId: 'l1', comicId: 'c1'),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Remove from library'));
    await tester.pumpAndSettle();
    expect(find.text('Remove this comic?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Remove this comic?'), findsNothing);
  });
}
