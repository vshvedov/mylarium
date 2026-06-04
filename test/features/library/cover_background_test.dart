import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/theme/app_theme.dart';
import 'package:mylarium/app/theme/cover_palette.dart';

Widget _host(List<Override> overrides) => ProviderScope(
  overrides: overrides,
  child: MaterialApp(
    theme: darkTheme,
    home: const Scaffold(
      body: SizedBox(
        width: 240,
        height: 240,
        child: CoverBackground(sourceId: 's', ownerType: 'book', ownerId: 'b'),
      ),
    ),
  ),
);

void main() {
  testWidgets('falls back to the gradient when there is no cover', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host([
        coverPaletteProvider(
          's',
          'book',
          'b',
        ).overrideWith((ref) async => null),
      ]),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    // No blurred cover layer (showBlurredCover defaults false).
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('renders the palette branch when a cover palette exists', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host([
        coverPaletteProvider('s', 'book', 'b').overrideWith(
          (ref) async => const CoverPalette(
            dominant: Color(0xFF884422),
            muted: Color(0xFF221108),
          ),
        ),
      ]),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(Image), findsNothing);
  });
}
