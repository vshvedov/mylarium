import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/theme/app_theme.dart';
import 'package:mylarium/data/source/content_source.dart';
import 'package:mylarium/data/source/models/server_details.dart';
import 'package:mylarium/features/sources/server_details.dart';
import 'package:mylarium/features/sources/server_details_dialog.dart';

void main() {
  Widget host(Override override) => ProviderScope(
        overrides: [override],
        child: MaterialApp(
          theme: lightTheme,
          home: const Scaffold(
            body: ServerDetailsDialog(sourceId: 's1'),
          ),
        ),
      );

  testWidgets('online: renders sections, counts, and actions', (tester) async {
    await tester.pumpWidget(host(
      serverDetailsProvider('s1').overrideWith(
        (ref) async => const ServerDetails(
          kind: SourceKind.komga,
          label: 'My Server',
          baseUrl: 'https://komga.test',
          online: true,
          facts: ServerFacts(
            version: '1.21.0',
            account: 'test@test.local',
            roles: {'ADMIN'},
            libraryNames: ['Manga', 'Comics'],
            totalSeries: 1204,
            totalBooks: 18732,
            extra: [(label: 'Disk', value: '500 GB free / 1000 GB')],
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('My Server'), findsOneWidget);
    expect(find.text('Online'), findsOneWidget);
    expect(find.text('1.21.0'), findsOneWidget);
    expect(find.text('test@test.local'), findsOneWidget);
    expect(find.text('1204'), findsOneWidget);
    expect(find.textContaining('500 GB free'), findsOneWidget);
    expect(find.text('Refresh'), findsOneWidget);
    expect(find.text('Close'), findsOneWidget);
  });

  testWidgets('offline: shows URL, Offline pill, retry copy, no version',
      (tester) async {
    await tester.pumpWidget(host(
      serverDetailsProvider('s1').overrideWith(
        (ref) async => const ServerDetails(
          kind: SourceKind.komga,
          label: 'My Server',
          baseUrl: 'https://komga.test',
          online: false,
          facts: ServerFacts.empty,
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Offline'), findsOneWidget);
    expect(find.text('https://komga.test'), findsOneWidget);
    expect(find.textContaining('unreachable'), findsOneWidget);
    expect(find.text('1.21.0'), findsNothing);
    expect(find.text('Refresh'), findsOneWidget);
  });
}
