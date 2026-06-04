import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/widgets/adaptive_layout.dart';

const _layout = MaterialApp(
  home: Scaffold(
    body: AdaptiveLayout(
      master: Text('MASTER'),
      detail: Text('DETAIL'),
      detailPlaceholder: Text('PLACEHOLDER'),
    ),
  ),
);

void main() {
  testWidgets('two-pane at a tablet width shows master and detail', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1024, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_layout);

    expect(find.text('MASTER'), findsOneWidget);
    expect(find.text('DETAIL'), findsOneWidget);
    expect(find.byType(VerticalDivider), findsOneWidget);
  });

  testWidgets('single-pane at a phone width shows only the master', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_layout);

    expect(find.text('MASTER'), findsOneWidget);
    expect(find.text('DETAIL'), findsNothing);
    expect(find.text('PLACEHOLDER'), findsNothing);
  });
}
