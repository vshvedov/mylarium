import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/data/source/models/series_dto.dart';

SeriesDto series({
  String? language,
  List<String> genres = const [],
  List<String> tags = const [],
}) =>
    SeriesDto(
      id: 's',
      libraryId: 'lib',
      name: 'n',
      title: 't',
      titleSort: 't',
      language: language,
      genres: genres,
      tags: tags,
    );

void main() {
  group('SeriesDto.looksLikeManga', () {
    test('Japanese language is a manga signal', () {
      expect(series(language: 'ja').looksLikeManga, isTrue);
      expect(series(language: 'JA').looksLikeManga, isTrue);
      expect(series(language: 'jpn').looksLikeManga, isTrue);
    });

    test('a manga genre or tag is a signal (case-insensitive, substring)', () {
      expect(series(genres: ['Manga']).looksLikeManga, isTrue);
      expect(series(genres: ['Seinen Manga']).looksLikeManga, isTrue);
      expect(series(tags: ['manga']).looksLikeManga, isTrue);
    });

    test('no Japanese language and no manga genre/tag is not a signal', () {
      expect(series().looksLikeManga, isFalse);
      expect(series(language: 'en').looksLikeManga, isFalse);
      expect(
        series(genres: ['Action', 'Fantasy'], tags: ['shonen']).looksLikeManga,
        isFalse,
      );
    });
  });
}
