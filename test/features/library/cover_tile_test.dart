import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/theme/app_theme.dart';
import 'package:mylarium/features/library/library_browse_controllers.dart';
import 'package:mylarium/features/library/thumbnail_cache.dart';
import 'package:mylarium/features/library/widgets/library_tiles.dart';

import '../../support/test_scope.dart';

void main() {
  testWidgets('cover tile carries an elevation shadow and forwards taps', (
    tester,
  ) async {
    final scope = await TestScope.create();
    addTearDown(scope.db.close);

    var tapped = false;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...scope.overrides,
          // Resolve the cover to the placeholder so the tile does not exercise
          // the real Komga/secure-storage fetch path in a unit test.
          coverImageProvider(
            's',
            'series',
            'x',
          ).overrideWith((ref) async => null),
        ],
        child: MaterialApp(
          theme: darkTheme,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 120,
                height: 200,
                child: CoverTile(
                  sourceId: 's',
                  ownerType: 'series',
                  ownerId: 'x',
                  title: 'Title',
                  onTap: () => tapped = true,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final container = tester.widget<Container>(
      find.byKey(const ValueKey('coverShadow')),
    );
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.boxShadow, isNotEmpty);

    await tester.tap(find.byType(CoverTile));
    await tester.pumpAndSettle();
    expect(tapped, isTrue);
  });

  testWidgets('a flat tile has no deck; a stacked tile shows two deck cards', (
    tester,
  ) async {
    final scope = await TestScope.create();
    addTearDown(scope.db.close);

    Widget tile({required bool stacked}) => ProviderScope(
          overrides: [
            ...scope.overrides,
            coverImageProvider('s', 'series', 'x')
                .overrideWith((ref) async => null),
          ],
          child: MaterialApp(
            theme: darkTheme,
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 120,
                  height: 200,
                  child: CoverTile(
                    sourceId: 's',
                    ownerType: 'series',
                    ownerId: 'x',
                    title: 'Title',
                    stacked: stacked,
                  ),
                ),
              ),
            ),
          ),
        );

    await tester.pumpWidget(tile(stacked: false));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('coverDeck')), findsNothing);
    expect(find.byKey(const ValueKey('deckCard')), findsNothing);

    await tester.pumpWidget(tile(stacked: true));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('coverDeck')), findsOneWidget);
    expect(find.byKey(const ValueKey('deckCard')), findsNWidgets(2));
    // The front cover keeps its shadow Container in both modes.
    expect(find.byKey(const ValueKey('coverShadow')), findsOneWidget);
  });

  testWidgets('a stacked tile keeps the same cover size as a flat tile (the '
      'deck overhangs to the right instead of cropping the cover)', (
    tester,
  ) async {
    final scope = await TestScope.create();
    addTearDown(scope.db.close);

    Future<Size> coverSizeFor({required bool stacked}) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ...scope.overrides,
            coverImageProvider('s', 'series', 'x')
                .overrideWith((ref) async => null),
          ],
          child: MaterialApp(
            theme: darkTheme,
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 120,
                  height: 200,
                  child: CoverTile(
                    sourceId: 's',
                    ownerType: 'series',
                    ownerId: 'x',
                    title: 'Title',
                    stacked: stacked,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return tester.getSize(find.byKey(const ValueKey('coverShadow')));
    }

    final flat = await coverSizeFor(stacked: false);
    final stacked = await coverSizeFor(stacked: true);
    // The series deck must not steal width from the cover: its front cover is
    // exactly the size a chapter's flat cover would be, so the thumbnail is the
    // same (the deck "pages" peek past the right edge, widening the tile).
    expect(stacked, flat);
  });

  testWidgets('ReadCorner paints a fold (with its checkmark)', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: ReadCorner())),
      ),
    );
    // The fold and its check are hand-painted, so assert the painter renders.
    expect(find.byType(ReadCorner), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
  });

  Widget bookCorner({required bool completed}) => ProviderScope(
        overrides: [
          bookCompletedProvider('s', 'b')
              .overrideWith((ref) => Stream.value(completed)),
        ],
        child: const MaterialApp(
          home: Scaffold(body: BookReadCorner(sourceId: 's', bookId: 'b')),
        ),
      );

  testWidgets('BookReadCorner stays hidden while the book is unread', (
    tester,
  ) async {
    await tester.pumpWidget(bookCorner(completed: false));
    await tester.pumpAndSettle();
    expect(find.byType(ReadCorner), findsNothing);
  });

  testWidgets('BookReadCorner shows the fold once the book is completed', (
    tester,
  ) async {
    await tester.pumpWidget(bookCorner(completed: true));
    await tester.pumpAndSettle();
    expect(find.byType(ReadCorner), findsOneWidget);
  });

  group('progress strip', () {
    Future<void> pumpTile(WidgetTester tester, {double? progress}) async {
      final scope = await TestScope.create();
      addTearDown(scope.db.close);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ...scope.overrides,
            coverImageProvider('s', 'book', 'x')
                .overrideWith((ref) async => null),
          ],
          child: MaterialApp(
            theme: darkTheme,
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 120,
                  height: 200,
                  child: CoverTile(
                    sourceId: 's',
                    ownerType: 'book',
                    ownerId: 'x',
                    title: 'Title',
                    progress: progress,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    const strip = ValueKey('coverProgressStrip');

    testWidgets('an in-progress fraction draws the strip on the cover', (
      tester,
    ) async {
      await pumpTile(tester, progress: 0.4);
      expect(find.byKey(strip), findsOneWidget);
      // The fill matches the fraction.
      final fill = tester.widget<FractionallySizedBox>(
        find.descendant(
          of: find.byKey(strip),
          matching: find.byType(FractionallySizedBox),
        ),
      );
      expect(fill.widthFactor, closeTo(0.4, 0.0001));
    });

    testWidgets('no progress draws no strip', (tester) async {
      await pumpTile(tester);
      expect(find.byKey(strip), findsNothing);
    });

    testWidgets('unstarted (0) and completed (1) draw no strip', (
      tester,
    ) async {
      await pumpTile(tester, progress: 0);
      expect(find.byKey(strip), findsNothing);
      await pumpTile(tester, progress: 1);
      expect(find.byKey(strip), findsNothing,
          reason: 'completed books keep the read corner, not a full strip');
    });
  });
}
