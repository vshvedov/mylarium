import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mylarium/app/theme/app_icons.dart';
import 'package:mylarium/app/theme/app_theme.dart';
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/core/network/content_exception.dart';
import 'package:mylarium/data/komga/komga_api.dart';
import 'package:mylarium/data/repositories/series_repository.dart';
import 'package:mylarium/data/source/source_providers.dart';
import 'package:mylarium/features/integrations/comic_vine/comic_vine_providers.dart';
import 'package:mylarium/features/library/library_browse_controllers.dart';
import 'package:mylarium/features/library/pin_controllers.dart';
import 'package:mylarium/features/library/series_detail.dart';
import 'package:mylarium/features/library/series_grid.dart';
import 'package:mylarium/features/library/series_sync.dart';
import 'package:mylarium/features/offline/download_manager.dart';
import 'package:mylarium/features/offline/downloader.dart';
import 'package:mylarium/features/offline/offline_providers.dart';

import '../../support/test_scope.dart';

/// A repository whose network refresh always fails, so the background series
/// sync degrades to whatever the local cache holds (no real HTTP in the test).
class _OfflineSeriesRepository extends SeriesRepository {
  _OfflineSeriesRepository(super.db, super.api);

  @override
  Future<int> refresh(
    String sourceId, {
    int page = 0,
    int size = 50,
    String? sort = 'metadata.titleSort,asc',
    String? libraryId,
    Object? search,
  }) async =>
      throw const ContentException(ContentErrorKind.unreachable, 'offline');
}

/// Inert downloader: the book detail's download control constructs the
/// DownloadManager at build (ref.read), and the real adapter would hit the
/// background_downloader platform channel in a widget test.
class _StubDownloader implements Downloader {
  @override
  Stream<DownloadUpdate> get updates => const Stream.empty();

  @override
  Future<void> enqueue({
    required String taskId,
    required String url,
    required Map<String, String> headers,
    required String relativeDirectory,
    required String filename,
    required bool requiresWifi,
  }) async {}

  @override
  Future<void> cancel(String taskId) async {}

  @override
  Future<void> recoverPending() async {}
}

Future<TestScope> _seed() async {
  final scope = await TestScope.create();
  for (final (sort, id, title) in const [
    ('a', 'ida', 'Alpha'),
    ('b', 'idb', 'Bravo'),
    ('c', 'idc', 'Charlie'),
  ]) {
    await scope.db.upsertSeries(SeriesCompanion(
      sourceId: const Value('s1'),
      id: Value(id),
      libraryId: const Value('lib1'),
      title: Value(title),
      titleSort: Value(sort),
    ));
  }
  // Alpha's one book, seeded for real: the book detail screen resolves its row
  // straight from the db (a private provider the test cannot override).
  await scope.db.upsertBook(const BooksCompanion(
    sourceId: Value('s1'),
    id: Value('b1'),
    seriesId: Value('ida'),
    libraryId: Value('lib1'),
    title: Value('Book One'),
    number: Value('1'),
    pagesCount: Value(20),
  ));
  return scope;
}

