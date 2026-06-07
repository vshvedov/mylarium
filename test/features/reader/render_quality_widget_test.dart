import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/features/reader/double_page_view.dart';
import 'package:mylarium/features/reader/reader_models.dart';
import 'package:mylarium/features/reader/webtoon_view.dart';

/// A provider whose image never completes, so the test exercises widget
/// construction (the [Image.filterQuality] property) without real bytes or a
/// pending decode timer.
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
  testWidgets('double-page images use the supplied filter quality',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: DoublePageView(
        pageController: PageController(),
        pairs: const [
          [0, 1],
        ],
        imageBuilder: (i) => _StubProvider(i),
        fit: FitMode.screen,
        rtl: false,
        filterQuality: FilterQuality.high,
        onPageChanged: (_) {},
        onTap: (_) {},
      ),
    ));
    final images = tester.widgetList<Image>(find.byType(Image));
    expect(images, isNotEmpty);
    expect(images.every((i) => i.filterQuality == FilterQuality.high), isTrue);
  });

  testWidgets('webtoon images use the supplied filter quality', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: WebtoonView(
        scrollController: ScrollController(),
        pageCount: 1,
        imageBuilder: (i) => _StubProvider(i),
        aspectRatio: (_) => 0.66,
        gaps: false,
        filterQuality: FilterQuality.medium,
        onTapToggle: () {},
      ),
    ));
    final images = tester.widgetList<Image>(find.byType(Image));
    expect(images, isNotEmpty);
    expect(images.every((i) => i.filterQuality == FilterQuality.medium), isTrue);
  });
}
