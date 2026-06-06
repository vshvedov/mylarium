import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/widgets/app_loading.dart';

void main() {
  testWidgets('AppLoadingIndicator renders centered at the given size',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AppLoadingIndicator(size: 64)),
      ),
    );

    expect(find.byType(AppLoadingIndicator), findsOneWidget);
    final box = tester.widget<SizedBox>(
      find
          .descendant(
            of: find.byType(AppLoadingIndicator),
            matching: find.byType(SizedBox),
          )
          .first,
    );
    expect(box.width, 64);
    expect(box.height, 64);
    // The Lottie asset loads asynchronously; building must not throw even if the
    // asset is unavailable in the test bundle.
    expect(tester.takeException(), isNull);
  });
}
