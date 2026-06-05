import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/theme/app_icons.dart';
import 'package:mylarium/features/reader/reader_navigation.dart';
import 'package:mylarium/features/reader/widgets/reader_seam.dart';

void main() {
  Widget host(ReaderSeam seam) => MaterialApp(home: Scaffold(body: seam));

  testWidgets('shows the next book and opens it on tap', (tester) async {
    String? opened;
    await tester.pumpWidget(host(ReaderSeam(
      title: 'Iron Man 1',
      neighbors: const BookNeighbors(nextId: 'n', nextTitle: 'Iron Man 2'),
      onOpenBook: (id) => opened = id,
      onDismiss: () {},
    )));

    expect(find.text('Iron Man 1'), findsOneWidget);
    expect(find.text('Next: Iron Man 2'), findsOneWidget);
    await tester.tap(find.text('Next: Iron Man 2'));
    expect(opened, 'n');
  });

  testWidgets('shows last-in-series when there is no next', (tester) async {
    await tester.pumpWidget(host(ReaderSeam(
      title: 'The End',
      neighbors: const BookNeighbors(),
      onOpenBook: (_) {},
      onDismiss: () {},
    )));

    expect(find.text('Last in this series'), findsOneWidget);
    expect(find.text('The End'), findsOneWidget);
  });

  testWidgets('close fires onDismiss', (tester) async {
    var dismissed = false;
    await tester.pumpWidget(host(ReaderSeam(
      title: 'X',
      neighbors: const BookNeighbors(),
      onOpenBook: (_) {},
      onDismiss: () => dismissed = true,
    )));

    await tester.tap(find.byIcon(AppIcons.close));
    expect(dismissed, isTrue);
  });
}
