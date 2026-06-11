import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/theme/theme_controller.dart'
    show appDatabaseProvider;
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/data/source/content_api.dart';
import 'package:mylarium/data/source/models/book_dto.dart';
import 'package:mylarium/data/source/models/page_dto.dart';
import 'package:mylarium/data/source/models/series_dto.dart';
import 'package:mylarium/data/source/source_providers.dart';
import 'package:mylarium/features/offline/offline_cache.dart';
import 'package:mylarium/features/offline/offline_providers.dart';
import 'package:mylarium/features/reader/reader_controller.dart';

/// Online source whose series carries configurable manga signals and an
/// (optional) reading direction. The reader's first-open nudge should fire only
/// when the series looks like manga yet opened left-to-right.
class _FakeApi implements ContentApi {
  _FakeApi({this.language, this.genres = const []});

  final String? language;
  final List<String> genres;

  @override
  Future<BookDto> getBook(String id) async => BookDto(
        id: id,
        seriesId: 'ser',
        libraryId: 'lib',
        name: id,
        title: 'Title',
        number: '1',
        pagesCount: 3,
        readPage: 0,
      );

  @override
  Future<List<PageDto>> bookPages(String id) async =>
      [for (var i = 1; i <= 3; i++) PageDto(number: i, fileName: 'p$i')];

  @override
  Future<SeriesDto> getSeries(String id) async => SeriesDto(
        id: id,
        libraryId: 'lib',
        name: 'n',
        title: 't',
        titleSort: 't',
        language: language,
        genres: genres,
      );

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<bool> directionUnsetFor(_FakeApi api) async {
    final c = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
      offlineCacheManagerProvider.overrideWithValue(OfflineCacheManager(db)),
      contentApiForProvider('s').overrideWith((ref) async => api),
    ]);
    addTearDown(c.dispose);
    final data = await c.read(readerControllerProvider('s', 'b').future);
    return data.directionUnset;
  }

  test('online: a manga-signal series opened LTR shows the nudge', () async {
    expect(await directionUnsetFor(_FakeApi(language: 'ja')), isTrue);
  });

  test('online: a manga genre signal shows the nudge', () async {
    expect(await directionUnsetFor(_FakeApi(genres: ['Manga'])), isTrue);
  });

  test('online: a non-manga series never shows the nudge', () async {
    expect(await directionUnsetFor(_FakeApi(language: 'en')), isFalse);
    expect(await directionUnsetFor(_FakeApi()), isFalse);
  });
}
