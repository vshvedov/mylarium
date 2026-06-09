import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/features/gallery/capture_models.dart';
import 'package:mylarium/features/gallery/gallery_controller.dart';
import 'package:mylarium/features/gallery/gallery_screen.dart';

Capture _capture(String id) => Capture(
      id: id,
      sourceId: 's',
      seriesId: 'se',
      bookId: 'b',
      libraryId: null,
      seriesTitle: 'Series $id',
      bookTitle: 'Book $id',
      pageNumber: 2,
      relativePath: 'media/captures/s/b/$id.png',
      absolutePath: '/nonexistent/$id.png',
      width: 100,
      height: 200,
      capturedAt: 1700000000000,
    );

Future<void> _pump(WidgetTester tester, List<Capture> captures) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        capturesProvider.overrideWith((ref) => Stream.value(captures)),
      ],
      child: const MaterialApp(home: GalleryScreen()),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('shows the empty state when there are no captures',
      (tester) async {
    await _pump(tester, const []);
    expect(find.text('No captures yet.'), findsOneWidget);
  });

  testWidgets('renders a tile per capture titled with the chapter name',
      (tester) async {
    await _pump(tester, [_capture('a'), _capture('b')]);
    expect(find.byType(Image), findsNWidgets(2));
    // The tile title is just the chapter name (no series line, no page suffix).
    expect(find.text('Book a'), findsOneWidget);
    expect(find.text('Series a'), findsNothing);
  });
}
