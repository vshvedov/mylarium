import 'package:flutter/widgets.dart';
import 'package:photo_view/photo_view.dart';

import '../reader_models.dart';

/// Maps a [FitMode] to a PhotoView initial scale, given the page's aspect ratio
/// (width / height) and the viewport's aspect ratio. Returns a value relative to
/// `PhotoViewComputedScale.contained` so it composes with PhotoView's layout.
///
/// - screen: fit the whole page (contained).
/// - width: page width fills the viewport (may overflow vertically -> pan).
/// - height: page height fills the viewport (may overflow horizontally -> pan).
/// - original: fill the viewport (covered), the closest practical "native" view
///   given the decode pipeline downsizes with cacheWidth.
dynamic fitInitialScale(FitMode fit, double? imageAspect, double viewportAspect) {
  if (imageAspect == null || imageAspect <= 0 || viewportAspect <= 0) {
    return PhotoViewComputedScale.contained;
  }
  switch (fit) {
    case FitMode.screen:
      return PhotoViewComputedScale.contained;
    case FitMode.width:
      final factor = viewportAspect / imageAspect;
      return PhotoViewComputedScale.contained * (factor < 1 ? 1.0 : factor);
    case FitMode.height:
      final factor = imageAspect / viewportAspect;
      return PhotoViewComputedScale.contained * (factor < 1 ? 1.0 : factor);
    case FitMode.original:
      return PhotoViewComputedScale.covered;
  }
}

/// The [BoxFit] equivalent for views that render with a plain [Image] widget
/// (double-page spreads, webtoon).
BoxFit boxFitFor(FitMode fit) => switch (fit) {
      FitMode.screen => BoxFit.contain,
      FitMode.width => BoxFit.fitWidth,
      FitMode.height => BoxFit.fitHeight,
      FitMode.original => BoxFit.none,
    };
