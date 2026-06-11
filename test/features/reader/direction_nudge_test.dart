import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/theme/theme_controller.dart'
    show appDatabaseProvider;
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/data/source/content_api.dart';
import 'package:mylarium/data/source/models/book_dto.dart';
import 'package:mylarium/data/source/models/page_dto.dart';
import 'package:mylarium/data/source/models/series_dto.dart';
import 'package:mylarium/data/source/source_providers.dart';
import 'package:mylarium/features/offline/offline_cache.dart';
import 'package:mylarium/features/offline/offline_providers.dart';
import 'package:mylarium/features/reader/reader_controller.dart';
import 'package:mylarium/features/reader/reader_models.dart';
import 'package:mylarium/features/reader/widgets/direction_nudge.dart';

/// Online series with a manga signal (Japanese language) and no reading
/// direction, so a fresh open lands left-to-right and the nudge is eligible.
class _MangaApi implements ContentApi {
  @override
  Future<BookDto> getBook(String id) async => BookDto(
        id: id,
        seriesId: 'ser',
        libraryId: 'lib',
        name: id,
        title: 'Title',
        number: '1',
        pagesCount: 3,
        readPage: 0,
      );

  @override
  Future<List<PageDto>> bookPages(String id) async =>
      [for (var i = 1; i <= 3; i++) PageDto(number: i, fileName: 'p$i')];

  @override
  Future<SeriesDto> getSeries(String id) async => SeriesDto(
        id: id,
        libraryId: 'lib',
        name: 'n',
        title: 't',
        titleSort: 't',
        language: 'ja',
      );

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

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

    setUp(() => db = AppDatabase(NativeDatabase.memory()));
    tearDown(() => db.close());

    ProviderContainer container() {
      final c = ProviderContainer(overrides: [
        appDatabaseProvider.overrideWithValue(db),
        offlineCacheManagerProvider.overrideWithValue(OfflineCacheManager(db)),
        contentApiForProvider('s').overrideWith((ref) async => _MangaApi()),
      ]);
      addTearDown(c.dispose);
      return c;
    }

    test('accepting RTL persists settings, so the nudge never returns',
        () async {
      final c = container();
      final before = await c.read(readerControllerProvider('s', 'b').future);
      // Manga-signal series opened LTR with nothing persisted: nudge eligible.
      expect(before.directionUnset, isTrue);

      await c
          .read(readerControllerProvider('s', 'b').notifier)
          .toggleDirection();

      // Cleared in place for this open...
      final after = c.read(readerControllerProvider('s', 'b')).value!;
      expect(after.directionUnset, isFalse);
      expect(after.settings.mode, ReadingMode.pagedRtl);

      // ...and persisted, so a later open (fresh container) stays cleared.
      final reopened =
          await container().read(readerControllerProvider('s', 'b').future);
      expect(reopened.directionUnset, isFalse);
      expect(reopened.settings.mode, ReadingMode.pagedRtl);
    });

    test('dismissing persists the current settings as-is', () async {
      final c = container();
      final before = await c.read(readerControllerProvider('s', 'b').future);
      expect(before.directionUnset, isTrue);
      expect(before.settings.mode, ReadingMode.pagedLtr);

      // The x action: persist the settings unchanged.
      await c
          .read(readerControllerProvider('s', 'b').notifier)
          .updateSettings(before.settings);

      final after = c.read(readerControllerProvider('s', 'b')).value!;
      expect(after.directionUnset, isFalse);
      expect(after.settings.mode, ReadingMode.pagedLtr);

      final reopened =
          await container().read(readerControllerProvider('s', 'b').future);
      expect(reopened.directionUnset, isFalse);
      expect(reopened.settings.mode, ReadingMode.pagedLtr);
    });
  });
}
