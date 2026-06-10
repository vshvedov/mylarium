// On-device reader smoke test (hermetic: no network, no Komga server).
//
// Why this exists: we shipped a regression where PhotoViewGallery captured its
// PageController once and never attached a swapped-in instance. The reader
// recreates the controller when the reading direction (or mode) flips, so
// after "Toggle reading direction" every tap-zone page turn silently no-oped
// on `hasClients == false` while swipes kept working through the stale
// controller. Nothing crashed, no unit test could see it, and the reader just
// felt dead. This suite drives the REAL app (real provider graph, real
// go_router, real photo_view gesture arena, real archive-decode isolate) on a
// device/simulator and asserts that taps still turn pages across a direction
// toggle, and that progress persists across a reader close/reopen.
//
// Hermeticity:
// - appDatabaseProvider is overridden with an in-memory Drift database,
//   pre-seeded with one 'local' source and one imported comic.
// - AppPaths.debugOverrideRoot points at a temp directory, where a small but
//   fully valid 5-page CBZ fixture is written before the app boots. The local
//   source has no ContentApi, so nothing ever touches the network.
// - No pumpAndSettle anywhere: the app holds live Drift streams (which never
//   settle), so all waiting is explicit pump(duration) polling via
//   [pumpUntilFound] / [pumpUntil].
//
// Run with: flutter test integration_test -d <device>

import 'dart:async';
import 'dart:convert' show jsonEncode;
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:archive/archive.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:mylarium/app/app.dart';
import 'package:mylarium/app/router.dart';
import 'package:mylarium/app/theme/app_icons.dart';
import 'package:mylarium/app/theme/theme_controller.dart';
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/core/fs/app_paths.dart';
import 'package:mylarium/features/reader/paged_view.dart';
import 'package:mylarium/features/reader/reader_models.dart';
import 'package:mylarium/features/reader/reader_screen.dart';
import 'package:mylarium/features/reader/reader_settings_repository.dart';
import 'package:mylarium/features/reader/widgets/reader_chrome.dart';

const _sourceId = 'loc';
const _comicId = 'c1';
const _pageNames = ['001.png', '002.png', '003.png', '004.png', '005.png'];

/// Polls real frames until [finder] matches at least once. Never use
/// pumpAndSettle in this app: live Drift streams keep the frame pipeline from
/// ever settling, so settle-based waiting hangs until its own timeout.
Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 20),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('Timed out after $timeout waiting for $finder');
}

/// Polls real frames until [condition] holds. For state that is not a widget
/// (database rows, widget properties), where a Finder cannot express the wait.
Future<void> pumpUntil(
  WidgetTester tester,
  String description,
  FutureOr<bool> Function() condition, {
  Duration timeout = const Duration(seconds: 20),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    if (await condition()) return;
    await tester.pump(const Duration(milliseconds: 100));
  }
  fail('Timed out after $timeout waiting for $description');
}

/// A solid-color PNG (64x96, a sane portrait page aspect), encoded through the
/// real engine codec so the reader's decode pipeline sees a genuine image.
/// Distinct colors keep the five fixture pages visually distinguishable when
/// debugging a failure on a simulator screen.
Future<List<int>> _solidPng(Color color) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(const Rect.fromLTWH(0, 0, 64, 96), Paint()..color = color);
  final image = await recorder.endRecording().toImage(64, 96);
  try {
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  } finally {
    image.dispose();
  }
}

/// Writes the 5-page CBZ fixture into the (overridden) app-support media root
/// at the exact relative path the seeded LocalComics row records, and returns
/// the per-page PNG bytes (page 1 doubles as the seeded cover thumbnail).
Future<List<List<int>>> _writeFixtureCbz() async {
  const colors = [
    Color(0xFFAA3333),
    Color(0xFF33AA33),
    Color(0xFF3333AA),
    Color(0xFFAAAA33),
    Color(0xFFAA33AA),
  ];
  final pages = [for (final c in colors) await _solidPng(c)];
  final archive = Archive();
  for (var i = 0; i < _pageNames.length; i++) {
    archive.add(ArchiveFile.bytes(_pageNames[i], pages[i]));
  }
  final file = await AppPaths.prepareFile(
    AppPaths.localRelativePath(_sourceId, _comicId),
  );
  file.writeAsBytesSync(ZipEncoder().encodeBytes(archive));
  return pages;
}

