import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/theme/app_theme.dart';
import 'package:mylarium/data/source/content_source.dart';
import 'package:mylarium/data/source/models/server_details.dart';
import 'package:mylarium/features/sources/reachability.dart';
import 'package:mylarium/features/sources/server_details.dart';
import 'package:mylarium/features/sources/source_status_button.dart';

void main() {
  testWidgets('tapping the dot opens the server details dialog',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        sourceReachableProvider('s1').overrideWith((ref) async => true),
        serverDetailsProvider('s1').overrideWith(
          (ref) async => const ServerDetails(
            kind: SourceKind.komga,
            label: 'My Server',
            baseUrl: 'https://komga.test',
            online: true,
            facts: ServerFacts(version: '1.21.0'),
          ),
        ),
      ],
      child: MaterialApp(
        theme: lightTheme,
        home: const Scaffold(
          body: Center(child: SourceStatusButton(sourceId: 's1')),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();

    expect(find.text('My Server'), findsOneWidget);
    expect(find.text('1.21.0'), findsOneWidget);
    expect(find.text('Close'), findsOneWidget);
  });
}
