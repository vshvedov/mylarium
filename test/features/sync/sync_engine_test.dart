import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/data/komga/komga_api.dart';
import 'package:mylarium/features/sync/sync_engine.dart';

void main() {
  late AppDatabase db;
  late Dio dio;
  late DioAdapter adapter;
  late KomgaApi api;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dio = Dio(BaseOptions(baseUrl: 'https://komga.test'));
    adapter = DioAdapter(dio: dio);
    api = KomgaApi(dio);
  });
  tearDown(() => db.close());

  SyncEngine engine() =>
      SyncEngine(db, (_) async => api, deviceId: 'dev', now: () => 1000);

  Future<void> addSource(String kind) => db.upsertSource(
    SourcesCompanion(
      id: const Value('src'),
      kind: Value(kind),
      label: const Value('S'),
    ),
  );

  test(
    'a local source records progress but never enqueues a write-back',
    () async {
      await addSource('localCopy');

      await engine().recordProgress('src', 'b1', 12, false);

      final state = await db.getBookState('src', 'b1');
      expect(state!.currentPage, 12);
      expect(state.status, 'reading');
      expect(await db.pendingSync(), isEmpty, reason: 'local stays on device');
    },
  );

  test('a komga source records progress and flushes the write-back', () async {
    await addSource('komga');
    adapter.onPatch(
      '/api/v1/books/b1/read-progress',
      (s) => s.reply(204, null),
      data: {'page': 13, 'completed': false},
    );

    await engine().recordProgress('src', 'b1', 12, false);

    expect((await db.getBookState('src', 'b1'))!.currentPage, 12);
    expect(await db.pendingSync(), isEmpty, reason: 'flushed on success');
  });

  test('a komga write-back that fails offline stays queued', () async {
    await addSource('komga');
    adapter.onPatch(
      '/api/v1/books/b1/read-progress',
      (s) => s.throws(
        -1,
        DioException.connectionError(
          requestOptions: RequestOptions(
            path: '/api/v1/books/b1/read-progress',
          ),
          reason: 'offline',
        ),
      ),
      data: {'page': 6, 'completed': false},
    );

    await engine().recordProgress('src', 'b1', 5, false);

    expect(
      (await db.getBookState('src', 'b1'))!.currentPage,
      5,
      reason: 'position is durable even offline',
    );
    final pending = await db.pendingSync();
    expect(pending, hasLength(1));
    expect(pending.single.page, 5);
  });

  test(
    'progress never rewinds: a lower page leaves currentPage unchanged',
    () async {
      await addSource('localCopy');
      final e = engine();
      await e.recordProgress('src', 'b1', 40, false);
      await e.recordProgress('src', 'b1', 5, false);
      expect((await db.getBookState('src', 'b1'))!.currentPage, 40);
    },
  );
}
