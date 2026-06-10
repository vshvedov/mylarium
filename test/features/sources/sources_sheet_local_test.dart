import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/theme/app_theme.dart';
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/data/source/source_providers.dart';
import 'package:mylarium/features/sources/sources_sheet.dart';

import '../../support/test_scope.dart';

void main() {
  // Pump the sheet using a fixed list of sources (no live Drift stream) to
  // avoid the pending-timer failure that a watch() stream produces in tests.
  Future<void> pumpSheet(
    WidgetTester tester,
    TestScope scope,
    List<Source> sources,
  ) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        ...scope.overrides,
        sourcesStreamProvider.overrideWith(
          (ref) => Stream.value(sources),
        ),
      ],
      child: MaterialApp(
        theme: lightTheme,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showSourcesSheet(context),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('offers a Local files entry when no local source exists',
      (tester) async {
    final scope = await TestScope.create();
    addTearDown(scope.db.close);
    // One Komga source; no local source - the sheet should offer Local files.
    final sources = [
      const Source(
        id: 's1',
        kind: 'komga',
        baseUrl: 'http://x',
        label: 'Server',
      ),
    ];

    await pumpSheet(tester, scope, sources);

    expect(find.text('Local files'), findsOneWidget);
  });

  testWidgets('local source row has no delete affordance', (tester) async {
    final scope = await TestScope.create();
    addTearDown(scope.db.close);
    // A local source is already connected; the row must not show a delete icon.
    final sources = [
      const Source(
        id: 'l1',
        kind: 'local',
        baseUrl: null,
        label: 'Local files',
      ),
    ];

    await pumpSheet(tester, scope, sources);

    // The connected local source renders as a row; the trailing delete icon
    // is suppressed for kind == 'local' (deleting it would orphan the whole
    // imported library; managing local books happens per book).
    expect(find.text('Local files'), findsOneWidget);
    expect(find.byTooltip('Remove source'), findsNothing);
  });
}
