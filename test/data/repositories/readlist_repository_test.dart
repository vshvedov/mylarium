import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/core/network/komga_exception.dart';
import 'package:mylarium/data/komga/komga_api.dart';
import 'package:mylarium/data/repositories/readlist_repository.dart';

void main() {
  late AppDatabase db;
  late Dio dio;
  late DioAdapter adapter;
  late ReadListRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dio = Dio(BaseOptions(baseUrl: 'https://komga.test'));
    adapter = DioAdapter(dio: dio);
    repo = ReadListRepository(KomgaApi(dio), db, 'src');
  });
  tearDown(() => db.close());

  Future<void> seedCache() async {
    adapter.onGet(
      '/api/v1/readlists',
      (s) => s.reply(200, {
        'content': [
          {'id': 'r1', 'name': 'Pull', 'ordered': false, 'bookIds': ['b1']},
        ],
        'totalElements': 1,
        'number': 0,
        'last': true,
      }),
      queryParameters: {'page': 0, 'size': 200},
    );
    await repo.list();
  }

  Future<List<String>> cachedBookIds(String readListId) async {
    final row = await db.getCachedMetadata('src', 'readlists', 'src');
    final list = (jsonDecode(row!.json) as List).cast<Map<String, Object?>>();
    final r = list.firstWhere((e) => e['id'] == readListId);
    return (r['bookIds'] as List).cast<String>();
  }

  test('removeBook fresh-reads, PATCHes the full list, and rewrites the cache',
      () async {
    await seedCache();
    adapter.onGet(
      '/api/v1/readlists/r1',
      (s) => s.reply(200, {
        'id': 'r1',
        'name': 'Pull',
        'ordered': false,
        'bookIds': ['b1', 'b2'],
      }),
    );
    adapter.onPatch(
      '/api/v1/readlists/r1',
      (s) => s.reply(204, null),
      data: {
        'name': 'Pull',
        'ordered': false,
        'bookIds': ['b1'],
      },
    );

    await repo.removeBook('r1', 'b2');

    expect(await cachedBookIds('r1'), ['b1']);
  });

  test('a failed PATCH reverts the optimistic cache and rethrows', () async {
    await seedCache();
    adapter.onGet(
      '/api/v1/readlists/r1',
      (s) => s.reply(200,
          {'id': 'r1', 'name': 'Pull', 'ordered': false, 'bookIds': ['b1']}),
    );
    adapter.onPatch(
      '/api/v1/readlists/r1',
      (s) => s.reply(500, {'error': 'boom'}),
      data: {
        'name': 'Pull',
        'ordered': false,
        'bookIds': ['b1', 'b2'],
      },
    );

    await expectLater(repo.addBook('r1', 'b2'), throwsA(isA<KomgaException>()));
    expect(await cachedBookIds('r1'), ['b1'], reason: 'cache reverted');
  });
}
