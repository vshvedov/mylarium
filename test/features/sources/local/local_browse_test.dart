import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/theme/app_theme.dart';
import 'package:mylarium/features/library/thumbnail_cache.dart';
import 'package:mylarium/features/sources/local/local_browse.dart';
import 'package:mylarium/features/sources/local/local_providers.dart';

void main() {
  testWidgets('series grid renders groups with counts', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        localSeriesProvider('l1').overrideWith((ref) => Stream.value(const [
              (
                series: 'Akira',
                seriesSort: 'akira',
                booksCount: 1,
                coverComicId: 'a1',
              ),
              (
                series: 'Berserk',
                seriesSort: 'berserk',
                booksCount: 3,
                coverComicId: 'b1',
              ),
            ])),
        coverImageProvider('l1', 'book', 'a1')
            .overrideWith((ref) async => null),
        coverImageProvider('l1', 'book', 'b1')
            .overrideWith((ref) async => null),
      ],
      child: MaterialApp(
        theme: lightTheme,
        home: const LocalBrowseShell(sourceId: 'l1'),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Akira'), findsOneWidget);
    expect(find.text('Berserk'), findsOneWidget);
    expect(find.text('1 book'), findsOneWidget);
    expect(find.text('3 books'), findsOneWidget);
  });
}
