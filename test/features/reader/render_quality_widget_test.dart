import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/features/reader/double_page_view.dart';
import 'package:mylarium/features/reader/reader_models.dart';
import 'package:mylarium/features/reader/upscaled_image.dart';
import 'package:mylarium/features/reader/webtoon_view.dart';

/// A provider whose image never completes, so the test exercises widget
/// construction without real bytes or a pending decode timer.
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
  testWidgets('double-page renders pages through the upscale shader',
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
        onPageChanged: (_) {},
        onTap: (_) {},
      ),
    ));
    await tester.pump();
    // Both pages of the spread go through UpscaledImage (not a plain Image).
    expect(find.byType(UpscaledImage), findsNWidgets(2));
  });

  testWidgets('webtoon renders pages through the upscale shader',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: WebtoonView(
        scrollController: ScrollController(),
        pageCount: 1,
        imageBuilder: (i) => _StubProvider(i),
        aspectRatio: (_) => 0.66,
        gaps: false,
        onTapToggle: () {},
      ),
    ));
    await tester.pump();
    expect(find.byType(UpscaledImage), findsOneWidget);
  });
}
