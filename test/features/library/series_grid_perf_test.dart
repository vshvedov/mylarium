import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/core/db/database.dart';

/// Proxy for the PRD's ">55fps scrolling 50k series" target. The browse grid now
/// loads the whole sorted series list for a source via [watchSeriesSorted]; the
/// `(titleSort, id)` keyset index backs the ORDER BY, so even materialising 50k
/// rows is fast. A missing index would sort 50k rows on every emission and blow
/// this budget. Pure SQLite timing (no rendering); the real frame target is
/// verified manually on device.
void main() {
  test('watchSeriesSorted over 50k series stays well under budget', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    const total = 50000;

    // Bulk-insert 50k rows in one transaction for a fast setup.
    await db.batch((b) {
      for (var i = 0; i < total; i++) {
        final key = i.toString().padLeft(6, '0');
        b.insert(
          db.series,
          SeriesCompanion(
            sourceId: const Value('s1'),
            id: Value('id$key'),
            libraryId: const Value('lib1'),
            title: Value('Series $key'),
            titleSort: Value('series $key'),
          ),
        );
      }
    });

    // A single full sorted load (what the grid does on open). Using total wall
    // time keeps the proxy robust to CI jitter.
    final sw = Stopwatch()..start();
    final rows = await db.watchSeriesSorted('s1').first;
    sw.stop();

    expect(rows.length, total);
    // Ordered ascending by titleSort (index-backed).
    expect(rows.first.id, 'id000000');
    expect(rows.last.id, 'id049999');
    expect(sw.elapsedMilliseconds, lessThan(2000),
        reason: 'full sorted load took ${sw.elapsedMilliseconds}ms '
            '(index-backed expected; a missing index would be far slower)');
  });
}
