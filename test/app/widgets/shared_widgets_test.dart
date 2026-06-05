import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/theme/app_theme.dart';
import 'package:mylarium/app/widgets/app_button.dart';
import 'package:mylarium/app/widgets/app_list_row.dart';
import 'package:mylarium/app/widgets/app_segmented_toggle.dart';
import 'package:mylarium/app/widgets/app_text_field.dart';

Widget _wrap(Widget child) =>
    MaterialApp(theme: lightTheme, home: Scaffold(body: child));

void main() {
  group('AppTextField', () {
    testWidgets('renders the label and accepts input', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(_wrap(
        AppTextField(label: 'Server URL', controller: controller),
      ));

      expect(find.text('Server URL'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'komga.test');
      expect(controller.text, 'komga.test');
    });

    testWidgets('label-less variant renders just the field', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(_wrap(
        AppTextField(controller: controller, hint: 'Search', dense: true),
      ));
      expect(find.byType(TextField), findsOneWidget);
    });
  });

  group('AppSegmentedToggle', () {
    testWidgets('selecting a segment reports the value', (tester) async {
      var selected = 'a';
      await tester.pumpWidget(_wrap(
        StatefulBuilder(
          builder: (context, setState) => AppSegmentedToggle<String>(
            segments: const [
              AppSegment('a', 'Alpha'),
              AppSegment('b', 'Beta'),
            ],
            selected: selected,
            onChanged: (v) => setState(() => selected = v),
          ),
        ),
      ));

      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('Beta'), findsOneWidget);

      await tester.tap(find.text('Beta'));
      await tester.pumpAndSettle();
      expect(selected, 'b');
    });

    testWidgets('disabled toggle does not change', (tester) async {
      var selected = 'a';
      await tester.pumpWidget(_wrap(
        AppSegmentedToggle<String>(
          segments: const [
            AppSegment('a', 'Alpha'),
            AppSegment('b', 'Beta'),
          ],
          selected: selected,
          enabled: false,
          onChanged: (v) => selected = v,
        ),
      ));
      await tester.tap(find.text('Beta'));
      await tester.pump();
      expect(selected, 'a');
    });
  });

  group('AppListRow', () {
    testWidgets('renders content and fires onTap', (tester) async {
      var tapped = 0;
      await tester.pumpWidget(_wrap(
        AppListRow(
          icon: Icons.folder,
          title: 'Libraries',
          subtitle: '3 series',
          onTap: () => tapped++,
        ),
      ));
      expect(find.text('Libraries'), findsOneWidget);
      expect(find.text('3 series'), findsOneWidget);

      await tester.tap(find.text('Libraries'));
      await tester.pump();
      expect(tapped, 1);
    });

    testWidgets('disabled row (no onTap) does not fire', (tester) async {
      var tapped = 0;
      await tester.pumpWidget(_wrap(
        AppListRow(title: 'Libraries', onTap: null),
      ));
      await tester.tap(find.text('Libraries'));
      await tester.pump();
      expect(tapped, 0);
    });
  });

  group('AppButton', () {
    testWidgets('outlined kind renders an OutlinedButton', (tester) async {
      await tester.pumpWidget(_wrap(
        AppButton(
          kind: AppButtonKind.outlined,
          label: 'Download',
          icon: Icons.download,
          onPressed: () {},
        ),
      ));
      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.text('Download'), findsOneWidget);
    });
  });
}
