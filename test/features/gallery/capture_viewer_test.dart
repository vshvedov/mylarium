import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/theme/app_icons.dart';
import 'package:mylarium/app/theme/app_theme.dart';
import 'package:mylarium/features/gallery/capture_export.dart';
import 'package:mylarium/features/gallery/capture_models.dart';
import 'package:mylarium/features/gallery/capture_viewer_screen.dart';
import 'package:mylarium/features/gallery/gallery_controller.dart';

/// Exporter that returns a fixed result without touching any platform plugin.
class _FakeExporter extends CaptureExporter {
  const _FakeExporter(this.result);

  final CaptureExportResult result;

  @override
  Future<CaptureExportResult> export(Capture capture) async => result;
}

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

Future<void> _pump(
  WidgetTester tester, {
  required bool chapterAvailable,
  CaptureExporter? exporter,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        captureByIdProvider('c1').overrideWith((ref) => _capture()),
        captureChapterAvailableProvider('s', 'b')
            .overrideWith((ref) => chapterAvailable),
        if (exporter != null)
          captureExporterProvider.overrideWithValue(exporter),
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
  testWidgets('shows the snippet and the chapter-only caption',
      (tester) async {
    await _pump(tester, chapterAvailable: true);
    // The snippet image widget is present (its file is absent in the test, so
    // the missing-image placeholder renders, but the viewer still shows it).
    expect(find.byType(Image), findsOneWidget);
    // Header is the chapter title alone: no series prefix, no page suffix.
    expect(find.text('Chapter 1'), findsOneWidget);
    expect(find.textContaining('My Series'), findsNothing);
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

  testWidgets('export button confirms a Photos save', (tester) async {
    await _pump(
      tester,
      chapterAvailable: true,
      exporter: const _FakeExporter(CaptureExportResult.savedToPhotos),
    );
    await tester.tap(find.byIcon(AppIcons.export));
    await tester.pump(); // run the export future
    await tester.pump(); // surface the snackbar
    expect(find.text('Saved to Photos'), findsOneWidget);
  });

  testWidgets('export button surfaces a failure', (tester) async {
    await _pump(
      tester,
      chapterAvailable: true,
      exporter: const _FakeExporter(CaptureExportResult.failed),
    );
    await tester.tap(find.byIcon(AppIcons.export));
    await tester.pump();
    await tester.pump();
    expect(find.text('Could not export capture.'), findsOneWidget);
  });

  testWidgets('export button shows no snackbar when cancelled', (tester) async {
    await _pump(
      tester,
      chapterAvailable: true,
      exporter: const _FakeExporter(CaptureExportResult.cancelled),
    );
    await tester.tap(find.byIcon(AppIcons.export));
    await tester.pump();
    await tester.pump();
    expect(find.byType(SnackBar), findsNothing);
  });
}
