import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/data/source/models/book_dto.dart';
import 'package:mylarium/data/source/models/series_dto.dart';
import 'package:mylarium/features/library/rail_item.dart';

void main() {
  test('fromSeriesDto: multi-book series is stacked, single is flat', () {
    final multi = RailItem.fromSeriesDto(SeriesDto(
        id: 'a', libraryId: 'l', name: 'A', title: 'A', titleSort: 'A',
        booksCount: 3));
    final single = RailItem.fromSeriesDto(SeriesDto(
        id: 'b', libraryId: 'l', name: 'B', title: 'B', titleSort: 'B',
        booksCount: 1));
    expect(multi.ownerType, 'series');
    expect(multi.ownerId, 'a');
    expect(multi.title, 'A');
    expect(multi.stacked, isTrue);
    expect(multi.subtitle, isNull);
    expect(single.stacked, isFalse);
  });

  test('fromBookDto: number becomes a "No. N" subtitle, empty number drops it',
      () {
    final numbered = RailItem.fromBookDto(BookDto(
        id: 'b1', seriesId: 's', libraryId: 'l', name: 'B1', title: 'B1',
        number: '3'));
    final blank = RailItem.fromBookDto(BookDto(
        id: 'b2', seriesId: 's', libraryId: 'l', name: 'B2', title: 'B2',
        number: ''));
    expect(numbered.ownerType, 'book');
    expect(numbered.subtitle, 'No. 3');
    expect(numbered.stacked, isFalse);
    expect(blank.subtitle, isNull);
  });

  test('value equality', () {
    const a = RailItem(ownerType: 'book', ownerId: 'x', title: 'T');
    const b = RailItem(ownerType: 'book', ownerId: 'x', title: 'T');
    expect(a, b);
    expect(a.hashCode, b.hashCode);
  });
}
