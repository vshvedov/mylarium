import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/data/local/import_service.dart';
import 'package:mylarium/features/sources/local/import_results_sheet.dart';

void main() {
  testWidgets('lists per-file outcomes with reasons', (tester) async {
    const result = ImportResult([
      FileImportResult('good.cbz', ImportOutcome.imported, comicId: 'c1'),
      FileImportResult('twice.cbz', ImportOutcome.duplicate,
          reason: 'Already imported', comicId: 'c0'),
      FileImportResult('fake.cbz', ImportOutcome.notAnArchive,
          reason: 'Not a comic archive'),
      FileImportResult('broken.cbz', ImportOutcome.malformed,
          reason: 'No image entries in archive'),
    ]);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: ImportResultsList(result: result)),
    ));

    expect(find.text('1 imported'), findsOneWidget);
    expect(find.text('good.cbz'), findsOneWidget);
    expect(find.text('twice.cbz'), findsOneWidget);
    expect(find.text('Already imported'), findsOneWidget);
    expect(find.text('Not a comic archive'), findsOneWidget);
    expect(find.text('No image entries in archive'), findsOneWidget);
  });

  testWidgets('all-imported batch shows no skip section', (tester) async {
    const result = ImportResult([
      FileImportResult('a.cbz', ImportOutcome.imported, comicId: 'c1'),
      FileImportResult('b.cbz', ImportOutcome.imported, comicId: 'c2'),
    ]);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: ImportResultsList(result: result)),
    ));
    expect(find.text('2 imported'), findsOneWidget);
    expect(find.text('Skipped'), findsNothing);
  });
}
