import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/features/reader/page_source.dart';
import 'package:mylarium/features/reader/webtoon_view.dart';

/// A provider whose image never completes, so the test exercises layout
/// (reserved extents) without needing real bytes.
class _StubProvider extends ImageProvider<_StubProvider> {
  const _StubProvider(this.index);
  final int index;

  @override
  Future<_StubProvider> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture(this);

  @override
  ImageStreamCompleter loadImage(
          _StubProvider key, ImageDecoderCallback decode) =>
      OneFrameImageStreamCompleter(Completer<ImageInfo>().future);

  @override
  bool operator ==(Object other) =>
      other is _StubProvider && other.index == index;
  @override
  int get hashCode => index;
}

void main() {
  Future<void> pumpWebtoon(
    WidgetTester tester, {
    required double? Function(int) aspectRatio,
  }) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: WebtoonView(
          scrollController: ScrollController(),
          pageCount: 3,
          imageBuilder: (i) => _StubProvider(i),
          aspectRatio: aspectRatio,
          gaps: false,
          filterQuality: FilterQuality.high,
          onTapToggle: () {},
        ),
      ),
    );
  }

  testWidgets('reserves the page aspect ratio when known', (tester) async {
    await pumpWebtoon(tester, aspectRatio: (i) => 0.5);
    final ratios = tester
        .widgetList<AspectRatio>(find.byType(AspectRatio))
        .map((w) => w.aspectRatio)
        .toList();
    expect(ratios, isNotEmpty);
    expect(ratios.every((r) => r == 0.5), isTrue,
        reason: 'every built page reserves its known ratio');
  });

  testWidgets('falls back to the default aspect when unknown', (tester) async {
    await pumpWebtoon(tester, aspectRatio: (i) => null);
    final first = tester
        .widgetList<AspectRatio>(find.byType(AspectRatio))
        .first
        .aspectRatio;
    expect(first, kDefaultPageAspect);
  });
}
