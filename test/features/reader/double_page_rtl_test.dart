import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/features/reader/double_page_layout.dart';

/// The double-page pairing is direction-agnostic (T4): RTL reuses the same
/// `pairs` and only reverses each spread's display order, which the view does
/// via `group.reversed`. This pins that contract over cover-offset + wide pages.
void main() {
  const layout = DoublePageLayout();

  test('RTL reuses the same pairing, only reversing display order', () {
    final pairs = layout.pairs(6, coverSolo: true, widePages: {3});
    // Pairing is identical regardless of direction.
    expect(pairs, [
      [0],
      [1, 2],
      [3],
      [4, 5],
    ]);

    // RTL display: each spread is shown right-to-left (higher index on the left,
    // lower on the right). Solo pages (cover, wide) are unaffected.
    final rtlDisplay = [for (final g in pairs) g.reversed.toList()];
    expect(rtlDisplay, [
      [0], // cover stays solo
      [2, 1], // spread reversed
      [3], // wide page stays solo
      [5, 4], // spread reversed
    ]);
  });

  test('without a cover offset the first spread also reverses in RTL', () {
    final pairs = layout.pairs(4);
    expect(pairs, [
      [0, 1],
      [2, 3],
    ]);
    final rtlDisplay = [for (final g in pairs) g.reversed.toList()];
    expect(rtlDisplay, [
      [1, 0],
      [3, 2],
    ]);
  });
}