/// Seeds the database exactly like a finished import would: the local source
/// row, one comic row pointing at the CBZ fixture, a cover thumbnail, and a
/// persisted (default, LTR) reader-settings row for the series.
///
/// The settings row matters for determinism: without it the reader shows the
/// one-time "try right-to-left" direction nudge (directionUnset), an extra
/// overlay this smoke flow does not exercise.
Future<void> _seedDatabase(AppDatabase db, List<int> coverPng) async {
  await db.upsertSource(const SourcesCompanion(
    id: Value(_sourceId),
    kind: Value('local'),
    label: Value('Local files'),
  ));
  await db.insertLocalComic(LocalComicsCompanion.insert(
    id: _comicId,
    sourceId: _sourceId,
    kind: 'localCopy',
    managedPath: Value(AppPaths.localRelativePath(_sourceId, _comicId)),
    series: 'Berserk',
    seriesSort: 'berserk',
    number: '1',
    numberSort: const Value(1.0),
    title: 'Berserk 1',
    readingDirection: const Value('ltr'),
    pageOrder: jsonEncode(_pageNames),
    pagesCount: _pageNames.length,
    importedAt: DateTime.now().millisecondsSinceEpoch,
  ));
  await db.upsertThumbnail(ThumbnailsCompanion(
    sourceId: const Value(_sourceId),
    ownerType: const Value('book'),
    ownerId: const Value(_comicId),
    bytes: Value(Uint8List.fromList(coverPng)),
    fetchedAt: Value(DateTime.now().millisecondsSinceEpoch),
  ));
  // seriesId for local books is the series NAME (local series have no id).
  await ReaderSettingsRepository(db)
      .save(_sourceId, 'Berserk', const ReaderSettings());
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // Render frames continuously so real-time animations (page turns, popup
  // menus, route transitions) progress between explicit pumps.
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets(
    'local book: taps turn pages, survive a direction toggle, progress persists',
    (tester) async {
      // --- Hermetic bootstrap (mirrors main(), minus network side effects) --
      // main() also kicks off download resume, Komga launch sync, and the live
      // SSE stream; all are fire-and-forget extras that need a server source,
      // so the test skips them and boots the same widget tree main() runs.
      final tmp = await Directory.systemTemp.createTemp('mylarium_itest');
      AppPaths.debugOverrideRoot = tmp.path;
      addTearDown(() {
        AppPaths.debugOverrideRoot = null;
        if (tmp.existsSync()) tmp.deleteSync(recursive: true);
      });

      final pages = await _writeFixtureCbz();

      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      await _seedDatabase(db, pages.first);
      final settings = await db.getOrCreateSettings();

      final container = ProviderContainer(overrides: [
        appDatabaseProvider.overrideWithValue(db),
        initialSettingsProvider.overrideWithValue(settings),
        // A source exists, so boot straight to home (main() checks
        // hasAnySource; here it is true by construction).
        initialLocationProvider.overrideWithValue('/'),
      ]);
      addTearDown(container.dispose);

      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: const MylariumApp(),
      ));

      // --- 1. Boots to the local home; the seeded book is on the shelf ------
      await pumpUntilFound(tester, find.text('Recently imported'));
      final tile = find.text('Berserk 1');
      await pumpUntilFound(tester, tile);

      // --- 2. Open the book: tile -> detail -> Read (all real taps) ---------
      await tester.tap(tile.first);
      final readButton = find.widgetWithText(FilledButton, 'Read');
      await pumpUntilFound(tester, readButton);
      await tester.tap(readButton);

      // --- 3. Reader shows page 1; a RIGHT-zone tap advances ----------------
      await pumpUntilFound(tester, find.byType(PagedView));
      // The scrubber label lives in the always-mounted chrome (it is only
      // faded out while hidden), so 'N/5' is assertable without opening it.
      expect(find.text('1/5'), findsOneWidget);

      // Normalized tap-zone helper over the reader viewport. Default preset is
      // lrEdges: x < 0.30 prev, x > 0.70 next, center box toggles chrome.
      Future<void> tapZone(double fx) async {
        final rect = tester.getRect(find.byType(ReaderScreen));
        await tester.tapAt(Offset(
          rect.left + rect.width * fx,
          rect.top + rect.height * 0.5,
        ));
        // Outlive photo_view's double-tap disambiguation window plus the page
        // animation, so consecutive zone taps never couple into a double tap.
        await tester.pump(const Duration(milliseconds: 350));
      }

      // Page-turn taps only land once photo_view has swapped its loading
      // builder for the decoded image (taps are wired to the resolved image,
      // not the placeholder), and the gesture arena's double-tap window adds
      // its own latency. So: wait for a decoded frame first, then retry the
      // zone tap until the scrubber reports the expected page.
      Future<void> turnPage(double fx, String expectedLabel) async {
        final label = find.text(expectedLabel);
        for (var attempt = 0; attempt < 6; attempt++) {
          await tapZone(fx);
          final deadline = DateTime.now().add(const Duration(seconds: 3));
          while (DateTime.now().isBefore(deadline)) {
            await tester.pump(const Duration(milliseconds: 100));
            if (label.evaluate().isNotEmpty) return;
          }
        }
        fail('page never reached $expectedLabel after 6 zone taps at $fx');
      }

      // First decoded page frame: photo_view drops its loading builder and
      // renders the image (RawImage is the resolved end of that pipeline).
      await pumpUntilFound(tester, find.byType(RawImage));

      await turnPage(0.85, '2/5'); // LTR: right zone = next

      // --- 4. Open chrome, toggle reading direction via the overflow menu ---
      // Retry like turnPage: a center tap that loses its gesture-arena race
      // (or couples into a double tap) is otherwise a one-shot dead end.
      var chromeVisible = false;
      for (var attempt = 0; attempt < 6 && !chromeVisible; attempt++) {
        await tapZone(0.5); // center box toggles chrome
        final deadline = DateTime.now().add(const Duration(seconds: 2));
        while (DateTime.now().isBefore(deadline)) {
          await tester.pump(const Duration(milliseconds: 100));
          chromeVisible =
              tester.widget<ReaderChrome>(find.byType(ReaderChrome)).visible;
          if (chromeVisible) break;
        }
      }
      expect(chromeVisible, isTrue,
          reason: 'chrome never appeared after 6 center taps');
      // The options menu is the only PopupMenuButton<String> in the top bar
      // (mode and fit menus are typed by their enums).
      await tester.tap(
        find.byWidgetPredicate((w) => w is PopupMenuButton<String>),
      );
      final toggleItem = find.text('Toggle reading direction');
      await pumpUntilFound(tester, toggleItem);
      await tester.tap(toggleItem);
      // Wait for the toggle to land: settings persist, the controller state
      // emits, and the reader swaps in a NEW PageController (the regression
      // hot spot: PhotoViewGallery must attach the swapped-in controller).
      await pumpUntil(
        tester,
        'reader to flip to RTL',
        () => tester.widget<ReaderChrome>(find.byType(ReaderChrome)).rtl,
      );
      // Let the menu route finish animating out so its barrier cannot eat the
      // next tap, then confirm the toggle did not move the page.
      await pumpUntil(
        tester,
        'options menu to close',
        () => find.text('Toggle reading direction').evaluate().isEmpty,
      );
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('2/5'), findsOneWidget);

      // --- 5. THE regression: in RTL a LEFT-zone tap must ADVANCE -----------
      // Before the fix this tap silently no-oped: the new PageController had
      // no attached view (hasClients == false), _step() returned early, no
      // crash, no page turn. Swipes kept working, which is what made the bug
      // invisible to everything but a real tap on a real gesture arena.
      await turnPage(0.15, '3/5');

      // --- 6. And a RIGHT-zone tap must go BACK ------------------------------
      await turnPage(0.85, '2/5');

      // --- 7. Close, reopen: resumes at the saved page through the real graph
      // Retry the back tap until the reader route actually leaves the tree:
      // navigator keeps lower routes mounted, so every later finder would
      // happily match the obscured detail screen and mask a missed pop.
      for (var attempt = 0;
          attempt < 6 && find.byType(PagedView).evaluate().isNotEmpty;
          attempt++) {
        await tester.tap(
          find.descendant(
            of: find.byType(ReaderChrome),
            matching: find.byIcon(AppIcons.back),
          ),
          warnIfMissed: false,
        );
        final deadline = DateTime.now().add(const Duration(seconds: 2));
        while (DateTime.now().isBefore(deadline) &&
            find.byType(PagedView).evaluate().isNotEmpty) {
          await tester.pump(const Duration(milliseconds: 100));
        }
      }
      expect(find.byType(PagedView), findsNothing,
          reason: 'reader never popped after 6 back taps');
      // The teardown progress push is fire-and-forget; poll the database for
      // the persisted BookState. Progress is FURTHEST-page-wins (the PRD's
      // resolution policy), so although the reader closed on displayed page 2,
      // the furthest page visited was 3 (0-based 2) and that is what persists.
      await pumpUntil(
        tester,
        'BookState to record the furthest page (3)',
        () async =>
            (await db.getBookState(_sourceId, _comicId))?.currentPage == 2,
      );
      // Back on the detail screen the action now reads "Continue reading"
      // (read state exists); find the button by its icon to stay robust.
      final reopen = find.widgetWithIcon(FilledButton, AppIcons.read);
      await pumpUntilFound(tester, reopen);
      await tester.tap(reopen);
      await pumpUntilFound(tester, find.byType(PagedView));
      // Resume honors the furthest-wins position too (chrome property, not
      // label text, so a timeout reports the actual page; .last because the
      // route below can still be animating out for the first frames).
      await pumpUntil(
        tester,
        'reopened reader to resume at page 3',
        () =>
            find.byType(ReaderChrome).evaluate().isNotEmpty &&
            tester
                    .widget<ReaderChrome>(find.byType(ReaderChrome).last)
                    .currentPage ==
                2,
      );
      // Still RTL: the direction toggle was persisted per series.
      expect(
        tester.widget<ReaderChrome>(find.byType(ReaderChrome)).rtl,
        isTrue,
      );

      // Tear the tree down while the database is still open, so reader/home
      // teardown writes (progress push, session log) cannot race db.close in
      // the LIFO tearDown chain.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 200));
    },
  );
}
