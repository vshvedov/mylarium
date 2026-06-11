import 'dart:convert' show jsonEncode;

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/theme/theme_controller.dart'
    show appDatabaseProvider;
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/core/fs/app_paths.dart';
import 'package:mylarium/core/network/content_exception.dart';
import 'package:mylarium/data/source/content_api.dart';
import 'package:mylarium/data/local/local_path_resolver.dart';
import 'package:mylarium/features/reader/reader_controller.dart';
import 'package:mylarium/features/reader/reader_models.dart';
import 'package:mylarium/features/reader/reader_navigation.dart';
import 'package:mylarium/features/sync/sync_engine.dart';

/// A server that is down: every call fails with a transient (retryable) error,
/// so a flushed write-back row stays pending.
class _UnreachableApi implements ContentApi {
  @override
  dynamic noSuchMethod(Invocation invocation) => Future<Never>.error(
        const ContentException(ContentErrorKind.unreachable, 'down'),
      );
}

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.upsertSource(const SourcesCompanion(
      id: Value('loc'),
      kind: Value('local'),
      label: Value('Local files'),
    ));
  });
  tearDown(() => db.close());

  Future<void> seedComic(
    String id, {
    String series = 'Berserk',
    String number = '1',
    double? numberSort = 1.0,
    String direction = 'ltr',
  }) =>
      db.insertLocalComic(LocalComicsCompanion.insert(
        id: id,
        sourceId: 'loc',
        kind: 'localCopy',
        managedPath: Value(AppPaths.localRelativePath('loc', id)),
        series: series,
        seriesSort: series.toLowerCase(),
        number: number,
        numberSort: Value(numberSort),
        title: '$series $number',
        readingDirection: Value(direction),
        pageOrder: jsonEncode(const ['001.jpg', '002.jpg', '003.jpg']),
        pagesCount: 3,
        importedAt: 1700000000000,
      ));

  ProviderContainer container() {
    final c = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
    ]);
    addTearDown(c.dispose);
    return c;
  }

  group('reader controller, local branch', () {
    test('opens a local comic from its archive row (no network)', () async {
      AppPaths.debugOverrideRoot = '/install-a';
      addTearDown(() => AppPaths.debugOverrideRoot = null);
      await seedComic('c1');

      final data =
          await container().read(readerControllerProvider('loc', 'c1').future);

      expect(data.source, isA<OfflinePages>());
      final source = data.source as OfflinePages;
      expect(source.entries, ['001.jpg', '002.jpg', '003.jpg']);
      // The stored path is RELATIVE; the resolved path is under this install's
      // root (the cross-install promise).
      expect(source.archivePath, startsWith('/install-a/'));
      expect(data.seriesId, 'Berserk');
      expect(data.title, 'Berserk 1');
      expect(data.initialPage, 0);
    });

    test('an RTL import opens in RTL paged mode', () async {
      AppPaths.debugOverrideRoot = '/r';
      addTearDown(() => AppPaths.debugOverrideRoot = null);
      await seedComic('c1', direction: 'rtl');

      final data =
          await container().read(readerControllerProvider('loc', 'c1').future);

      expect(data.settings.mode, ReadingMode.pagedRtl);
      expect(data.settings.direction, ReadingDirection.rtl);
    });

    test('directionUnset: local imports never show the first-open RTL nudge',
        () async {
      AppPaths.debugOverrideRoot = '/r';
      addTearDown(() => AppPaths.debugOverrideRoot = null);
      // A local row carries no positive manga signal we can gate the nudge on:
      // 'rtl' (ComicInfo Manga=YesAndRightToLeft) already opens RTL, and 'ltr'
      // is also the no-metadata fallback. So local never nudges either way.
      await seedComic('c1'); // ltr
      await seedComic('c2', series: 'Akira', direction: 'rtl');

      final c = container();
      final ltr = await c.read(readerControllerProvider('loc', 'c1').future);
      final rtl = await c.read(readerControllerProvider('loc', 'c2').future);

      expect(ltr.directionUnset, isFalse);
      expect(rtl.directionUnset, isFalse);
    });

    test('resumes at the saved local page after a simulated relaunch',
        () async {
      AppPaths.debugOverrideRoot = '/install-a';
      addTearDown(() => AppPaths.debugOverrideRoot = null);
      await seedComic('c1');

      // Read to page 2 through the real progress path.
      final engine = SyncEngine(db, (_) async => null, deviceId: 'd');
      await engine.recordProgress('loc', 'c1', 2, false);

      // "Relaunch" (fresh container) on a moved container root (the iOS
      // reinstall case): progress survives and the path re-resolves.
      AppPaths.debugOverrideRoot = '/install-b';
      final data =
          await container().read(readerControllerProvider('loc', 'c1').future);

      expect(data.initialPage, 2);
      expect(
        (data.source as OfflinePages).archivePath,
        startsWith('/install-b/'),
      );
    });
  });

  group('local path resolver', () {
    test('throws for a malformed row with no readable path', () async {
      final resolver = LocalPathResolver();
      await seedComic('c1');
      final row = (await db.getLocalComic('c1'))!;
      final pathless = LocalComic(
        id: row.id,
        sourceId: row.sourceId,
        kind: 'safTree',
        managedPath: null,
        treeDocPath: null,
        series: row.series,
        seriesSort: row.seriesSort,
        number: row.number,
        title: row.title,
        readingDirection: row.readingDirection,
        pageOrder: row.pageOrder,
        pagesCount: row.pagesCount,
        importedAt: row.importedAt,
      );
      expect(resolver.archivePath(pathless), throwsStateError);
    });
  });

  group('local book neighbors', () {
    test('orders by numberSort with unnumbered specials last', () async {
      await seedComic('c1', number: '1', numberSort: 1);
      await seedComic('c2', number: '2', numberSort: 2);
      await seedComic('sp', number: 'Special', numberSort: null);

      final c = container();
      final mid =
          await c.read(bookNeighborsProvider('loc', 'Berserk', 'c2').future);
      expect(mid.prevId, 'c1');
      expect(mid.nextId, 'sp'); // NULL numberSort sorts last, after numbered

      final first =
          await c.read(bookNeighborsProvider('loc', 'Berserk', 'c1').future);
      expect(first.prevId, isNull);
      expect(first.nextId, 'c2');

      final last =
          await c.read(bookNeighborsProvider('loc', 'Berserk', 'sp').future);
      expect(last.prevId, 'c2');
      expect(last.nextId, isNull);
    });

    test('never crosses series', () async {
      await seedComic('c1', series: 'Berserk');
      await seedComic('x1', series: 'Akira');

      final n = await container()
          .read(bookNeighborsProvider('loc', 'Berserk', 'c1').future);
      expect(n.hasPrev, isFalse);
      expect(n.hasNext, isFalse);
    });
  });

  group('no-sync-queue guard', () {
    test('local progress never enqueues a write-back', () async {
      await seedComic('c1');
      final engine = SyncEngine(db, (_) async => null, deviceId: 'd');

      await engine.recordProgress('loc', 'c1', 2, true);

      expect(await db.pendingSync(), isEmpty);
      // The local BookState write itself happened (stats source of truth).
      final state = await db.getBookState('loc', 'c1');
      expect(state?.currentPage, 2);
      expect(state?.status, 'completed');
    });

    test('komga progress does enqueue (guard is kind-scoped, not global)',
        () async {
      await db.upsertSource(const SourcesCompanion(
        id: Value('k'),
        kind: Value('komga'),
        baseUrl: Value('http://x'),
        label: Value('Komga'),
      ));
      // The server is unreachable, so the immediate flush leaves the row
      // pending for the next drain (a null api would DELETE it instead).
      final engine =
          SyncEngine(db, (_) async => _UnreachableApi(), deviceId: 'd');

      await engine.recordProgress('k', 'b1', 2, false);

      expect(await db.pendingSync(), hasLength(1));
    });
  });
}
