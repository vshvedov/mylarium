import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/theme/app_theme.dart';
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/features/library/library_browse_controllers.dart';
import 'package:mylarium/features/library/search.dart';

import '../../support/test_scope.dart';

/// A locked library is hidden everywhere: search must not render its library
/// filter chip. (The result grid is independently lock-filtered inside
/// SearchScreen's `_run`.)
void main() {
  testWidgets('a locked library has no filter chip in search', (tester) async {
    final scope = await TestScope.create();
    addTearDown(scope.db.close);
    await scope.db.upsertSource(const SourcesCompanion(
      id: Value('s1'),
      kind: Value('komga'),
      label: Value('T'),
    ));
    // 'Secret' (lib2) is locked; 'Comics' (lib1) is not.
    await scope.db.upsertLibraryPref(const LibraryPrefsCompanion(
      sourceId: Value('s1'),
      libraryId: Value('lib2'),
      locked: Value(true),
    ));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...scope.overrides,
          // The cached library rows, without the network refresh the real
          // provider kicks.
          librariesProvider.overrideWith(
            (ref) => Stream.value(const [
              Library(sourceId: 's1', id: 'lib1', name: 'Comics'),
              Library(sourceId: 's1', id: 'lib2', name: 'Secret'),
            ]),
          ),
          // No server: the referential chip rows render empty.
          genresProvider.overrideWith((ref) async => const []),
          tagsProvider.overrideWith((ref) async => const []),
          publishersProvider.overrideWith((ref) async => const []),
          ageRatingsProvider.overrideWith((ref) async => const []),
        ],
        child: MaterialApp(theme: lightTheme, home: const SearchScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Comics'), findsOneWidget,
        reason: 'the unlocked library keeps its chip');
    expect(find.text('Secret'), findsNothing,
        reason: 'a locked library is hidden everywhere, chips included');

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
}
