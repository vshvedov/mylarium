import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/data/komga/models/series_search.dart';

void main() {
  test('full text is carried as the query value, not the body', () {
    const search = SeriesSearch(fullText: 'akira');
    expect(search.fullTextSearch, 'akira');
    expect(search.toRequestBody(), isEmpty);
  });

  test('empty full text yields a null query value', () {
    expect(const SeriesSearch(fullText: '').fullTextSearch, isNull);
    expect(const SeriesSearch().fullTextSearch, isNull);
  });

  test('filters serialize into an allOf of anyOf condition groups', () {
    const search = SeriesSearch(
      libraryIds: ['libA', 'libB'],
      readStatus: ['UNREAD'],
    );

    final body = search.toRequestBody();

    expect(body, {
      'condition': {
        'allOf': [
          {
            'anyOf': [
              {
                'libraryId': {'operator': 'is', 'value': 'libA'}
              },
              {
                'libraryId': {'operator': 'is', 'value': 'libB'}
              },
            ],
          },
          {
            'anyOf': [
              {
                'readStatus': {'operator': 'is', 'value': 'UNREAD'}
              },
            ],
          },
        ],
      },
    });
  });

  test('age ratings serialize with integer values', () {
    final body = const SeriesSearch(ageRatings: [18]).toRequestBody();
    expect(body, {
      'condition': {
        'allOf': [
          {
            'anyOf': [
              {
                'ageRating': {'operator': 'is', 'value': 18}
              },
            ],
          },
        ],
      },
    });
  });
}
