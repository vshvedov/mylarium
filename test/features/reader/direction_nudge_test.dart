import 'dart:convert' show jsonEncode;

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/theme/theme_controller.dart'
    show appDatabaseProvider;
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/core/fs/app_paths.dart';
import 'package:mylarium/features/reader/reader_controller.dart';
import 'package:mylarium/features/reader/reader_models.dart';
import 'package:mylarium/features/reader/widgets/direction_nudge.dart';

void main() {
  group('DirectionNudge pill', () {
    Future<void> pump(
      WidgetTester tester, {
      required VoidCallback onRightToLeft,
      required VoidCallback onDismiss,
    }) =>
        tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: Center(
              child: DirectionNudge(
                onRightToLeft: onRightToLeft,
                onDismiss: onDismiss,
              ),
            ),
          ),
        ));

    testWidgets('shows the prompt and routes both actions', (tester) async {
      var rtlTaps = 0;
      var dismissTaps = 0;
      await pump(
        tester,
        onRightToLeft: () => rtlTaps++,
        onDismiss: () => dismissTaps++,
      );

      expect(find.text('Reading manga? Try right-to-left'), findsOneWidget);

      await tester.tap(find.text('Right-to-left'));
      expect(rtlTaps, 1);
      expect(dismissTaps, 0);

      await tester.tap(find.byTooltip('Dismiss'));
      expect(rtlTaps, 1);
      expect(dismissTaps, 1);
    });

    testWidgets('both actions meet the 44px touch target', (tester) async {
      await pump(tester, onRightToLeft: () {}, onDismiss: () {});
      final action = tester.getSize(find.byType(TextButton));
      expect(action.height, greaterThanOrEqualTo(44));
      expect(action.width, greaterThanOrEqualTo(44));
      final close = tester.getSize(find.byType(IconButton));
      expect(close.height, greaterThanOrEqualTo(44));
      expect(close.width, greaterThanOrEqualTo(44));
    });
  });

  group('direction nudge persistence (controller)', () {
    late AppDatabase db;

    setUp(() async {
      AppPaths.debugOverrideRoot = '/r';
      db = AppDatabase(NativeDatabase.memory());
      await db.upsertSource(const SourcesCompanion(
        id: Value('loc'),
        kind: Value('local'),
        label: Value('Local files'),
      ));
      await db.insertLocalComic(LocalComicsCompanion.insert(
        id: 'c1',
        sourceId: 'loc',
        kind: 'localCopy',
        managedPath: Value(AppPaths.localRelativePath('loc', 'c1')),
        series: 'Berserk',
        seriesSort: 'berserk',
        number: '1',
        numberSort: const Value(1.0),
        title: 'Berserk 1',
        readingDirection: const Value('ltr'),
        pageOrder: jsonEncode(const ['001.jpg', '002.jpg']),
        pagesCount: 2,
        importedAt: 1700000000000,
      ));
    });
    tearDown(() async {
      AppPaths.debugOverrideRoot = null;
      await db.close();
    });

    ProviderContainer container() {
      final c = ProviderContainer(overrides: [
        appDatabaseProvider.overrideWithValue(db),
      ]);
      addTearDown(c.dispose);
      return c;
    }

    test('accepting RTL persists settings, so the nudge never returns',
        () async {
      final c = container();
      final before =
          await c.read(readerControllerProvider('loc', 'c1').future);
      expect(before.directionUnset, isTrue);

      await c
          .read(readerControllerProvider('loc', 'c1').notifier)
          .toggleDirection();

      // Cleared in place for this open...
      final after = c.read(readerControllerProvider('loc', 'c1')).value!;
      expect(after.directionUnset, isFalse);
      expect(after.settings.mode, ReadingMode.pagedRtl);

      // ...and persisted, so a later open (fresh container) stays cleared.
      final reopened = await container()
          .read(readerControllerProvider('loc', 'c1').future);
      expect(reopened.directionUnset, isFalse);
      expect(reopened.settings.mode, ReadingMode.pagedRtl);
    });

    test('dismissing persists the current settings as-is', () async {
      final c = container();
      final before =
          await c.read(readerControllerProvider('loc', 'c1').future);
      expect(before.directionUnset, isTrue);
      expect(before.settings.mode, ReadingMode.pagedLtr);

      // The x action: persist the settings unchanged.
      await c
          .read(readerControllerProvider('loc', 'c1').notifier)
          .updateSettings(before.settings);

      final after = c.read(readerControllerProvider('loc', 'c1')).value!;
      expect(after.directionUnset, isFalse);
      expect(after.settings.mode, ReadingMode.pagedLtr);

      final reopened = await container()
          .read(readerControllerProvider('loc', 'c1').future);
      expect(reopened.directionUnset, isFalse);
      expect(reopened.settings.mode, ReadingMode.pagedLtr);
    });
  });
}
