import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/theme/app_icons.dart';
import 'package:mylarium/app/theme/theme_controller.dart';
import 'package:mylarium/app/widgets/ephemeral_storage_banner.dart';

void main() {
  Future<void> pump(WidgetTester tester, {required bool ephemeral}) {
    return tester.pumpWidget(
      ProviderScope(
        overrides: [ephemeralStorageProvider.overrideWithValue(ephemeral)],
        child: const MaterialApp(
          home: Scaffold(body: EphemeralStorageBanner()),
        ),
      ),
    );
  }

  testWidgets('renders nothing when storage is healthy', (tester) async {
    await pump(tester, ephemeral: false);

    expect(find.text('Storage unavailable'), findsNothing);
    expect(find.byIcon(AppIcons.warning), findsNothing);
    // Self-hides to zero height so hosts can include it unconditionally.
    expect(tester.getSize(find.byType(EphemeralStorageBanner)), Size.zero);
  });

  testWidgets('warns when running on the in-memory fallback', (tester) async {
    await pump(tester, ephemeral: true);

    expect(find.text('Storage unavailable'), findsOneWidget);
    expect(find.byIcon(AppIcons.warning), findsOneWidget);
    expect(find.textContaining('memory only'), findsOneWidget);
  });
}
