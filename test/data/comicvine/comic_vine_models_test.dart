import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/data/comicvine/comic_vine_models.dart';

void main() {
  group('normalizeTitle / query helpers', () {
    test('normalizeTitle lowercases, strips year, collapses punctuation', () {
      expect(normalizeTitle('Saga (2012-)'), 'saga');
      expect(normalizeTitle('Godzilla (2025)'), 'godzilla');
      expect(normalizeTitle('X-Men: Red'), 'x men red');
    });

    test('comicVineSearchQuery drops the year suffix, keeps the words', () {
      expect(comicVineSearchQuery('Cruel Universe (2025-)'), 'Cruel Universe');
      expect(comicVineSearchQuery('Saga'), 'Saga');
    });

    test('komgaTitleYear extracts the embedded year', () {
      expect(komgaTitleYear('Cruel Universe (2025-)'), 2025);
      expect(komgaTitleYear('Godzilla (2025)'), 2025);
      expect(komgaTitleYear('Saga'), isNull);
    });
  });

  group('bestVolumeMatch', () {
    CvVolumeMatch v(int id, String name, {int? count, String? year}) =>
        CvVolumeMatch(id: id, name: name, countOfIssues: count, startYear: year);

    test('picks the closest issue count among name overlaps', () {
      final match = bestVolumeMatch(
        [v(1, 'Saga', count: 60), v(2, 'Saga of the Swamp Thing', count: 171)],
        title: 'Saga (2012-)',
        booksCount: 9,
      );
      expect(match?.name, 'Saga');
    });

    test('matches despite a prefix the Komga title lacks (EC Cruel Universe)',
        () {
      final match = bestVolumeMatch(
        [
          v(1, 'EC Cruel Universe', year: '2025', count: 6),
          v(2, 'Cruel Summer', count: 12),
        ],
        title: 'Cruel Universe (2025-)',
        booksCount: 6,
      );
      expect(match?.name, 'EC Cruel Universe');
    });

    test('uses the title year to disambiguate same-named volumes', () {
      final match = bestVolumeMatch(
        [
          v(1, 'EC Cruel Universe', year: '1954', count: 9),
          v(2, 'EC Cruel Universe', year: '2025', count: 6),
        ],
        title: 'Cruel Universe (2025-)',
        booksCount: 6,
      );
      expect(match?.id, 2);
    });

    test('returns null when nothing overlaps', () {
      final match = bestVolumeMatch(
        [v(1, 'Berserk', count: 41)],
        title: 'Godzilla',
        booksCount: 5,
      );
      expect(match, isNull);
    });

    test('breaks ties on lowest id', () {
      final match = bestVolumeMatch(
        [v(9, 'Hellboy', count: 20), v(3, 'Hellboy', count: 20)],
        title: 'Hellboy',
        booksCount: 20,
      );
      expect(match?.id, 3);
    });
  });

  group('stripHtml', () {
    test('removes nested tags and decodes entities', () {
      expect(
        stripHtml('<p>Tom &amp; <i>Jerry</i> &lt;3</p>'),
        'Tom & Jerry <3',
      );
    });
  });

  group('groupCreatorsByRole', () {
    test('splits comma roles, person under each role, first-seen order', () {
      final groups = groupCreatorsByRole([
        (name: 'A', role: 'writer, artist'),
        (name: 'B', role: 'Artist'),
      ]);
      expect(groups.map((g) => g.role).toList(), ['Writer', 'Artist']);
      expect(groups[1].names, ['A', 'B']);
    });
  });

  group('cache round-trip', () {
    test('volume encode/decode preserves fields', () {
      const data = ComicVineVolumeData(
        matchedId: 7,
        name: 'Saga',
        deck: 'Space opera',
        publisher: 'Image',
        startYear: '2012',
        issueCount: 60,
        characters: ['Alana', 'Marko'],
        creators: [(name: 'BKV', role: 'Writer')],
      );
      final back = volumeFromCache(volumeToCache(data));
      expect(back.matchedId, 7);
      expect(back.name, 'Saga');
      expect(back.characters, ['Alana', 'Marko']);
      expect(back.creators.single.role, 'Writer');
    });

    test('noMatch payload is detected', () {
      expect(comicVineIsNoMatch(comicVineNoMatchPayload()), isTrue);
      expect(comicVineIsNoMatch(volumeToCache(const ComicVineVolumeData(
        matchedId: 1,
        name: 'x',
      ))), isFalse);
    });
  });

  group('DTO parse', () {
    test('CvVolume reads publisher.name and comma roles', () {
      final v = CvVolume.fromJson({
        'id': 4050,
        'name': 'Saga',
        'publisher': {'name': 'Image'},
        'characters': [
          {'id': 1, 'name': 'Alana'},
        ],
        'people': [
          {'id': 2, 'name': 'BKV', 'role': 'writer'},
        ],
      });
      expect(v.publisherName, 'Image');
      expect(v.characters, ['Alana']);
      expect(v.people.single.role, 'writer');
    });
  });
}
