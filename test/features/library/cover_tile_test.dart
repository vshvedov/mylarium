import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/theme/app_theme.dart';
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
}
