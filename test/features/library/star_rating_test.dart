import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/features/library/widgets/star_rating.dart';

void main() {
  testWidgets('fills stars up to the value', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: StarRating(value: 3, onChanged: (_) {}),
      ),
    ));
    expect(find.byType(Icon), findsNWidgets(5));
  });

  testWidgets('tapping a star reports that rating; re-tapping clears to null',
      (tester) async {
    int? captured = -1;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: StarRating(value: 3, onChanged: (v) => captured = v),
      ),
    ));

    final stars = find.byType(Icon);
    await tester.tap(stars.at(4)); // 5th star -> rating 5
    expect(captured, 5);

    await tester.tap(stars.at(2)); // the current value (3) -> clear
    expect(captured, isNull);
  });
}
