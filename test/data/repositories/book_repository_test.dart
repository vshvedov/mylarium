import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/data/komga/komga_api.dart';
import 'package:mylarium/data/repositories/book_repository.dart';

void main() {
  late AppDatabase db;
  late Dio dio;
  late DioAdapter adapter;
  late BookRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dio = Dio(BaseOptions(baseUrl: 'https://komga.test'));
    adapter = DioAdapter(dio: dio);
    repo = BookRepository(db, KomgaApi(dio));
  });
  tearDown(() => db.close());

  Map<String, Object?> booksPage() => {
        'content': [
          {
            'id': 'b1',
            'seriesId': 'ser1',
            'libraryId': 'lib1',
            'name': 'Volume 1',
            'metadata': {'title': 'Volume 1', 'number': '1'},
            'media': {'pagesCount': 20, 'mediaType': 'application/zip'},
          },
        ],
        'totalElements': 1,
        'number': 0,
        'last': true,
      };

  test('refresh with a seriesId uses the nested series books endpoint',
      () async {
    // Only the nested path is mocked: if the code hit /api/v1/books instead,
    // no mock would match and the request would throw.
    adapter.onGet(
      '/api/v1/series/ser1/books',
      (s) => s.reply(200, booksPage()),
      queryParameters: {'page': 0, 'size': 50},
    );

    final total = await repo.refresh('src-A', seriesId: 'ser1');

    expect(total, 1);
    final rows = await db.select(db.books).get();
    expect(rows.single.id, 'b1');
    expect(rows.single.sourceId, 'src-A');
    expect(rows.single.pagesCount, 20);
  });

  test('refresh without a seriesId uses the flat books endpoint', () async {
    adapter.onGet(
      '/api/v1/books',
      (s) => s.reply(200, booksPage()),
      queryParameters: {'page': 0, 'size': 50},
    );

    final total = await repo.refresh('src-A');

    expect(total, 1);
  });
}
