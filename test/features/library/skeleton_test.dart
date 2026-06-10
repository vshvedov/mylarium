import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/theme/app_theme.dart';
import 'package:mylarium/features/library/widgets/skeleton.dart';

Widget _host(ThemeData theme) => MaterialApp(
      theme: theme,
      home: const Scaffold(
        body: SkeletonRail(title: 'Keep reading', count: 2),
      ),
    );

void main() {
  testWidgets('e-ink renders the skeleton static: no animation runs',
      (tester) async {
    await tester.pumpWidget(_host(einkTheme));
    await tester.pump();

    expect(find.byType(SkeletonTile), findsNWidgets(2));
    // No pulse on e-ink: a frozen Opacity instead of a FadeTransition, and no
    // ticker scheduling frames.
    expect(
      find.descendant(
        of: find.byType(SkeletonTile),
        matching: find.byType(FadeTransition),
      ),
      findsNothing,
    );
    final opacity = tester.widget<Opacity>(
      find
          .descendant(
            of: find.byType(SkeletonTile),
            matching: find.byType(Opacity),
          )
          .first,
    );
    expect(opacity.opacity, 0.5);
    expect(tester.hasRunningAnimations, isFalse);
    // Settles immediately; a running pulse would make this throw.
    await tester.pumpAndSettle();
  });

  testWidgets('non-e-ink pulses the tiles with a repeating fade',
      (tester) async {
    await tester.pumpWidget(_host(lightTheme));
    await tester.pump();

    expect(
      find.descendant(
        of: find.byType(SkeletonTile),
        matching: find.byType(FadeTransition),
      ),
      findsWidgets,
    );
    expect(tester.hasRunningAnimations, isTrue);

    // Dispose the tree so the repeating controllers are torn down before the
    // end-of-test invariants run.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
}
