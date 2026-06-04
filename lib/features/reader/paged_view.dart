import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import 'gestures/fit_scale.dart';
import 'reader_models.dart';
import 'widgets/page_error.dart';

/// Paged reader (LTR / RTL). Uses [PhotoViewGallery] so pinch-zoom/pan work and
/// horizontal page swipe is gated to scale 1 (when any page is zoomed, the
/// gallery stops paging). Taps are reported as a normalized position for the
/// screen's tap-zone resolver. Double-tap zoom is disabled when
/// [doubleTapZoom] is off so a double tap reads as two instant page turns.
class PagedView extends StatelessWidget {
  const PagedView({
    super.key,
    required this.pageController,
    required this.pageCount,
    required this.imageBuilder,
    required this.aspectRatioOf,
    required this.fit,
    required this.viewportAspect,
    required this.rtl,
    required this.doubleTapZoom,
    required this.zoomed,
    required this.onPageChanged,
    required this.onTap,
  });

  final PageController pageController;
  final int pageCount;
  final ImageProvider Function(int index) imageBuilder;
  final double? Function(int index) aspectRatioOf;
  final FitMode fit;
  final double viewportAspect;
  final bool rtl;
  final bool doubleTapZoom;

  /// True while any page is zoomed in; gates page swipe.
  final ValueNotifier<bool> zoomed;
  final void Function(int index) onPageChanged;
  final void Function(Offset normalized) onTap;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: zoomed,
      builder: (context, isZoomed, _) => PhotoViewGallery.builder(
        itemCount: pageCount,
        pageController: pageController,
        reverse: rtl,
        onPageChanged: onPageChanged,
        scrollPhysics: isZoomed
            ? const NeverScrollableScrollPhysics()
            : const PageScrollPhysics(),
        scaleStateChangedCallback: (state) =>
            zoomed.value = state != PhotoViewScaleState.initial,
        backgroundDecoration: const BoxDecoration(color: Colors.transparent),
        loadingBuilder: (context, _) =>
            const Center(child: CircularProgressIndicator()),
        builder: (context, index) => PhotoViewGalleryPageOptions(
          imageProvider: imageBuilder(index),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 4,
          initialScale:
              fitInitialScale(fit, aspectRatioOf(index), viewportAspect),
          errorBuilder: (context, _, _) => const PageError(),
          // Identity cycle = double-tap does not change scale (zoom disabled).
          scaleStateCycle: doubleTapZoom ? defaultScaleStateCycle : (s) => s,
          onTapUp: (ctx, details, _) {
            final size = ctx.size;
            if (size == null || size.width == 0 || size.height == 0) return;
            onTap(Offset(
              details.localPosition.dx / size.width,
              details.localPosition.dy / size.height,
            ));
          },
        ),
      ),
    );
  }
}
