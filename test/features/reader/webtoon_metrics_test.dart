import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/features/reader/page_source.dart';
import 'package:mylarium/features/reader/webtoon_metrics.dart';

void main() {
  test('offsets accumulate page heights (width / aspect) plus gap', () {
    // width 100, aspects 0.5 (height 200) and 1.0 (height 100), gap 10.
    final offsets = webtoonOffsets(100, [0.5, 1.0], 10);
    expect(offsets, [0.0, 210.0, 320.0]);
  });

  test('unknown aspect uses the default page aspect', () {
    final offsets = webtoonOffsets(100, [null], 0);
    expect(offsets[1], closeTo(100 / kDefaultPageAspect, 0.001));
  });

  test('webtoonPageAt maps a scroll offset to the containing page', () {
    final offsets = webtoonOffsets(100, [0.5, 1.0, 0.5], 0); // 200,100,200
    expect(webtoonPageAt(offsets, 0), 0);
    expect(webtoonPageAt(offsets, 199), 0);
    expect(webtoonPageAt(offsets, 200), 1);
    expect(webtoonPageAt(offsets, 299), 1);
    expect(webtoonPageAt(offsets, 300), 2);
    // Past the end clamps to the last page.
    expect(webtoonPageAt(offsets, 99999), 2);
  });

  test('empty book is page 0', () {
    expect(webtoonPageAt(webtoonOffsets(100, const [], 0), 0), 0);
  });
}
