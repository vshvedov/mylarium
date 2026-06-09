import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/theme/app_theme.dart';
import 'package:mylarium/features/gallery/capture_models.dart';
import 'package:mylarium/features/gallery/capture_viewer_screen.dart';
import 'package:mylarium/features/gallery/gallery_controller.dart';

Capture _capture() => const Capture(
      id: 'c1',
      sourceId: 's',
      seriesId: 'se',
      bookId: 'b',
      libraryId: null,
      seriesTitle: 'My Series',
      bookTitle: 'Chapter 1',
      pageNumber: 4,
      relativePath: 'media/captures/s/b/c1.png',
      absolutePath: '/nonexistent/c1.png',
      width: 100,
      height: 200,
      capturedAt: 1700000000000,
    );

Future<void> _pump(WidgetTester tester, {required bool chapterAvailable}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        captureByIdProvider('c1').overrideWith((ref) => _capture()),
        captureChapterAvailableProvider('s', 'b')
            .overrideWith((ref) => chapterAvailable),
      ],
      child: MaterialApp(
        theme: darkTheme,
        home: const CaptureViewerScreen(id: 'c1'),
      ),
    ),
  );
  await tester.pump(); // resolve the capture + availability futures
  await tester.pump();
}

void main() {
  testWidgets('shows the snippet and its series/chapter caption',
      (tester) async {
    await _pump(tester, chapterAvailable: true);
    // The snippet image widget is present (its file is absent in the test, so
    // the missing-image placeholder renders, but the viewer still shows it).
    expect(find.byType(Image), findsOneWidget);
    expect(find.text('My Series · Chapter 1 · p.5'), findsOneWidget);
  });

  testWidgets('offers "Go to page" when the chapter is still available',
      (tester) async {
    await _pump(tester, chapterAvailable: true);
    expect(find.text('Go to page'), findsOneWidget);
  });

  testWidgets('hides "Go to page" when the chapter was deleted', (tester) async {
    await _pump(tester, chapterAvailable: false);
    expect(find.text('Go to page'), findsNothing);
    // The snippet itself is still viewable.
    expect(find.byType(Image), findsOneWidget);
  });
}