Future<GoRouter> _pumpBrowse(
  WidgetTester tester,
  TestScope scope, {
  required Size size,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  addTearDown(scope.db.close);

  final book = Book(
    sourceId: 's1',
    id: 'b1',
    seriesId: 'ida',
    libraryId: 'lib1',
    title: 'Book One',
    number: '1',
    numberSort: 1,
    pagesCount: 20,
    mediaType: null,
    sizeBytes: null,
    readPage: null,
    completed: false,
  );

  final router = GoRouter(
    initialLocation: '/browse/s1',
    routes: [
      GoRoute(
        path: '/browse/:sourceId',
        builder: (_, state) =>
            BrowseShell(sourceId: state.pathParameters['sourceId']!),
      ),
      // The real series detail, so the phone flow exercises the same book-tile
      // tap that the embedded pane does.
      GoRoute(
        path: '/series/:sourceId/:seriesId',
        builder: (_, state) => SeriesDetailScreen(
          sourceId: state.pathParameters['sourceId']!,
          seriesId: state.pathParameters['seriesId']!,
        ),
      ),
      GoRoute(
        path: '/book/:sourceId/:bookId',
        builder: (_, state) => Scaffold(
          body: Center(
            child: Text('BOOK_ROUTE_${state.pathParameters['bookId']}'),
          ),
        ),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...scope.overrides,
        seriesRepositoryProvider.overrideWith(
          (ref) async => _OfflineSeriesRepository(scope.db, KomgaApi(Dio())),
        ),
        // No server: covers resolve to the deterministic placeholder.
        contentApiForProvider('s1').overrideWith((ref) async => null),
        // Comic Vine off (avoids hitting secure storage, which never resolves
        // in a widget test and would leave the panel spinning forever).
        comicVineApiKeyProvider.overrideWith((ref) async => null),
        // Stub the grid's data with a plain (non-Drift) stream + a resolved
        // sync, so no live Drift query stream is opened (see the "stub live
        // Drift streams" rule in browse_shell_navigation_test).
        browseSeriesProvider('s1', null, false).overrideWith(
          (ref) => Stream.value([
            SeriesRow(
                sourceId: 's1',
                id: 'ida',
                libraryId: 'lib1',
                title: 'Alpha',
                titleSort: 'a',
                booksCount: 1),
            SeriesRow(
                sourceId: 's1',
                id: 'idb',
                libraryId: 'lib1',
                title: 'Bravo',
                titleSort: 'b',
                booksCount: 0),
            SeriesRow(
                sourceId: 's1',
                id: 'idc',
                libraryId: 'lib1',
                title: 'Charlie',
                titleSort: 'c',
                booksCount: 0),
          ]),
        ),
        seriesSyncCompleteProvider('s1', null).overrideWith((ref) async => true),
        // Series detail providers, stubbed so the screen opens no live Drift
        // stream / network fetch that would outlive the test.
        seriesDetailProvider('s1', 'ida').overrideWith(
          (ref) async => await scope.db.getSeries('s1', 'ida'),
        ),
        seriesBooksProvider('s1', 'ida')
            .overrideWith((ref) => Stream.value([book])),
        seriesReadStatesProvider('s1', 'ida')
            .overrideWith((ref) => Stream.value(const <BookStateRow>[])),
        seriesDetailDtoProvider('s1', 'ida').overrideWith((ref) async => null),
        seriesRatingProvider('s1', 'ida').overrideWith((ref) async => null),
        seriesDownloadStatusProvider('s1', 'ida').overrideWith(
          (ref) => Stream.value((total: 1, downloaded: 0, active: 0)),
        ),
        isPinnedProvider('s1', 'series', 'ida')
            .overrideWith((ref) => Stream.value(false)),
        // Book detail providers (the new in-pane level), same stubbing rules.
        bookReadStateProvider('s1', 'b1')
            .overrideWith((ref) => Stream.value(null)),
        bookDetailDtoProvider('s1', 'b1').overrideWith((ref) async => null),
        bookRatingProvider('s1', 'b1').overrideWith((ref) async => null),
        cachedAssetProvider('s1', 'b1')
            .overrideWith((ref) => Stream.value(null)),
        downloadProgressProvider('s1', 'b1').overrideWith(
          (ref) => Stream.value(
              const DownloadProgress(state: 'none', bytesDownloaded: 0)),
        ),
        downloaderProvider.overrideWith((ref) => _StubDownloader()),
      ],
      child: MaterialApp.router(
        theme: lightTheme,
        routerConfig: router,
        // Disable animations below MaterialApp so the transient branded loader
        // (a repeating Lottie) renders static and pumpAndSettle can settle.
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

void main() {
  testWidgets(
    'tablet width: a book tap swaps the pane to the book detail and the '
    'in-pane back returns to the series detail (no route push)',
    (tester) async {
      final scope = await _seed();
      final router =
          await _pumpBrowse(tester, scope, size: const Size(1200, 900));

      // Select Alpha into the detail pane.
      expect(find.text('Select a series'), findsOneWidget);
      await tester.tap(find.text('Alpha'));
      await tester.pumpAndSettle();
      expect(find.text('Mark series read'), findsOneWidget);

      // Tap its book tile, scrolling the detail pane's OWN scroll view (the
      // scrollable inside SeriesDetailScreen; `.last` of all Scrollables is
      // not guaranteed to be the pane).
      await tester.scrollUntilVisible(
        find.text('Book One'),
        200,
        scrollable: find
            .descendant(
              of: find.byType(SeriesDetailScreen),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Book One'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Book One'));
      await tester.pumpAndSettle();

      // The book detail rendered IN the pane: no route push (the master grid
      // is still on screen and the URI never changed)...
      expect(find.text('BOOK_ROUTE_b1'), findsNothing);
      expect(
        router.routerDelegate.currentConfiguration.uri.toString(),
        '/browse/s1',
      );
      expect(find.text('Bravo'), findsOneWidget); // master grid still present
      // ...and it replaced the series detail.
      expect(find.text('Read'), findsOneWidget);
      expect(find.text('Mark read'), findsOneWidget);
      expect(find.text('Mark series read'), findsNothing);

      // The in-pane back affordance returns the pane to the series detail.
      await tester.tap(find.byIcon(AppIcons.back));
      await tester.pumpAndSettle();
      expect(find.text('Mark series read'), findsOneWidget);
      expect(find.text('Mark read'), findsNothing);
      expect(
        router.routerDelegate.currentConfiguration.uri.toString(),
        '/browse/s1',
      );
    },
  );

  testWidgets(
    'phone width: a book tap from the pushed series detail still pushes the '
    'book route',
    (tester) async {
      final scope = await _seed();
      await _pumpBrowse(tester, scope, size: const Size(390, 844));

      // Phone width: the series tap pushes the (real) series detail route,
      // full screen (the master grid is covered).
      await tester.tap(find.text('Alpha'));
      await tester.pumpAndSettle();
      expect(find.text('Mark series read'), findsOneWidget);
      expect(find.text('Bravo'), findsNothing);

      // And a book tap from there pushes the book detail route, as before.
      await tester.scrollUntilVisible(
        find.text('Book One'),
        200,
        scrollable: find
            .descendant(
              of: find.byType(SeriesDetailScreen),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.ensureVisible(find.text('Book One'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Book One'));
      await tester.pumpAndSettle();
      expect(find.text('BOOK_ROUTE_b1'), findsOneWidget);
    },
  );
}
