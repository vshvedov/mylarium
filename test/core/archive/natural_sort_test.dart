import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/core/archive/natural_sort.dart';

void main() {
  test('numeric runs sort numerically, not lexically', () {
    final names = ['page10.jpg', 'page2.jpg', 'page1.jpg', 'page20.jpg'];
    names.sort(naturalCompare);
    expect(names, ['page1.jpg', 'page2.jpg', 'page10.jpg', 'page20.jpg']);
  });

  test('equal numeric value tie-breaks by fewer leading zeros first', () {
    final names = ['p007.jpg', 'p7.jpg', 'p08.jpg', 'p8.jpg'];
    names.sort(naturalCompare);
    // Values 7,7,8,8; within equal values the one with fewer zeros sorts first.
    expect(names, ['p7.jpg', 'p007.jpg', 'p8.jpg', 'p08.jpg']);
  });

  test('case-insensitive text comparison', () {
    expect(naturalCompare('Cover.jpg', 'cover.jpg'), 0);
    expect(naturalCompare('A.jpg', 'b.jpg'), lessThan(0));
  });

  test('mixed depth paths sort sensibly', () {
    final names = ['ch1/p2.png', 'ch1/p10.png', 'ch1/p1.png'];
    names.sort(naturalCompare);
    expect(names, ['ch1/p1.png', 'ch1/p2.png', 'ch1/p10.png']);
  });
}
