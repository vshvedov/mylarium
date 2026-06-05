import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/theme/theme_controller.dart' show appDatabaseProvider;
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/core/network/connectivity.dart';
import 'package:mylarium/data/comicvine/comic_vine_api.dart';
import 'package:mylarium/data/comicvine/comic_vine_models.dart';
import 'package:mylarium/data/komga/komga_api.dart';
import 'package:mylarium/data/repositories/series_repository.dart';
import 'package:mylarium/data/source/source_providers.dart';
import 'package:mylarium/features/integrations/comic_vine/comic_vine_providers.dart';

/// A ComicVineApi stand-in that records calls and can simulate a network
/// failure (the way a real Dio request fails when offline).
class _FakeApi extends ComicVineApi {
  _FakeApi() : super(Dio());

  int searchCalls = 0;
  int findIssueCalls = 0;
  bool fail = false;

  @override
  Future<List<CvVolumeMatch>> searchVolumes(String query) async {
    searchCalls++;
    if (fail) throw DioException(requestOptions: RequestOptions());
    return const [CvVolumeMatch(id: 1, name: 'Saga', countOfIssues: 60)];
  }

  @override
  Future<CvVolume> getVolume(int id) async =>
      CvVolume(id: id, name: 'Saga', deck: 'Space opera');

  @override
  Future<CvIssueRef?> findIssue(int volumeId, String issueNumber) async {
    findIssueCalls++;
    return const CvIssueRef(10);
  }

  @override
  Future<CvIssue> getIssue(int id) async => CvIssue(id: id, name: 'Saga #1');
}

/// A SeriesRepository whose [fetchSeries] caches a row, standing in for the real
/// fetch-and-cache path so the volume provider can resolve a not-yet-cached
/// series (the race the fix addresses).
class _FakeSeriesRepo extends SeriesRepository {
  _FakeSeriesRepo(AppDatabase db)
      : _db = db,
        super(db, KomgaApi(Dio()));

  final AppDatabase _db;

  @override
  Future<SeriesRow?> fetchSeries(String sourceId, String seriesId) async {
    await _db.upsertSeries(SeriesCompanion(
      sourceId: Value(sourceId),
      id: Value(seriesId),
      libraryId: const Value('lib'),
      title: const Value('Saga'),
      titleSort: const Value('saga'),
      booksCount: const Value(60),
    ));
    return _db.getSeries(sourceId, seriesId);
  }
}

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.upsertSeries(
      const SeriesCompanion(
        sourceId: Value('s'),
        id: Value('se1'),
        libraryId: Value('lib'),
        title: Value('Saga'),
        titleSort: Value('saga'),
        booksCount: Value(60),
      ),
    );
  });
  tearDown(() => db.close());

  /// A container with connectivity pre-settled, so the family providers build
  /// once (no loading->data transition re-running the future).
  Future<ProviderContainer> container(_FakeApi api, {bool online = true}) async {
    final c = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        comicVineApiProvider.overrideWith((ref) => api),
        isOnlineProvider.overrideWith((ref) => Stream.value(online)),
      ],
    );
    addTearDown(c.dispose);
    await c.read(isOnlineProvider.future);
    return c;
  }

  test('online with no cache fetches, returns data, and writes the cache',
      () async {
    final api = _FakeApi();
    final c = await container(api, online: true);
    final data = await c.read(comicVineVolumeProvider(('s', 'se1')).future);
    expect(data?.matchedId, 1);
    expect(api.searchCalls, 1);
    expect(
      await db.getCachedMetadata('s', 'comicvine.volume', 'se1'),
      isNotNull,
    );
  });

  test('a fresh cache is served without a network call', () async {
    await (await container(_FakeApi(), online: true))
        .read(comicVineVolumeProvider(('s', 'se1')).future);
    final fresh = _FakeApi();
    final c = await container(fresh, online: true);
    final data = await c.read(comicVineVolumeProvider(('s', 'se1')).future);
    expect(data?.matchedId, 1);
    expect(fresh.searchCalls, 0);
  });

  test('offline with a cache serves the cache without a network call',
      () async {
    await (await container(_FakeApi(), online: true))
        .read(comicVineVolumeProvider(('s', 'se1')).future);
    final fresh = _FakeApi();
    final c = await container(fresh, online: false);
    final data = await c.read(comicVineVolumeProvider(('s', 'se1')).future);
    expect(data?.matchedId, 1);
    expect(fresh.searchCalls, 0);
  });

  test('offline with no cache and a failed fetch throws ComicVineOffline',
      () async {
    final api = _FakeApi()..fail = true;
    final c = await container(api, online: false);
    await expectLater(
      c.read(comicVineVolumeProvider(('s', 'se1')).future),
      throwsA(isA<ComicVineOffline>()),
    );
  });

  test('matches a series that is NOT pre-cached by fetching it (race fix)',
      () async {
    // A fresh db with NO series row: reproduces a detail opened from a home rail
    // / a fresh install, where the row is not cached when the CV provider runs.
    final freshDb = AppDatabase(NativeDatabase.memory());
    addTearDown(freshDb.close);
    final api = _FakeApi();
    final c = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(freshDb),
        comicVineApiProvider.overrideWith((ref) => api),
        isOnlineProvider.overrideWith((ref) => Stream.value(true)),
        seriesRepositoryProvider.overrideWith(
          (ref) async => _FakeSeriesRepo(freshDb),
        ),
      ],
    );
    addTearDown(c.dispose);
    await c.read(isOnlineProvider.future);

    final data = await c.read(comicVineVolumeProvider(('s', 'se1')).future);

    // Before the fix this returned null (db.getSeries was null -> bail) and
    // searchVolumes was never called.
    expect(data?.matchedId, 1, reason: 'matched despite no pre-cached row');
    expect(api.searchCalls, 1);
    expect(
      await freshDb.getCachedMetadata('s', 'comicvine.volume', 'se1'),
      isNotNull,
    );
  });

  test('a non-numeric issue number short-circuits with no issue lookup',
      () async {
    await db.upsertBook(
      const BooksCompanion(
        sourceId: Value('s'),
        id: Value('bk1'),
        seriesId: Value('se1'),
        libraryId: Value('lib'),
        title: Value('Special'),
        number: Value('Special'),
      ),
    );
    final api = _FakeApi();
    final c = await container(api, online: true);
    final data = await c.read(comicVineIssueProvider(('s', 'bk1')).future);
    expect(data, isNull);
    expect(api.findIssueCalls, 0);
    expect(
      await db.getCachedMetadata('s', 'comicvine.issue', 'bk1'),
      isNotNull,
    );
  });
}
