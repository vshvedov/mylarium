import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/theme/app_theme.dart';
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/features/library/library_browse_controllers.dart';
import 'package:mylarium/features/library/thumbnail_cache.dart';
import 'package:mylarium/features/library/widgets/skeleton.dart';
import 'package:mylarium/features/sources/local/local_home.dart';
import 'package:mylarium/features/sources/local/local_providers.dart';

LocalComic comic(String id, String series, String title,
        {int pagesCount = 1}) =>
    LocalComic(
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
      pagesCount: pagesCount,
      sizeBytes: 100,
      contentHash: 'h-$id',
      lastModified: null,
      importedAt: 0,
    );

BookStateRow readState(String bookId, {required int currentPage}) =>
    BookStateRow(
      sourceId: 'l1',
      bookId: bookId,
      status: 'inProgress',
      currentPage: currentPage,
      timesReread: 0,
      isRereading: false,
      visibility: 'private',
      shareToFeed: false,
      updatedAt: 0,
    );

/// A stream that never emits, keeping its provider in the loading state.
Stream<List<LocalComic>> _pending() =>
    StreamController<List<LocalComic>>().stream;

/// Forces reduce-motion ON below MaterialApp's own MediaQuery so SkeletonTile
/// runs no perpetual ticker (the loading test holds skeletons forever via
/// never-emitting streams; the ticker would never let the test end).
MaterialApp _app(Widget home) => MaterialApp(
      theme: lightTheme,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: true),
        child: child!,
      ),
      home: home,
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

  testWidgets('loading shows skeleton rails, never the empty call to action',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        localKeepReadingProvider('l1').overrideWith((ref) => _pending()),
        localRecentlyImportedProvider('l1').overrideWith((ref) => _pending()),
      ],
      child: _app(const Scaffold(body: LocalHomeBody(sourceId: 'l1'))),
    ));
    await tester.pump(); // one frame; do not settle (streams never close)

    expect(find.byType(SkeletonRail), findsNWidgets(2));
    expect(find.text('No comics yet'), findsNothing);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });

  testWidgets('rails render keep-reading and recently-imported', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        localKeepReadingProvider('l1').overrideWith(
            (ref) => Stream.value([comic('k1', 'Akira', 'Akira 1')])),
        localRecentlyImportedProvider('l1').overrideWith(
            (ref) => Stream.value([comic('r1', 'Berserk', 'Berserk 1')])),
        // No read state yet: the hero footer must render nothing.
        bookReadStateProvider('l1', 'k1')
            .overrideWith((ref) => Stream<BookStateRow?>.value(null)),
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
    // No progress recorded, so no caption renders anywhere.
    expect(find.textContaining('p. '), findsNothing);
  });

  testWidgets('keep-reading tiles show the page-progress bar and caption',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        localKeepReadingProvider('l1').overrideWith((ref) =>
            Stream.value([comic('k1', 'Akira', 'Akira 1', pagesCount: 10)])),
        localRecentlyImportedProvider('l1').overrideWith((ref) =>
            Stream.value([comic('r1', 'Berserk', 'Berserk 1', pagesCount: 10)])),
        // currentPage is 0-based; page 1 reads as "p. 2 of 10".
        bookReadStateProvider('l1', 'k1').overrideWith((ref) =>
            Stream<BookStateRow?>.value(readState('k1', currentPage: 1))),
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

    // Only the keep-reading (hero) tile carries the caption; the
    // recently-imported rail never does.
    expect(find.text('p. 2 of 10'), findsOneWidget);
  });
}
