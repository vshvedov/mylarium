import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/data/komga/komga_api.dart';
import 'package:mylarium/data/repositories/series_repository.dart';
import 'package:mylarium/features/library/series_grid_controller.dart';

void main() {
  late AppDatabase db;
  late Dio dio;
  late DioAdapter adapter;
  late SeriesRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dio = Dio(BaseOptions(baseUrl: 'https://komga.test'));
    adapter = DioAdapter(dio: dio);
    repo = SeriesRepository(db, KomgaApi(dio));
  });
  tearDown(() => db.close());

  // Seed n rows with zero-padded titleSort so lexical order is deterministic.
  Future<void> seed(int n) async {
    for (var i = 0; i < n; i++) {
      final key = i.toString().padLeft(4, '0');
      await db.upsertSeries(SeriesCompanion(
        sourceId: const Value('s1'),
        id: Value('id$key'),
        libraryId: const Value('lib1'),
        title: Value('Series $key'),
        titleSort: Value('series $key'),
      ));
    }
  }

  test('keyset pages cover every row exactly once, last flips at the end',
      () async {
    await seed(130);
    // The cache is already full; the only network call is the sync-complete
    // probe, which reports the same total (idempotent, empty content).
    adapter.onGet(
      '/api/v1/series',
      (s) => s.reply(200, {'content': [], 'totalElements': 130, 'last': true}),
      queryParameters: {
        'page': 0,
        'size': 50,
        'sort': 'metadata.titleSort,asc',
      },
    );

    final controller = SeriesGridController(
      db: db,
      repo: repo,
      sourceId: 's1',
      includeRestricted: false,
      pageSize: 50,
    );

    final seen = <String>[];
    var cursor = const SeriesCursor.start();
    var guard = 0;
    while (guard++ < 20) {
      final page = await controller.page(cursor);
      seen.addAll(page.content.map((r) => r.id));
      if (page.last) break;
      cursor = SeriesCursor.after(page.content.last);
    }

    expect(seen.length, 130, reason: 'every row returned once');
    expect(seen.toSet().length, 130, reason: 'no duplicates');
    final sorted = [...seen]..sort();
    expect(seen, sorted, reason: 'returned in keyset order');
  });

  test('excludes restricted series unless includeRestricted', () async {
    await db.upsertSeries(const SeriesCompanion(
      sourceId: Value('s1'),
      id: Value('clean'),
      libraryId: Value('lib1'),
      title: Value('Clean'),
      titleSort: Value('clean'),
    ));
    await db.upsertSeries(const SeriesCompanion(
      sourceId: Value('s1'),
      id: Value('adult'),
      libraryId: Value('lib1'),
      title: Value('Adult'),
      titleSort: Value('zzz'),
      ageRating: Value(18),
    ));
    adapter.onGet(
      '/api/v1/series',
      (s) => s.reply(200, {'content': [], 'totalElements': 2, 'last': true}),
      queryParameters: {
        'page': 0,
        'size': 50,
        'sort': 'metadata.titleSort,asc',
      },
    );

    final controller = SeriesGridController(
      db: db,
      repo: repo,
      sourceId: 's1',
      includeRestricted: false,
      pageSize: 50,
    );
    final page = await controller.page(const SeriesCursor.start());
    expect(page.content.map((r) => r.id), ['clean']);
  });
}
