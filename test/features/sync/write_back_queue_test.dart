import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/data/komga/komga_api.dart';
import 'package:mylarium/features/sync/write_back_queue.dart';

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

  WriteBackQueue queueFor(KomgaApi? Function(String) f) =>
      WriteBackQueue(db, (sid) async => f(sid));

  Future<void> enqueue(int page, {bool completed = false, int at = 0}) =>
      db.enqueueSync(
        SyncQueueCompanion.insert(
          sourceId: 'src',
          bookId: 'b1',
          page: page,
          queuedAt: at,
          completed: Value(completed),
        ),
      );

  test('enqueue collapses to one pending row per book (latest wins)', () async {
    await enqueue(3, at: 10);
    await enqueue(7, at: 20);
    final pending = await db.pendingSync();
    expect(pending, hasLength(1));
    expect(pending.single.page, 7);
  });

  test(
    'flush PATCHes page+1 (0-based to Komga 1-based) then deletes the row',
    () async {
      await enqueue(7, completed: false);
      adapter.onPatch(
        '/api/v1/books/b1/read-progress',
        (s) => s.reply(204, null),
        data: {'page': 8, 'completed': false},
      );

      await queueFor((_) => api).flush();

      expect(await db.pendingSync(), isEmpty);
    },
  );

  test('a transient 500 keeps the row pending and bumps attempts', () async {
    await enqueue(2);
    adapter.onPatch(
      '/api/v1/books/b1/read-progress',
      (s) => s.reply(500, {'error': 'boom'}),
      data: {'page': 3, 'completed': false},
    );

    await queueFor((_) => api).flush();

    final pending = await db.pendingSync();
    expect(pending, hasLength(1));
    expect(pending.single.attempts, 1);
  });

  test(
    'a permanent 404 dead-letters the row and is dropped from pending',
    () async {
      await enqueue(2);
      adapter.onPatch(
        '/api/v1/books/b1/read-progress',
        (s) => s.reply(404, {'error': 'gone'}),
        data: {'page': 3, 'completed': false},
      );

      await queueFor((_) => api).flush();

      expect(
        await db.pendingSync(),
        isEmpty,
        reason: 'failed rows are not pending',
      );
      final all = await db.select(db.syncQueue).get();
      expect(all.single.state, 'failed');
    },
  );

  test('a missing source (apiFor null) drops the queued row', () async {
    await enqueue(2);
    await queueFor((_) => null).flush();
    expect(await db.select(db.syncQueue).get(), isEmpty);
  });

  // --- T3: op-aware write-back ---------------------------------------------

  Future<void> enqueueOp(String op, {String bookId = 'b1'}) => db.enqueueSync(
        SyncQueueCompanion.insert(
          sourceId: 'src',
          bookId: bookId,
          page: 0,
          queuedAt: 1,
          op: Value(op),
        ),
      );

  test('op=unread DELETEs the book read-progress and deletes the row', () async {
    await enqueueOp('unread');
    adapter.onDelete('/api/v1/books/b1/read-progress', (s) => s.reply(204, null));

    await queueFor((_) => api).flush();

    expect(await db.pendingSync(), isEmpty);
    expect(await db.select(db.syncQueue).get(), isEmpty);
  });

  test('op=unread treats a 404 as success (already absent)', () async {
    await enqueueOp('unread');
    adapter.onDelete(
      '/api/v1/books/b1/read-progress',
      (s) => s.reply(404, {'error': 'gone'}),
    );

    await queueFor((_) => api).flush();

    expect(await db.select(db.syncQueue).get(), isEmpty,
        reason: '404 on a delete is idempotent success, not dead-letter');
  });

  test('op=seriesRead POSTs the series read-progress', () async {
    await enqueueOp('seriesRead', bookId: 'ser1');
    adapter.onPost(
      '/api/v1/series/ser1/read-progress',
      (s) => s.reply(204, null),
    );

    await queueFor((_) => api).flush();

    expect(await db.select(db.syncQueue).get(), isEmpty);
  });

  test('op=seriesUnread DELETEs the series read-progress', () async {
    await enqueueOp('seriesUnread', bookId: 'ser1');
    adapter.onDelete(
      '/api/v1/series/ser1/read-progress',
      (s) => s.reply(204, null),
    );

    await queueFor((_) => api).flush();

    expect(await db.select(db.syncQueue).get(), isEmpty);
  });

  test('an unknown op is dead-lettered without throwing', () async {
    await enqueueOp('teleport');

    await queueFor((_) => api).flush();

    expect(await db.pendingSync(), isEmpty);
    final all = await db.select(db.syncQueue).get();
    expect(all.single.state, 'failed');
  });

  test('a transient failure on one source still drains the others', () async {
    // Source A is down (transient); source B is healthy.
    final dioB = Dio(BaseOptions(baseUrl: 'https://b.test'));
    final adapterB = DioAdapter(dio: dioB);
    final apiB = KomgaApi(dioB);
    adapterB.onPatch(
      '/api/v1/books/bB/read-progress',
      (s) => s.reply(204, null),
      data: {'page': 6, 'completed': false},
    );
    adapter.onPatch(
      '/api/v1/books/bA/read-progress',
      (s) => s.reply(503, {'error': 'down'}),
      data: {'page': 2, 'completed': false},
    );
    await db.enqueueSync(SyncQueueCompanion.insert(
        sourceId: 'A', bookId: 'bA', page: 1, queuedAt: 1));
    await db.enqueueSync(SyncQueueCompanion.insert(
        sourceId: 'B', bookId: 'bB', page: 5, queuedAt: 2));

    await queueFor((sid) => sid == 'A' ? api : apiB).flush();

    final pending = await db.pendingSync();
    expect(pending, hasLength(1), reason: 'B drained, A retained');
    expect(pending.single.sourceId, 'A');
    expect(pending.single.attempts, 1);
  });
}
