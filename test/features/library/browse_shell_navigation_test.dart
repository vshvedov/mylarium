import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mylarium/app/theme/app_theme.dart';
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/core/network/komga_exception.dart';
import 'package:mylarium/data/komga/komga_api.dart';
import 'package:mylarium/data/repositories/series_repository.dart';
import 'package:mylarium/data/source/source_providers.dart';
import 'package:mylarium/features/integrations/comic_vine/comic_vine_providers.dart';
import 'package:mylarium/features/library/library_browse_controllers.dart';
import 'package:mylarium/features/library/series_grid.dart';

import '../../support/test_scope.dart';

/// A repository whose network refresh always fails, so [SeriesGridController]
/// degrades to whatever the local cache holds (no real HTTP in the test).
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
      throw const KomgaException(KomgaErrorKind.unreachable, 'offline');
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
  return scope;
}

Future<GoRouter> _pumpBrowse(
  WidgetTester tester,
  TestScope scope, {
  required Size size,
  List<Override> extra = const [],
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  addTearDown(scope.db.close);

  final router = GoRouter(
    initialLocation: '/browse/s1',
    routes: [
      GoRoute(
        path: '/browse/:sourceId',
        builder: (_, state) =>
            BrowseShell(sourceId: state.pathParameters['sourceId']!),
      ),
      GoRoute(
        path: '/series/:sourceId/:seriesId',
        builder: (_, state) => Scaffold(
          body: Center(
            child: Text('SERIES_ROUTE_${state.pathParameters['seriesId']}'),
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
        komgaApiForProvider('s1').overrideWith((ref) async => null),
        // Comic Vine off (avoids hitting secure storage, which never resolves
        // in a widget test and would leave the panel spinning forever).
        comicVineApiKeyProvider.overrideWith((ref) async => null),
        ...extra,
      ],
      child: MaterialApp.router(theme: lightTheme, routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

void main() {
  testWidgets(
    'phone width: tapping a series pushes the detail route',
    (tester) async {
      final scope = await _seed();
      await _pumpBrowse(tester, scope, size: const Size(390, 844));

      // The two-pane detail is collapsed at this width, so the tap must push
      // the detail route (which renders the marker below).
      expect(find.text('Alpha'), findsOneWidget);
      await tester.tap(find.text('Alpha'));
      await tester.pumpAndSettle();

      expect(find.text('SERIES_ROUTE_ida'), findsOneWidget);
    },
  );

  testWidgets(
    'tablet width: tapping a series fills the detail pane in place',
    (tester) async {
      final scope = await _seed();
      final router = await _pumpBrowse(
        tester,
        scope,
        size: const Size(1200, 900),
        extra: [
          // Keep the embedded detail screen deterministic (no network/db cover
          // resolution that would hang a bare scope).
          seriesDetailProvider('s1', 'ida').overrideWith(
            (ref) async => await scope.db.getSeries('s1', 'ida'),
          ),
          seriesBooksProvider('s1', 'ida')
              .overrideWith((ref) => Stream.value(const <Book>[])),
        ],
      );

      expect(find.text('Select a series'), findsOneWidget);
      await tester.tap(find.text('Alpha'));
      await tester.pumpAndSettle();

      // Stayed on the browse route; selection rendered in the detail pane.
      expect(find.text('SERIES_ROUTE_ida'), findsNothing);
      expect(find.text('Select a series'), findsNothing);
      expect(
        router.routerDelegate.currentConfiguration.uri.toString(),
        '/browse/s1',
      );
    },
  );
}
