import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../../core/image/resolve_image.dart';
import '../page_source.dart';
import 'color_pipeline.dart';
import 'color_settings.dart';

/// Decorates a base page [ImageProvider], baking the non-linear residual
/// adjustments (gamma, auto-levels) into the decoded image off the UI isolate.
/// Keyed by `(base, adj.signature)` so the global [ImageCache] dedupes and
/// evicts corrected results (no second cache). Affine adjustments (brightness,
/// contrast, mode) are NOT applied here; the reader layers those on at render
/// with a GPU `ColorFilter`.
@immutable
class ColorCorrectedImageProvider
    extends ImageProvider<ColorCorrectedImageProvider> {
  const ColorCorrectedImageProvider(this.base, this.adj);

  final ImageProvider base;
  final ColorAdjustments adj;

  @override
  Future<ColorCorrectedImageProvider> obtainKey(
    ImageConfiguration configuration,
  ) =>
      SynchronousFuture<ColorCorrectedImageProvider>(this);

  @override
  ImageStreamCompleter loadImage(
    ColorCorrectedImageProvider key,
    ImageDecoderCallback decode,
  ) =>
      OneFrameImageStreamCompleter(_load());

  Future<ImageInfo> _load() async {
    // `ImageConfiguration.empty` is fine: the base page providers size their
    // decode from their own `cacheWidth` field, not the configuration. The base
    // image is engine/cache owned (not disposed here); the base provider is not
    // evicted, so quick-off restores it instantly.
    final src = await resolveImageProvider(base);
    try {
      final corrected = await applyColor(src, adj);
      // applyColor returns `src` unchanged on a no-op (unreadable bytes); clone
      // so disposing this stream's image never frees the base's live handle.
      final image = identical(corrected, src) ? src.clone() : corrected;
      return ImageInfo(image: image, scale: 1.0);
    } catch (_) {
      // Never show a broken page: fall back to the uncorrected source. Clone
      // it: the base image is owned by the base stream, so handing the raw
      // handle to this completer would risk a double-dispose.
      return ImageInfo(image: src.clone(), scale: 1.0);
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ColorCorrectedImageProvider &&
          other.base == base &&
          other.adj.signature == adj.signature;

  @override
  int get hashCode => Object.hash(base, adj.signature);
}

/// Wraps a base [PageSource], returning color-corrected page providers for the
/// non-linear residual [adj]. Delegates page count, aspect ratio (NOT
/// re-derived from the corrected image, so the webtoon no-scroll-jump reserve
/// is preserved), and wide-page detection to the base.
class ColorCorrectingPageSource implements PageSource {
  ColorCorrectingPageSource(this._base, this._adj)
      : assert(!_adj.isIdentity, 'wrap only when there is residual to apply');

  final PageSource _base;
  final ColorAdjustments _adj;

  @override
  int get pageCount => _base.pageCount;

  @override
  ImageProvider imageProvider(int i) =>
      ColorCorrectedImageProvider(_base.imageProvider(i), _adj);

  @override
  ImageProvider imageProviderAt(int i, int? cacheWidth) =>
      ColorCorrectedImageProvider(_base.imageProviderAt(i, cacheWidth), _adj);

  // Scrubber thumbnails are intentionally uncorrected: a tiny preview does not
  // need the (more expensive) residual bake, so forward to the base.
  @override
  ImageProvider thumbnail(int i) => _base.thumbnail(i);

  @override
  Future<ImageProvider> page(int i) async => imageProvider(i);

  @override
  double? aspectRatio(int i) => _base.aspectRatio(i);

  @override
  Set<int> get widePages => _base.widePages;
}

/// Returns a residual-corrected page source when [residual] is non-identity,
/// else the base unchanged. ([residual] carries only gamma/auto-levels; the
/// affine layer is applied separately via a GPU `ColorFilter`.)
PageSource colorCorrectedSource(PageSource base, ColorAdjustments residual) =>
    residual.isIdentity ? base : ColorCorrectingPageSource(base, residual);
