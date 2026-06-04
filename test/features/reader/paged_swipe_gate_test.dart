import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/features/reader/paged_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

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
  testWidgets('page swipe is gated to scale 1 (NeverScrollable when zoomed)',
      (tester) async {
    final zoomed = ValueNotifier<bool>(false);
    addTearDown(zoomed.dispose);
    final controller = PageController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(MaterialApp(
      home: PagedView(
        pageController: controller,
        pageCount: 3,
        imageBuilder: (i) => _StubProvider(i),
        rtl: false,
        doubleTapZoom: true,
        zoomed: zoomed,
        onPageChanged: (_) {},
        onTap: (_) {},
      ),
    ));

    PhotoViewGallery gallery() =>
        tester.widget<PhotoViewGallery>(find.byType(PhotoViewGallery));

    // At scale 1, paging is enabled.
    expect(gallery().scrollPhysics, isA<PageScrollPhysics>());

    // When a page is zoomed, the gallery stops paging.
    zoomed.value = true;
    await tester.pump();
    expect(gallery().scrollPhysics, isA<NeverScrollableScrollPhysics>());
  });
}
