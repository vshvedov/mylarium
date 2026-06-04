import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/features/library/series_grid_controller.dart';

/// Proxy for the PRD's ">55fps scrolling 50k series" target: a missing keyset
/// index would full-scan 50k rows and blow this budget. Pure SQLite timing
/// (no rendering); the real frame target is verified manually on device.
void main() {
  test('keyset pages over 50k series stay well under budget', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    const total = 50000;
    const pageSize = 60;

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

    var cursor = const SeriesCursor.start();
    var pages = 0;
    var maxMs = 0;
    var seen = 0;
    while (true) {
      final sw = Stopwatch()..start();
      final rows = await db.seriesPage(
        sourceId: 's1',
        afterTitleSort: cursor.titleSort,
        afterId: cursor.id,
        limit: pageSize,
        includeRestricted: false,
      );
      sw.stop();
      maxMs = sw.elapsedMilliseconds > maxMs ? sw.elapsedMilliseconds : maxMs;
      if (rows.isEmpty) break;
      seen += rows.length;
      cursor = SeriesCursor.after(rows.last);
      pages++;
      if (rows.length < pageSize) break;
    }

    expect(seen, total);
    expect(pages, (total / pageSize).ceil());
    expect(maxMs, lessThan(50),
        reason: 'slowest keyset page took ${maxMs}ms (index-backed expected)');
  });
}
