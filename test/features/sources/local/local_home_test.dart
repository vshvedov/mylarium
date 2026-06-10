import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/theme/app_theme.dart';
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/features/library/thumbnail_cache.dart';
import 'package:mylarium/features/sources/local/local_home.dart';
import 'package:mylarium/features/sources/local/local_providers.dart';

LocalComic comic(String id, String series, String title) => LocalComic(
      id: id,
      sourceId: 'l1',
      kind: 'localCopy',
      managedPath: 'media/local/l1/$id.archive',
      treeDocPath: null,
      series: series,
      seriesSort: series.toLowerCase(),
      number: '1',
      numberSort: 1,
      volume: null,
      title: title,
      ageRating: null,
      readingDirection: 'ltr',
      pageOrder: '["p1.jpg"]',
      pagesCount: 1,
      sizeBytes: 100,
      contentHash: 'h-$id',
      lastModified: null,
      importedAt: 0,
    );

void main() {
  testWidgets('empty library shows the import call to action', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        localKeepReadingProvider('l1')
            .overrideWith((ref) => Stream.value(const [])),
        localRecentlyImportedProvider('l1')
            .overrideWith((ref) => Stream.value(const [])),
      ],
      child: MaterialApp(
          theme: lightTheme,
          home: const Scaffold(body: LocalHomeBody(sourceId: 'l1'))),
    ));
    await tester.pumpAndSettle();

    expect(find.text('No comics yet'), findsOneWidget);
    expect(find.text('Import comics'), findsOneWidget);
  });

  testWidgets('rails render keep-reading and recently-imported', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        localKeepReadingProvider('l1').overrideWith(
            (ref) => Stream.value([comic('k1', 'Akira', 'Akira 1')])),
        localRecentlyImportedProvider('l1').overrideWith(
            (ref) => Stream.value([comic('r1', 'Berserk', 'Berserk 1')])),
        // Covers hang in a bare scope; stub them null (placeholder tile).
        coverImageProvider('l1', 'book', 'k1')
            .overrideWith((ref) async => null),
        coverImageProvider('l1', 'book', 'r1')
            .overrideWith((ref) async => null),
      ],
      child: MaterialApp(
          theme: lightTheme,
          home: const Scaffold(body: LocalHomeBody(sourceId: 'l1'))),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Keep reading'), findsOneWidget);
    expect(find.text('Recently imported'), findsOneWidget);
    expect(find.text('Akira 1'), findsOneWidget);
    expect(find.text('Berserk 1'), findsOneWidget);
  });
}
