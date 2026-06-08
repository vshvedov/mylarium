import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mylarium/app/theme/app_theme.dart';
import 'package:mylarium/features/library/thumbnail_cache.dart';
import 'package:mylarium/features/library/widgets/detail_header.dart';

void main() {
  testWidgets('hero title is near-black with no shadow in e-ink', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // The hero cover watches coverImageProvider; a bare scope would hang
          // on it. Resolve to null (placeholder cover) so the test settles.
          coverImageProvider('s', 'series', 'o').overrideWith((ref) async => null),
        ],
        child: MaterialApp(
          theme: einkTheme,
          home: const Scaffold(
            body: SingleChildScrollView(
              child: DetailHeader(
                sourceId: 's',
                ownerType: 'series',
                ownerId: 'o',
                title: 'Monochrome Title',
                pills: [],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final titleFinder = find.text('Monochrome Title');
    expect(titleFinder, findsOneWidget);
    final text = tester.widget<Text>(titleFinder);
    expect(text.style!.color, const Color(0xFF111111));
    expect(text.style!.shadows ?? const [], isEmpty);
  });
}
