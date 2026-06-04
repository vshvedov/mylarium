import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/data/komga/komga_api.dart';
import 'package:mylarium/features/sync/reconciler.dart';
import 'package:mylarium/features/sync/sync_models.dart';

void main() {
  late AppDatabase db;
  late Dio dio;
  late DioAdapter adapter;
  late KomgaApi api;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    dio = Dio(BaseOptions(baseUrl: 'https://komga.test'));
    adapter = DioAdapter(dio: dio);
    api = KomgaApi(dio);
    await db.upsertSource(
      const SourcesCompanion(
        id: Value('src'),
        kind: Value('komga'),
        label: Value('Komga'),
      ),
    );
  });
  tearDown(() => db.close());

  Future<void> seedState(int page, {String status = 'reading', int? remote}) =>
      db.upsertBookState(
        BookStateCompanion(
          sourceId: const Value('src'),
          bookId: const Value('b1'),
          status: Value(status),
          currentPage: Value(page),
          updatedAt: const Value(100),
          remoteUpdatedAt: Value(remote),
        ),
      );

  Map<String, Object?> bookJson({
    required int page,
    bool completed = false,
    String? readDate = '2026-06-01T10:00:00Z',
    String? lastModified = '2026-06-01T10:00:00Z',
  }) => {
    'id': 'b1',
    'seriesId': 'ser1',
    'libraryId': 'lib1',
    'name': 'V1',
    'metadata': {'title': 'V1', 'number': '1'},
    'media': {'pagesCount': 100, 'mediaType': 'application/zip'},
    'readProgress': {
      'page': page,
      'completed': completed,
      'readDate': ?readDate,
      'lastModified': ?lastModified,
    },
  };

  Reconciler reconciler() => Reconciler(
    db,
    (_) async => api,
    deviceId: 'local-device',
    now: () => 999999,
  );

  test(
    'a further server read advances local state and synthesizes a session',
    () async {
      await seedState(10);
      adapter.onGet(
        '/api/v1/books/b1',
        (s) => s.reply(200, bookJson(page: 50)),
      );

      await reconciler().reconcile();

      final state = await db.getBookState('src', 'b1');
      expect(state!.currentPage, 49, reason: '1-based 50 -> 0-based 49');
      expect(state.remoteUpdatedAt, isNotNull);

      final sessions = await db.allReadingSessions();
      expect(sessions, hasLength(1));
      final session = sessions.single;
      expect(session.deviceId, kRemoteDeviceId);
      expect(session.startPage, 10);
      expect(session.endPage, 49);
      expect(session.pagesRead, 39);
      expect(session.activeSeconds, 0);
    },
  );

  test('an unchanged server (lastModified <= baseline) is skipped', () async {
    final baseline = DateTime.parse(
      '2026-06-05T00:00:00Z',
    ).millisecondsSinceEpoch;
    await seedState(10, remote: baseline);
    adapter.onGet(
      '/api/v1/books/b1',
      (s) => s.reply(
        200,
        bookJson(page: 80, lastModified: '2026-06-01T10:00:00Z'),
      ),
    );

    await reconciler().reconcile();

    expect((await db.getBookState('src', 'b1'))!.currentPage, 10);
    expect(await db.allReadingSessions(), isEmpty);
  });

  test(
    'local already further than server does not rewind nor synthesize',
    () async {
      await seedState(80);
      adapter.onGet(
        '/api/v1/books/b1',
        (s) => s.reply(200, bookJson(page: 10)),
      );

      await reconciler().reconcile();

      expect((await db.getBookState('src', 'b1'))!.currentPage, 80);
      expect(await db.allReadingSessions(), isEmpty);
    },
  );

  test(
    'a server book with no read progress just advances the baseline',
    () async {
      await seedState(10);
      adapter.onGet(
        '/api/v1/books/b1',
        (s) => s.reply(200, {
          'id': 'b1',
          'seriesId': 'ser1',
          'libraryId': 'lib1',
          'name': 'V1',
          'metadata': {'title': 'V1', 'number': '1'},
          'media': {'pagesCount': 100},
        }),
      );

      await reconciler().reconcile();

      final state = await db.getBookState('src', 'b1');
      expect(state!.currentPage, 10);
      // Rotation clock advances (device); the server freshness baseline stays a
      // server value (null here, since the server has no progress).
      expect(state.reconciledAt, 999999);
      expect(state.remoteUpdatedAt, isNull);
      expect(await db.allReadingSessions(), isEmpty);
    },
  );
}
