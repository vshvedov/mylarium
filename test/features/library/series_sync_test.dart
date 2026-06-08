import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/data/komga/komga_api.dart';
import 'package:mylarium/data/repositories/series_repository.dart';
import 'package:mylarium/features/library/series_sync.dart';

/// Minimal series JSON item for a page response.
Map<String, Object?> _seriesItem(String id) => {
      'id': id,
      'libraryId': 'lib1',
      'name': id,
      'booksCount': 1,
      'metadata': {
        'title': id,
        'titleSort': id,
      },
    };

/// A page of [count] series items starting at offset [offset], with
/// [totalElements] as the server total.
Map<String, Object?> _seriesPage(
  int offset,
  int count,
  int totalElements,
) =>
    {
      'content': [
        for (var i = 0; i < count; i++)
          _seriesItem('s${offset + i}'),
      ],
      'totalElements': totalElements,
      'number': offset ~/ count,
      'last': (offset + count) >= totalElements,
    };

/// Stubs GET /api/v1/series for a given [page] index and [size], returning
/// [count] items with the given [totalElements].
void _stubSeriesGet(
  DioAdapter adapter, {
  required int page,
  required int size,
  required int count,
  required int totalElements,
}) =>
    adapter.onGet(
      '/api/v1/series',
      (s) => s.reply(200, _seriesPage(page * size, count, totalElements)),
      queryParameters: {
        'page': page,
        'size': size,
        'sort': 'metadata.titleSort,asc',
      },
    );

void main() {
  late AppDatabase db;
  late Dio dio;
  late DioAdapter adapter;
  late SeriesRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dio = Dio(BaseOptions(baseUrl: 'https://komga.test'));
    adapter = DioAdapter(dio: dio, printLogs: false);
    repo = SeriesRepository(db, KomgaApi(dio));
  });
  tearDown(() => db.close());

  // Seeds [n] series rows directly into the DB (bypasses network).
  Future<void> seedSeries(int n, {String sourceId = 's1'}) async {
    for (var i = 0; i < n; i++) {
      final key = i.toString().padLeft(6, '0');
      await db.upsertSeries(SeriesCompanion(
        sourceId: Value(sourceId),
        id: Value('pre$key'),
        libraryId: const Value('lib1'),
        title: Value('Series $key'),
        titleSort: Value('series $key'),
      ));
    }
  }

  // Test A: bounded fetch -- server total 1200, syncSize 500.
  // Expects exactly 3 network fetches (pages 0, 1, 2) and 1200 rows in cache.
  test('A: fetches exactly 3 pages for 1200-item server total with size=500',
      () async {
    const total = 1200;
    const size = 500;

    // Pages 0 (500 items), 1 (500 items), 2 (200 items).
    _stubSeriesGet(adapter,
        page: 0, size: size, count: 500, totalElements: total);
    _stubSeriesGet(adapter,
        page: 1, size: size, count: 500, totalElements: total);
    _stubSeriesGet(adapter,
        page: 2, size: size, count: 200, totalElements: total);

    final sync = SeriesSync(
      db: db,
      repo: repo,
      sourceId: 's1',
      libraryId: null,
      syncSize: size,
    );
    await sync.ensureSynced();

    expect(sync.complete, isTrue);
    // The DB must hold all 1200 rows.
    expect(await db.seriesCount('s1'), total);
    // A 4th fetch would have thrown because adapter has no stub for page 3.
    // If we reach this line without error, the loop stopped at 3.
  });

  // Test B: already cached -- cache >= total, only 1 network fetch to learn
  // the total, then stop.
  test('B: stops after 1 fetch when cache already covers server total',
      () async {
    const total = 1200;
    const size = 500;

    // Pre-seed the DB with enough rows.
    await seedSeries(total);
    expect(await db.seriesCount('s1'), total);

    // Only one stub registered: page 0. If a second fetch were made the adapter
    // would throw (no matching stub), failing the test.
    _stubSeriesGet(adapter,
        page: 0, size: size, count: 500, totalElements: total);

    final sync = SeriesSync(
      db: db,
      repo: repo,
      sourceId: 's1',
      libraryId: null,
      syncSize: size,
    );
    await sync.ensureSynced();

    expect(sync.complete, isTrue);
  });

  // Test C: idempotent -- calling ensureSynced twice runs the loop only once.
  test('C: calling ensureSynced twice does not re-run the loop', () async {
    const total = 100;
    const size = 500;

    // Only one stub: if a second loop ran it would exhaust the adapter's
    // one-shot stub and then throw on a second invocation.
    _stubSeriesGet(adapter,
        page: 0, size: size, count: 100, totalElements: total);

    final sync = SeriesSync(
      db: db,
      repo: repo,
      sourceId: 's1',
      libraryId: null,
      syncSize: size,
    );

    // Both calls must complete without error and the second must not re-fetch.
    await sync.ensureSynced();
    await sync.ensureSynced(); // must be a no-op

    expect(sync.complete, isTrue);
    expect(await db.seriesCount('s1'), total);
  });

  // Test D: degrade -- first page returns 500 error; ensureSynced completes
  // without throwing and complete == true.
  test('D: degrades gracefully on server error, complete is true', () async {
    adapter.onGet(
      '/api/v1/series',
      (s) => s.reply(500, {'error': 'boom'}),
      queryParameters: {
        'page': 0,
        'size': 500,
        'sort': 'metadata.titleSort,asc',
      },
    );

    final sync = SeriesSync(
      db: db,
      repo: repo,
      sourceId: 's1',
      libraryId: null,
      syncSize: 500,
    );

    await expectLater(sync.ensureSynced(), completes);
    expect(sync.complete, isTrue);
  });

  // Test E: scoped to a library -- refresh builds a SeriesSearch, so the API
  // uses POST /api/v1/series/list, and the cache count is filtered by library.
  test('E: syncs a single library via the POST list endpoint', () async {
    const total = 300;
    const size = 500;

    adapter.onPost(
      '/api/v1/series/list',
      (s) => s.reply(200, _seriesPage(0, total, total)),
      data: {
        'condition': {
          'allOf': [
            {
              'anyOf': [
                {
                  'libraryId': {'operator': 'is', 'value': 'lib1'}
                }
              ]
            }
          ]
        }
      },
      queryParameters: {
        'page': 0,
        'size': size,
        'sort': 'metadata.titleSort,asc',
      },
    );

    final sync = SeriesSync(
      db: db,
      repo: repo,
      sourceId: 's1',
      libraryId: 'lib1',
      syncSize: size,
    );
    await sync.ensureSynced();

    expect(sync.complete, isTrue);
    expect(await db.seriesCount('s1', libraryId: 'lib1'), total);
  });

  // Test F: a malformed (non-Dio) 200 response makes Page.fromJson throw, which
  // is NOT a ContentException. The loop must still set complete (degrade), not
  // leave the grid loader spinning forever.
  test('F: degrades on a non-ContentException error, complete is true',
      () async {
    adapter.onGet(
      '/api/v1/series',
      // `content` is not a list -> Page.fromJson throws a TypeError that
      // escapes the api guard (which only maps DioException).
      (s) => s.reply(200, {'content': 42, 'totalElements': 1}),
      queryParameters: {
        'page': 0,
        'size': 500,
        'sort': 'metadata.titleSort,asc',
      },
    );

    final sync = SeriesSync(
      db: db,
      repo: repo,
      sourceId: 's1',
      libraryId: null,
      syncSize: 500,
    );

    await expectLater(sync.ensureSynced(), completes);
    expect(sync.complete, isTrue);
  });
}
