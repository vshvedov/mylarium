import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/theme/app_theme.dart';
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/features/home/home_screen.dart';
import 'package:mylarium/features/library/library_browse_controllers.dart';
import 'package:mylarium/features/library/rail_item.dart';
import 'package:mylarium/features/library/widgets/rail_skeleton.dart';

import '../../support/test_scope.dart';

/// A stream that never emits, keeping its provider in the loading state.
Stream<List<RailItem>> _pending() => StreamController<List<RailItem>>().stream;

/// A MaterialApp that forces reduce-motion ON *below* its own MediaQuery (a
/// MediaQuery wrapped above MaterialApp would be overridden by the one
/// MaterialApp inserts from the test window). This keeps SkeletonBox static so
/// its repeating ticker schedules no frames (test 1 holds skeletons forever via
/// never-emitting streams; without this the ticker would never let the test end),
/// and skips the home's per-rail AnimatedSize so a rail collapsing to empty in
/// test 2 settles cleanly.
MaterialApp _app(Widget home) => MaterialApp(
      theme: lightTheme,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: true),
        child: child!,
      ),
      home: home,
    );

void main() {
  testWidgets('rails that are still loading show skeletons, no empty-state',
      (tester) async {
    tester.view.physicalSize = const Size(430, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final scope = await TestScope.create();
    addTearDown(scope.db.close);
    await scope.db.upsertSource(const SourcesCompanion(
      id: Value('s1'), kind: Value('komga'), label: Value('T')));

    await tester.pumpWidget(ProviderScope(
      overrides: [
        ...scope.overrides,
        keepReadingProvider('s1').overrideWith((ref) => _pending()),
        recentlyAddedBooksProvider('s1').overrideWith((ref) => _pending()),
        recentlyAddedSeriesProvider('s1').overrideWith((ref) => _pending()),
        recentlyUpdatedSeriesProvider('s1').overrideWith((ref) => _pending()),
      ],
      child: _app(const HomeScreen()),
    ));
    await tester.pump(); // one frame; do not settle (streams never close)

    expect(find.byType(RailSkeleton), findsWidgets);
    expect(find.text('Nothing to show yet. Pull to refresh.'), findsNothing);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });

  testWidgets('all rails resolved empty shows the empty-state, no skeletons',
      (tester) async {
    tester.view.physicalSize = const Size(430, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final scope = await TestScope.create();
    addTearDown(scope.db.close);
    await scope.db.upsertSource(const SourcesCompanion(
      id: Value('s1'), kind: Value('komga'), label: Value('T')));

    await tester.pumpWidget(ProviderScope(
      overrides: [
        ...scope.overrides,
        keepReadingProvider('s1')
            .overrideWith((ref) => Stream.value(const <RailItem>[])),
        recentlyAddedBooksProvider('s1')
            .overrideWith((ref) => Stream.value(const <RailItem>[])),
        recentlyAddedSeriesProvider('s1')
            .overrideWith((ref) => Stream.value(const <RailItem>[])),
        recentlyUpdatedSeriesProvider('s1')
            .overrideWith((ref) => Stream.value(const <RailItem>[])),
      ],
      child: _app(const HomeScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(RailSkeleton), findsNothing);
    expect(find.text('Nothing to show yet. Pull to refresh.'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
}
