import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/features/reader/double_page_layout.dart';

void main() {
  const layout = DoublePageLayout();

  test('cover-solo offsets pairing by one', () {
    expect(layout.pairs(5, coverSolo: true), [
      [0],
      [1, 2],
      [3, 4],
    ]);
  });

  test('no cover offset pairs from zero', () {
    expect(layout.pairs(4), [
      [0, 1],
      [2, 3],
    ]);
  });

  test('odd trailing page is solo', () {
    expect(layout.pairs(5), [
      [0, 1],
      [2, 3],
      [4],
    ]);
  });

  test('wide page is solo and parity resynchronizes after it', () {
    // count=6, coverSolo, wide page at index 3.
    expect(layout.pairs(6, coverSolo: true, widePages: {3}), [
      [0],
      [1, 2],
      [3],
      [4, 5],
    ]);
  });

  test('a wide page mid-spread breaks the spread cleanly', () {
    // index 2 is wide: 0-1 pair, 2 solo, 3-4 pair.
    expect(layout.pairs(5, widePages: {2}), [
      [0, 1],
      [2],
      [3, 4],
    ]);
  });

  test('empty book yields no groups', () {
    expect(layout.pairs(0), isEmpty);
  });
}
