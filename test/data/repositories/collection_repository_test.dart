import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/core/network/komga_exception.dart';
import 'package:mylarium/data/komga/komga_api.dart';
import 'package:mylarium/data/repositories/collection_repository.dart';

void main() {
  late AppDatabase db;
  late Dio dio;
  late DioAdapter adapter;
  late CollectionRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dio = Dio(BaseOptions(baseUrl: 'https://komga.test'));
    adapter = DioAdapter(dio: dio);
    repo = CollectionRepository(KomgaApi(dio), db, 'src');
  });
  tearDown(() => db.close());

  // Seeds the per-source cache with one collection c1 holding [s1].
  Future<void> seedCache() async {
    adapter.onGet(
      '/api/v1/collections',
      (s) => s.reply(200, {
        'content': [
          {'id': 'c1', 'name': 'Faves', 'ordered': false, 'seriesIds': ['s1']},
        ],
        'totalElements': 1,
        'number': 0,
        'last': true,
      }),
      queryParameters: {'page': 0, 'size': 200},
    );
    await repo.list();
  }

  Future<List<String>> cachedSeriesIds(String collectionId) async {
    final row = await db.getCachedMetadata('src', 'collections', 'src');
    final list = (jsonDecode(row!.json) as List).cast<Map<String, Object?>>();
    final c = list.firstWhere((e) => e['id'] == collectionId);
    return (c['seriesIds'] as List).cast<String>();
  }

  test('addSeries fresh-reads, PATCHes the full list, and rewrites the cache',
      () async {
    await seedCache();
    adapter.onGet(
      '/api/v1/collections/c1',
      (s) => s.reply(200,
          {'id': 'c1', 'name': 'Faves', 'ordered': false, 'seriesIds': ['s1']}),
    );
    adapter.onPatch(
      '/api/v1/collections/c1',
      (s) => s.reply(204, null),
      data: {
        'name': 'Faves',
        'ordered': false,
        'seriesIds': ['s1', 's2'],
      },
    );

    await repo.addSeries('c1', 's2');

    expect(await cachedSeriesIds('c1'), ['s1', 's2']);
  });

  test('a failed PATCH reverts the optimistic cache and rethrows', () async {
    await seedCache();
    adapter.onGet(
      '/api/v1/collections/c1',
      (s) => s.reply(200,
          {'id': 'c1', 'name': 'Faves', 'ordered': false, 'seriesIds': ['s1']}),
    );
    adapter.onPatch(
      '/api/v1/collections/c1',
      (s) => s.reply(403, {'error': 'denied'}),
      data: {
        'name': 'Faves',
        'ordered': false,
        'seriesIds': ['s1', 's2'],
      },
    );

    await expectLater(repo.addSeries('c1', 's2'), throwsA(isA<KomgaException>()));
    expect(await cachedSeriesIds('c1'), ['s1'], reason: 'cache reverted');
  });
}
