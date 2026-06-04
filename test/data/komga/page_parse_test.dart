import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/data/komga/models/page.dart';
import 'package:mylarium/data/komga/models/series_dto.dart';

void main() {
  test('Page.fromJson parses the Spring envelope', () {
    final json = {
      'content': [
        {
          'id': 's1',
          'libraryId': 'lib1',
          'name': 'Akira',
          'metadata': {'title': 'Akira', 'titleSort': 'Akira'},
          'booksCount': 6,
        },
      ],
      'totalElements': 42,
      'totalPages': 5,
      'number': 0,
      'size': 10,
      'numberOfElements': 1,
      'first': true,
      'last': false,
      'empty': false,
    };

    final page = Page.fromJson(json, SeriesDto.fromJson);

    expect(page.content.single.title, 'Akira');
    expect(page.totalElements, 42);
    expect(page.totalPages, 5);
    expect(page.number, 0);
    expect(page.last, isFalse);
    expect(page.first, isTrue);
    expect(page.empty, isFalse);
  });

  test('Page.fromJson distinguishes an empty result from a final page', () {
    final empty = Page.fromJson(
      {'content': [], 'totalElements': 0, 'number': 0, 'last': true},
      SeriesDto.fromJson,
    );
    expect(empty.content, isEmpty);
    expect(empty.empty, isTrue);
    expect(empty.last, isTrue);
  });

  test('SeriesDto leaves an absent ageRating null (never coerced to 0)', () {
    final dto = SeriesDto.fromJson({
      'id': 's1',
      'libraryId': 'lib1',
      'name': 'Untitled',
      'metadata': {'title': 'Untitled', 'titleSort': 'Untitled'},
    });
    expect(dto.ageRating, isNull);
  });
}
