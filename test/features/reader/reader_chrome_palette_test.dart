import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/theme/app_theme.dart';
import 'package:mylarium/app/theme/cover_palette.dart';
import 'package:mylarium/features/reader/reader_models.dart';
import 'package:mylarium/features/reader/widgets/reader_chrome.dart';

ReaderChrome _chrome() => ReaderChrome(
  visible: true,
  title: 'Page 1 of 10',
  sourceId: 's',
  bookId: 'b',
  offline: false,
  settings: const ReaderSettings(),
  pageCount: 10,
  currentPage: 0,
  previewImage: (_) => const AssetImage('none'),
  onClose: () {},
  onSettings: (_) {},
  onSeekPage: (_) {},
  onImageQuality: () {},
  onColorCorrection: () {},
);

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

void main() {
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
