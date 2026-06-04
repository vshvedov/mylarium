import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/data/komga/komga_api.dart';
import 'package:mylarium/data/repositories/series_repository.dart';

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

  Map<String, Object?> seriesPage(List<Map<String, Object?>> content) => {
        'content': content,
        'totalElements': content.length,
        'number': 0,
        'last': true,
      };

  test('refresh maps DTOs to rows with sourceId and upserts them', () async {
    adapter.onGet(
      '/api/v1/series',
      (s) => s.reply(
        200,
        seriesPage([
          {
            'id': 's1',
            'libraryId': 'lib1',
            'name': 'Akira',
            'metadata': {'title': 'Akira', 'titleSort': 'Akira', 'ageRating': 18},
            'booksCount': 6,
          },
          {
            'id': 's2',
            'libraryId': 'lib1',
            'name': 'Berserk',
            'metadata': {'title': 'Berserk', 'titleSort': 'Berserk'},
            'booksCount': 41,
          },
        ]),
      ),
      queryParameters: {'page': 0, 'size': 50},
    );

    final total = await repo.refresh('src-A');
    expect(total, 2);

    final rows = await db.watchSeries('src-A').first;
    expect(rows.map((r) => r.title).toList(), ['Akira', 'Berserk']);
    expect(rows.every((r) => r.sourceId == 'src-A'), isTrue);
    expect(rows.firstWhere((r) => r.id == 's1').ageRating, 18);
    // Absent ageRating stays NULL, never coerced to 0.
    expect(rows.firstWhere((r) => r.id == 's2').ageRating, isNull);
  });

  test('a second refresh upserts (no duplicate {sourceId,id})', () async {
    adapter.onGet(
      '/api/v1/series',
      (s) => s.reply(
        200,
        seriesPage([
          {
            'id': 's1',
            'libraryId': 'lib1',
            'name': 'Old title',
            'metadata': {'title': 'Old title', 'titleSort': 'Old title'},
          },
        ]),
      ),
      queryParameters: {'page': 0, 'size': 50},
    );
    await repo.refresh('src-A');

    // Re-point the adapter to return an updated payload for the same series.
    adapter = DioAdapter(dio: dio);
    adapter.onGet(
      '/api/v1/series',
      (s) => s.reply(
        200,
        seriesPage([
          {
            'id': 's1',
            'libraryId': 'lib1',
            'name': 'New title',
            'metadata': {'title': 'New title', 'titleSort': 'New title'},
          },
        ]),
      ),
      queryParameters: {'page': 0, 'size': 50},
    );
    await repo.refresh('src-A');

    final rows = await db.watchSeries('src-A').first;
    expect(rows.length, 1);
    expect(rows.single.title, 'New title');
  });
}
