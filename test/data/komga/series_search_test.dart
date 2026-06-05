import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/data/komga/models/series_search.dart';

void main() {
  test('full text goes into the body as fullTextSearch', () {
    const search = SeriesSearch(fullText: 'batman');
    expect(search.toRequestBody(), {'fullTextSearch': 'batman'});
  });

  test('empty full text is omitted from the body', () {
    expect(const SeriesSearch(fullText: '').fullTextSearch, isNull);
    expect(const SeriesSearch(fullText: '').toRequestBody(), isEmpty);
    expect(const SeriesSearch().toRequestBody(), isEmpty);
  });

  test('full text and filters combine in one body', () {
    const search = SeriesSearch(fullText: 'batman', readStatus: ['UNREAD']);
    final body = search.toRequestBody();
    expect(body['fullTextSearch'], 'batman');
    expect(body['condition'], isNotNull);
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

  test('genre, tag and publisher filters serialize as their own groups (T3)',
      () {
    final body = const SeriesSearch(
      genres: ['Action'],
      tags: ['ongoing'],
      publishers: ['Acme'],
    ).toRequestBody();

    // Groups are emitted in field order: genre, tag, publisher.
    expect(body, {
      'condition': {
        'allOf': [
          {
            'anyOf': [
              {
                'genre': {'operator': 'is', 'value': 'Action'}
              },
            ],
          },
          {
            'anyOf': [
              {
                'tag': {'operator': 'is', 'value': 'ongoing'}
              },
            ],
          },
          {
            'anyOf': [
              {
                'publisher': {'operator': 'is', 'value': 'Acme'}
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
