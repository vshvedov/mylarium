import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/features/stats/stats_models.dart';
import 'package:mylarium/features/stats/stats_repository.dart';

void main() {
  late AppDatabase db;
  late StatsRepository stats;

  final day1 = DateTime(2026, 6, 1, 10);
  final day1b = DateTime(2026, 6, 1, 12);
  final day2 = DateTime(2026, 6, 2, 9);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    stats = StatsRepository(db);

    await db.upsertBook(
      BooksCompanion.insert(
        sourceId: 'A',
        id: 'b1',
        seriesId: 'serA',
        libraryId: 'lib',
        title: 'Akira 1',
        number: '1',
        mediaType: const Value('application/zip'), // CBZ
      ),
    );
    await db.upsertBook(
      BooksCompanion.insert(
        sourceId: 'B',
        id: 'b2',
        seriesId: 'serB',
        libraryId: 'lib',
        title: 'Berserk 1',
        number: '1',
        mediaType: const Value('application/x-rar-compressed'), // CBR
      ),
    );
    await db.upsertSeries(
      SeriesCompanion.insert(
        sourceId: 'A',
        id: 'serA',
        libraryId: 'lib',
        title: 'Akira',
        titleSort: 'akira',
      ),
    );
    await db.upsertSeries(
      SeriesCompanion.insert(
        sourceId: 'B',
        id: 'serB',
        libraryId: 'lib',
        title: 'Berserk',
        titleSort: 'berserk',
      ),
    );
    await db.upsertSeriesMeta(
      SeriesMetaCompanion.insert(
        sourceId: 'A',
        seriesId: 'serA',
        publisher: const Value('Kodansha'),
        genres: Value(jsonEncode(['Action', 'Sci-Fi'])),
      ),
    );
    await db.upsertSeriesMeta(
      SeriesMetaCompanion.insert(
        sourceId: 'B',
        seriesId: 'serB',
        publisher: const Value('Hakusensha'),
        genres: Value(jsonEncode(['Action', 'Fantasy'])),
      ),
    );

    Future<void> session(
      String id,
      String src,
      String book,
      String series,
      DateTime at,
      int pages,
      int seconds, {
      bool completion = false,
      String device = 'dev',
    }) => db.insertReadingSession(
      ReadingSessionsCompanion.insert(
        id: id,
        sourceId: src,
        bookId: book,
        seriesId: series,
        startedAt: at.millisecondsSinceEpoch,
        endedAt: at.millisecondsSinceEpoch + seconds * 1000,
        activeSeconds: seconds,
        startPage: 0,
        endPage: pages,
        pagesRead: pages,
        isCompletion: Value(completion),
        deviceId: device,
      ),
    );

    await session('s1', 'A', 'b1', 'serA', day1, 20, 600);
    await session('s2', 'B', 'b2', 'serB', day1b, 10, 300, completion: true);
    // An off-device (reconciled) read: counts pages, excluded from time.
    await session('s3', 'A', 'b1', 'serA', day2, 15, 0, device: 'remote');
  });
  tearDown(() => db.close());

  final range = DateRange(DateTime(2026, 6, 1), DateTime(2026, 6, 3));

  Breakdown row(List<Breakdown> b, String key) =>
      b.firstWhere((x) => x.key == key);

  test('rolls up totals across two sources', () async {
    final s = await stats.summary(range);
    expect(s.totalPages, 45); // 20 + 10 + 15
    expect(s.totalSeconds, 900, reason: 'remote session time excluded');
    expect(s.sessionCount, 3);
    expect(s.booksCompleted, 1);
    expect(s.avgSecondsPerSession, 450, reason: '900 / 2 measured sessions');
  });

  test('byFormat is a partition that sums to total pages', () async {
    final s = await stats.summary(range);
    expect(row(s.byFormat, 'CBZ').pages, 35); // b1: 20 + 15
    expect(row(s.byFormat, 'CBR').pages, 10);
    final sum = s.byFormat.fold<int>(0, (a, b) => a + b.pages);
    expect(sum, s.totalPages);
  });

  test('byGenre is tag-overlap and can exceed total pages', () async {
    final s = await stats.summary(range);
    expect(row(s.byGenre, 'Action').pages, 45); // serA 35 + serB 10
    expect(row(s.byGenre, 'Sci-Fi').pages, 35);
    expect(row(s.byGenre, 'Fantasy').pages, 10);
    final sum = s.byGenre.fold<int>(0, (a, b) => a + b.pages);
    expect(sum, greaterThan(s.totalPages));
  });

  test('byPublisher and bySeries roll up correctly', () async {
    final s = await stats.summary(range);
    expect(row(s.byPublisher, 'Kodansha').pages, 35);
    expect(row(s.byPublisher, 'Hakusensha').pages, 10);
    expect(row(s.bySeries, 'Akira').pages, 35);
    expect(row(s.bySeries, 'Berserk').pages, 10);
  });

  test(
    'streak counts consecutive local days, heatmap buckets by day',
    () async {
      final s = await stats.summary(range);
      expect(s.streakDays, 2); // June 1 and June 2
      expect(s.heatmap[DateTime(2026, 6, 1)], 30); // 20 + 10
      expect(s.heatmap[DateTime(2026, 6, 2)], 15);
    },
  );

  test('comparison period is computed when provided', () async {
    final prior = DateRange(DateTime(2026, 5, 1), DateTime(2026, 6, 1));
    final s = await stats.summary(range, comparison: prior);
    expect(s.comparison, isNotNull);
    expect(s.comparison!.totalPages, 0);
  });

  test('empty range yields the empty summary shape', () async {
    final s = await stats.summary(
      DateRange(DateTime(2025, 1, 1), DateTime(2025, 2, 1)),
    );
    expect(s.isEmpty, isTrue);
    expect(s.streakDays, 0);
  });
}
