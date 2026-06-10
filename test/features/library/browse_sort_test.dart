import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/theme/theme_controller.dart';
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/features/library/library_browse_controllers.dart';
import 'package:mylarium/features/library/series_sync.dart';

void main() {
  group('BrowseSort mapping', () {
    test('only Title Z-A runs the title query descending', () {
      expect(BrowseSort.titleAsc.titleDescending, isFalse);
      expect(BrowseSort.titleDesc.titleDescending, isTrue);
      expect(BrowseSort.mostBooks.titleDescending, isFalse);
    });

    test('only the title sorts are alphabetical (A-Z scrubber)', () {
      expect(BrowseSort.titleAsc.alphabetical, isTrue);
      expect(BrowseSort.titleDesc.alphabetical, isTrue);
      expect(BrowseSort.mostBooks.alphabetical, isFalse);
    });

    test('menu labels', () {
      expect(
        [for (final s in BrowseSort.values) s.label],
        ['Title A-Z', 'Title Z-A', 'Most books'],
      );
    });
  });

  group('browseSortProvider', () {
    test('defaults to Title A-Z, is per source, and outlives listeners', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(browseSortProvider('s1')), BrowseSort.titleAsc);

      // The grid (a listener) sets a sort and is then disposed; the choice
      // must survive for the session (memory-only persistence).
      final sub = container.listen(browseSortProvider('s1'), (_, _) {});
      container.read(browseSortProvider('s1').notifier).state =
          BrowseSort.mostBooks;
      sub.close();

      expect(container.read(browseSortProvider('s1')), BrowseSort.mostBooks);
      // Another source keeps its own default.
      expect(container.read(browseSortProvider('s2')), BrowseSort.titleAsc);
    });
  });

  group('browseSeriesByBooksProvider', () {
    late AppDatabase db;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      await db.upsertSource(const SourcesCompanion(
        id: Value('s1'),
        kind: Value('komga'),
        label: Value('T'),
      ));
    });
    tearDown(() => db.close());

    Future<void> seed(
      String id, {
      required int books,
      String library = 'lib1',
    }) =>
        db.upsertSeries(SeriesCompanion(
          sourceId: const Value('s1'),
          id: Value(id),
          libraryId: Value(library),
          title: Value(id),
          titleSort: Value(id),
          booksCount: Value(books),
        ));

    ProviderContainer container() {
      final c = ProviderContainer(overrides: [
        appDatabaseProvider.overrideWithValue(db),
        // No background sync (and no network): the seeded cache is the data.
        seriesSyncProvider('s1', null).overrideWith((ref) async => null),
        seriesSyncProvider('s1', 'lib1').overrideWith((ref) async => null),
      ]);
      addTearDown(c.dispose);
      return c;
    }

    test('orders by booksCount desc with an alphabetical tie-break', () async {
      await seed('bravo', books: 1);
      await seed('charlie', books: 3);
      await seed('alpha', books: 1);

      final rows = await container().read(
        browseSeriesByBooksProvider((sourceId: 's1', libraryId: null)).future,
      );
      expect(rows.map((r) => r.id), ['charlie', 'alpha', 'bravo']);
    });

    test('scopes to the requested library', () async {
      await seed('inside', books: 2);
      await seed('outside', books: 9, library: 'lib2');

      final rows = await container().read(
        browseSeriesByBooksProvider((sourceId: 's1', libraryId: 'lib1'))
            .future,
      );
      expect(rows.map((r) => r.id), ['inside']);
    });

    test('hides series in a locked library', () async {
      await seed('open', books: 1);
      await seed('hidden', books: 9, library: 'lib2');
      await db.upsertLibraryPref(const LibraryPrefsCompanion(
        sourceId: Value('s1'),
        libraryId: Value('lib2'),
        locked: Value(true),
      ));

      final rows = await container().read(
        browseSeriesByBooksProvider((sourceId: 's1', libraryId: null)).future,
      );
      expect(rows.map((r) => r.id), ['open'],
          reason: 'the locked lib2 library is hidden');
    });

    test('an empty sourceId yields an empty list', () async {
      final rows = await container().read(
        browseSeriesByBooksProvider((sourceId: '', libraryId: null)).future,
      );
      expect(rows, isEmpty);
    });
  });
}
