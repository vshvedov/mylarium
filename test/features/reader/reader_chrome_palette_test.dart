import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/theme/app_icons.dart';
import 'package:mylarium/app/theme/app_theme.dart';
import 'package:mylarium/app/theme/cover_palette.dart';
import 'package:mylarium/features/reader/reader_models.dart';
import 'package:mylarium/features/reader/reader_navigation.dart';
import 'package:mylarium/features/reader/widgets/reader_chrome.dart';

ReaderChrome _chrome({
  ReaderSettings settings = const ReaderSettings(),
  bool rtl = false,
  BookNeighbors neighbors = const BookNeighbors(),
  VoidCallback? onToggleDirection = _noop,
  void Function(int)? onJumpToPage,
}) =>
    ReaderChrome(
      visible: true,
      title: 'Page 1 of 10',
      sourceId: 's',
      bookId: 'b',
      offline: false,
      settings: settings,
      pageCount: 10,
      currentPage: 0,
      thumbnailImage: (_) => const AssetImage('none'),
      rtl: rtl,
      neighbors: neighbors,
      onClose: () {},
      onSettings: (_) {},
      onSeekPage: (_) {},
      onJumpToPage: onJumpToPage ?? (_) {},
      onOpenBook: (_) {},
      onToggleDirection: onToggleDirection,
      onImageQuality: () {},
      onColorCorrection: () {},
      onCapture: () {},
    );

void _noop() {}

final _plain = darkTheme.colorScheme.surface.withValues(alpha: 0.92);

Future<Color> _topBarColor(WidgetTester tester, Override override) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [override],
      child: MaterialApp(
        theme: darkTheme,
        home: Scaffold(body: Stack(children: [_chrome()])),
      ),
    ),
  );
  await tester.pumpAndSettle(); // let the async palette override resolve
  final material = tester.widget<Material>(
    find
        .ancestor(
          of: find.text('Page 1 of 10'),
          matching: find.byType(Material),
        )
        .first,
  );
  return material.color!;
}

Future<void> _pump(WidgetTester tester, ReaderChrome chrome) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        // The chrome watches the cover palette; override it so a bare test scope
        // does not hang resolving it.
        coverPaletteProvider('s', 'book', 'b').overrideWith((ref) async => null),
      ],
      child: MaterialApp(
        theme: darkTheme,
        home: Scaffold(body: Stack(children: [chrome])),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('chapter buttons disabled when no neighbors, enabled with them',
      (tester) async {
    await _pump(tester, _chrome());
    IconButton btn(IconData icon) => tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, icon).first);
    expect(btn(AppIcons.prevChapter).onPressed, isNull);
    expect(btn(AppIcons.nextChapter).onPressed, isNull);

    await _pump(
      tester,
      _chrome(
        neighbors: const BookNeighbors(
          prevId: 'p',
          prevTitle: 'Prev',
          nextId: 'n',
          nextTitle: 'Next',
        ),
      ),
    );
    expect(btn(AppIcons.prevChapter).onPressed, isNotNull);
    expect(btn(AppIcons.nextChapter).onPressed, isNotNull);
  });

  testWidgets(
      'direction toggle lives in the options menu, hidden in webtoon',
      (tester) async {
    // The toggle is an options-menu entry now, never a bar icon.
    await _pump(tester, _chrome(onToggleDirection: null));
    expect(find.byIcon(AppIcons.readingDirection), findsNothing);
    await tester.tap(find.byIcon(AppIcons.options));
    await tester.pumpAndSettle();
    expect(find.text('Toggle reading direction'), findsNothing);
    expect(find.text('Capture page'), findsOneWidget);

    // Close the open menu before re-pumping: the options glyph also appears
    // on the Image quality row, which would make the next tap ambiguous.
    await tester.tapAt(const Offset(5, 590));
    await tester.pumpAndSettle();

    await _pump(tester, _chrome(onToggleDirection: _noop));
    await tester.tap(find.byIcon(AppIcons.options).first);
    await tester.pumpAndSettle();
    expect(find.text('Toggle reading direction'), findsOneWidget);
    expect(find.byIcon(AppIcons.readingDirection), findsOneWidget);
  });

  testWidgets('scrubber Directionality follows the rtl prop', (tester) async {
    await _pump(tester, _chrome(rtl: true));
    final dir = tester.widget<Directionality>(
      find
          .ancestor(of: find.byType(Slider), matching: find.byType(Directionality))
          .first,
    );
    expect(dir.textDirection, TextDirection.rtl);
  });

  testWidgets('jump-to-page dialog seeks and disposes cleanly', (tester) async {
    int? jumped;
    await _pump(tester, _chrome(onJumpToPage: (p) => jumped = p));
    // Open the dialog via the page counter, enter a page, confirm.
    await tester.tap(find.text('1/10'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '5');
    await tester.tap(find.text('Go'));
    // pumpAndSettle runs the dialog's exit animation; a synchronously-disposed
    // controller would throw "used after being disposed" here.
    await tester.pumpAndSettle();
    expect(jumped, 4); // 1-based 5 -> 0-based 4
    expect(tester.takeException(), isNull);
  });

  testWidgets('chrome top bar tints with the cover palette', (tester) async {
    final tinted = await _topBarColor(
      tester,
      coverPaletteProvider('s', 'book', 'b').overrideWith(
        (ref) async => const CoverPalette(
          dominant: Color(0xFF6699CC),
          muted: Color(0xFF224466),
        ),
      ),
    );
    expect(tinted, isNot(_plain));
  });

  testWidgets(
    'chrome top bar falls back to the plain surface without a cover',
    (tester) async {
      final plain = await _topBarColor(
        tester,
        coverPaletteProvider(
          's',
          'book',
          'b',
        ).overrideWith((ref) async => null),
      );
      expect(plain, _plain);
    },
  );
}
