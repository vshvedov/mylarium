import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/data/kavita/models/kavita_mappers.dart';
import 'package:mylarium/data/kavita/models/kavita_pagination.dart';

void main() {
  group('kavitaVolumesToBooks', () {
    test('maps a whole-volume sentinel chapter from the volume', () {
      // Shape captured from the live server: a manga volume holds one sentinel
      // chapter (range "-100000") representing the whole file.
      final volumes = [
        {
          'id': 31,
          'name': '1',
          'minNumber': 1,
          'number': 1,
          'chapters': [
            {
              'id': 31,
              'range': '-100000',
              'minNumber': -100000,
              'sortOrder': -100000,
              'titleName': '',
              'pages': 219,
              'pagesRead': 0,
              'volumeId': 31,
            },
          ],
        },
        {
          'id': 32,
          'name': '2',
          'minNumber': 2,
          'number': 2,
          'chapters': [
            {
              'id': 33,
              'range': '-100000',
              'minNumber': -100000,
              'sortOrder': -100000,
              'titleName': '',
              'pages': 200,
              'pagesRead': 200,
              'volumeId': 32,
            },
          ],
        },
      ];

      final books =
          kavitaVolumesToBooks(volumes, seriesId: '1', libraryId: '1');

      expect(books, hasLength(2));
      // Number/name/sort come from the VOLUME, not the sentinel chapter.
      expect(books[0].id, '31');
      expect(books[0].number, '1');
      expect(books[0].numberSort, 1);
      expect(books[0].name, 'Volume 1');
      expect(books[0].pagesCount, 219);
      expect(books[0].completed, isFalse);
      // Ordered by volume.minNumber; volume 2 is fully read.
      expect(books[1].id, '33');
      expect(books[1].number, '2');
      expect(books[1].completed, isTrue);
    });

    test('maps read progress to the 1-based contract for reconcile', () {
      final volumes = [
        {
          'id': 5,
          'name': '1',
          'minNumber': 1,
          'number': 1,
          'chapters': [
            {
              'id': 9,
              'range': '-100000',
              'minNumber': -100000,
              'sortOrder': -100000,
              'titleName': '',
              'pages': 26,
              'pagesRead': 9,
              'lastReadingProgressUtc': '2026-06-06T07:41:58.9',
              'volumeId': 5,
            },
          ],
        },
      ];
      final book =
          kavitaVolumesToBooks(volumes, seriesId: '5', libraryId: '1').single;
      // Kavita pagesRead 9 (0-based) -> contract readPage 10 (1-based).
      expect(book.readPage, 10);
      expect(book.completed, isFalse);
      expect(book.readLastModified, isNotNull);
      expect(book.readDate, book.readLastModified);
    });

    test('unread chapter has null readPage and timestamps', () {
      final volumes = [
        {
          'id': 5,
          'name': '1',
          'minNumber': 1,
          'number': 1,
          'chapters': [
            {
              'id': 9,
              'minNumber': -100000,
              'pages': 26,
              'pagesRead': 0,
              'lastReadingProgressUtc': '0001-01-01T00:00:00',
              'volumeId': 5,
            },
          ],
        },
      ];
      final book =
          kavitaVolumesToBooks(volumes, seriesId: '5', libraryId: '1').single;
      expect(book.readPage, isNull);
      expect(book.readLastModified, isNull);
    });

    test('keeps a real chapter number when not a sentinel', () {
      final volumes = [
        {
          'id': 5,
          'name': '1',
          'minNumber': 1,
          'number': 1,
          'chapters': [
            {
              'id': 9,
              'range': '3',
              'minNumber': 3,
              'sortOrder': 3,
              'titleName': 'The Hunt',
              'pages': 26,
              'pagesRead': 0,
              'volumeId': 5,
            },
          ],
        },
      ];
      final books =
          kavitaVolumesToBooks(volumes, seriesId: '2', libraryId: '1');
      expect(books.single.number, '3');
      expect(books.single.numberSort, 3);
      expect(books.single.name, 'The Hunt');
    });
  });

  group('kavitaSeriesToDto', () {
    test('manga library defaults to right-to-left reading', () {
      final dto = kavitaSeriesToDto(
        {'id': 1, 'libraryId': 1, 'name': 'Berserk', 'sortName': 'Berserk'},
        libraryType: 0,
      );
      expect(dto.id, '1');
      expect(dto.readingDirection, 'RIGHT_TO_LEFT');
      expect(dto.title, 'Berserk');
    });

    test('non-manga library defaults to left-to-right', () {
      final dto = kavitaSeriesToDto(
        {'id': 2, 'libraryId': 2, 'name': 'Saga'},
        libraryType: 1,
      );
      expect(dto.readingDirection, 'LEFT_TO_RIGHT');
    });

    test('extracts .name from object-shaped genres/publishers and unsets age 0',
        () {
      final dto = kavitaSeriesToDto(
        {'id': 3, 'libraryId': 1, 'name': 'X'},
        metadata: {
          'summary': 'hi',
          'ageRating': 0,
          'publicationStatus': 2,
          'genres': [
            {'id': 1, 'name': 'Action'},
            {'id': 2, 'name': 'Horror'},
          ],
          'publishers': [
            {'id': 5, 'name': 'Dark Horse'},
          ],
        },
        libraryType: 0,
        booksCount: 12,
      );
      expect(dto.ageRating, isNull); // 0 means unset
      expect(dto.status, 'COMPLETED');
      expect(dto.genres, ['Action', 'Horror']);
      expect(dto.publisher, 'Dark Horse');
      expect(dto.booksCount, 12);
    });
  });

  test('kavitaSearchHitToDto uses seriesId and sums counts', () {
    final dto = kavitaSearchHitToDto({
      'seriesId': 7,
      'name': 'Akira',
      'sortName': 'Akira',
      'libraryId': 1,
      'volumeCount': 6,
      'chapterCount': 2,
    });
    expect(dto.id, '7');
    expect(dto.booksCount, 8);
  });

  test('kavitaReadListItemToBook maps a reading-list item to a book', () {
    final book = kavitaReadListItemToBook({
      'id': 1,
      'chapterId': 31,
      'seriesId': 1,
      'libraryId': 1,
      'title': 'Volume 1',
      'pagesRead': 0,
      'pagesTotal': 219,
      'volumeNumber': 1,
    });
    expect(book.id, '31');
    expect(book.seriesId, '1');
    expect(book.title, 'Volume 1');
    expect(book.pagesCount, 219);
  });

  test('collection and reading-list DTO mappers use the title as name', () {
    expect(kavitaCollectionToDto({'id': 3, 'title': 'Favorites'}).name,
        'Favorites');
    final rl = kavitaReadListToDto({'id': 7, 'title': 'My List'});
    expect(rl.id, '7');
    expect(rl.name, 'My List');
    expect(rl.ordered, isTrue);
  });

  test('kavitaPages synthesizes a 1-based page list', () {
    final pages = kavitaPages(3);
    expect(pages.map((p) => p.number), [1, 2, 3]);
    expect(pages.first.fileName, '');
  });

  group('kavitaPage', () {
    test('parses the Pagination header', () {
      final page = kavitaPage(
        '{"currentPage":2,"itemsPerPage":20,"totalItems":45,"totalPages":3}',
        [1, 2, 3],
        requestedSize: 20,
      );
      expect(page.number, 1); // currentPage 2 -> 0-based 1
      expect(page.totalElements, 45);
      expect(page.totalPages, 3);
      expect(page.last, isFalse);
    });

    test('synthesizes when the header is absent', () {
      final page = kavitaPage(null, [1, 2], requestedSize: 20);
      expect(page.number, 0);
      expect(page.last, isTrue); // short page
      expect(page.totalElements, 2);
    });
  });
}
