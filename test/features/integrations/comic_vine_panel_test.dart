import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/data/comicvine/comic_vine_api.dart';
import 'package:mylarium/data/comicvine/comic_vine_models.dart';
import 'package:mylarium/features/integrations/comic_vine/comic_vine_panel.dart';
import 'package:mylarium/features/integrations/comic_vine/comic_vine_providers.dart';

Future<void> _pump(WidgetTester tester, List<Override> overrides) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: const MaterialApp(
        home: Scaffold(
          body: ComicVineDetailsPanel(
            ownerKind: 'series',
            sourceId: 's',
            ownerId: 'x',
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  final volume = comicVineVolumeProvider(('s', 'x'));

  testWidgets('no key shows the connect placeholder', (tester) async {
    await _pump(tester, [
      comicVineApiKeyProvider.overrideWith((ref) async => null),
    ]);
    expect(find.text('Comic Vine details'), findsOneWidget);
    expect(find.text('Add API key'), findsOneWidget);
  });

  testWidgets('a match renders the structured details', (tester) async {
    await _pump(tester, [
      comicVineApiKeyProvider.overrideWith((ref) async => 'key'),
      volume.overrideWith(
        (ref) async => const ComicVineVolumeData(
          matchedId: 1,
          name: 'Saga',
          deck: 'Space opera',
          characters: ['Alana'],
        ),
      ),
    ]);
    expect(find.text('Space opera'), findsOneWidget);
    expect(find.text('Alana'), findsOneWidget);
    expect(find.text('Characters'), findsOneWidget);
  });

  testWidgets('no match renders nothing (no placeholder)', (tester) async {
    await _pump(tester, [
      comicVineApiKeyProvider.overrideWith((ref) async => 'key'),
      volume.overrideWith((ref) async => null),
    ]);
    expect(find.text('COMIC VINE'), findsNothing);
    expect(find.text('No Comic Vine match for this title.'), findsNothing);
  });

  testWidgets('a fetch error shows a Retry affordance', (tester) async {
    await _pump(tester, [
      comicVineApiKeyProvider.overrideWith((ref) async => 'key'),
      volume.overrideWith(
        (ref) async => throw const ComicVineApiError(100, 'bad key'),
      ),
    ]);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('offline with no cache renders nothing (no placeholder)', (
    tester,
  ) async {
    await _pump(tester, [
      comicVineApiKeyProvider.overrideWith((ref) async => 'key'),
      volume.overrideWith((ref) async => throw const ComicVineOffline()),
    ]);
    expect(find.text('COMIC VINE'), findsNothing);
    expect(find.text('Comic Vine is offline'), findsNothing);
  });
}
