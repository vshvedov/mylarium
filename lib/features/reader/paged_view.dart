import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../app/widgets/app_loading.dart';
import 'gestures/fit_scale.dart';
import 'reader_models.dart';
import 'upscaled_image.dart';
import 'widgets/page_error.dart';

/// Paged reader (LTR / RTL). Uses [PhotoViewGallery] so pinch-zoom/pan work and
/// horizontal page swipe is gated to scale 1 (when any page is zoomed, the
/// gallery stops paging). Taps are reported as a normalized position for the
/// screen's tap-zone resolver. Double-tap zoom is disabled when
/// [doubleTapZoom] is off so a double tap reads as two instant page turns.
///
/// Each page is a [customChild] rendered through the Catmull-Rom upscale shader
/// (via [UpscaledImage]) so pinch-zoom stays sharp on every platform. photo_view
/// scales that child with its Transform (hence `filterQuality: none`); the shader
/// samples at device resolution under the scale.
class PagedView extends StatefulWidget {
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
  State<PagedView> createState() => _PagedViewState();
}

class _PagedViewState extends State<PagedView> {
  /// Decoded pixel sizes, learned as pages render, so photo_view gets a
  /// correctly-proportioned `childSize` (offline pages have no a-priori aspect).
  final Map<int, Size> _sizes = {};

  Size _childSize(int index) {
    final known = _sizes[index];
    if (known != null) return known;
    final aspect = widget.aspectRatioOf(index);
    if (aspect != null && aspect > 0) return Size(1000, 1000 / aspect);
    return const Size(1000, 1500); // 2:3 default until the page decodes
  }

  void _onSize(int index, Size size) {
    if (_sizes[index] == size) return;
    // The decoded size can arrive synchronously (cached image) while the gallery
    // is building this page, so defer the rebuild past the current frame to
    // avoid setState-during-build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _sizes[index] == size) return;
      setState(() => _sizes[index] = size);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: widget.zoomed,
      builder: (context, isZoomed, _) => PhotoViewGallery.builder(
        itemCount: widget.pageCount,
        pageController: widget.pageController,
        reverse: widget.rtl,
        onPageChanged: widget.onPageChanged,
        scrollPhysics: isZoomed
            ? const NeverScrollableScrollPhysics()
            : const PageScrollPhysics(),
        scaleStateChangedCallback: (state) =>
            widget.zoomed.value = state != PhotoViewScaleState.initial,
        backgroundDecoration: const BoxDecoration(color: Colors.transparent),
        builder: (context, index) => PhotoViewGalleryPageOptions.customChild(
          childSize: _childSize(index),
          // none: photo_view scales the child via its Transform, and the shader
          // does the high-quality sampling at device resolution under it.
          filterQuality: FilterQuality.none,
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 4,
          initialScale: fitInitialScale(
              widget.fit, widget.aspectRatioOf(index), widget.viewportAspect),
          // Identity cycle = double-tap does not change scale (zoom disabled).
          scaleStateCycle: widget.doubleTapZoom ? defaultScaleStateCycle : (s) => s,
          onTapUp: (ctx, details, _) {
            final size = ctx.size;
            if (size == null || size.width == 0 || size.height == 0) return;
            widget.onTap(Offset(
              details.localPosition.dx / size.width,
              details.localPosition.dy / size.height,
            ));
          },
          child: UpscaledImage(
            image: widget.imageBuilder(index),
            onSize: (s) => _onSize(index, s),
            loadingBuilder: (_) => const AppLoadingIndicator(),
            errorBuilder: (_) => const PageError(),
          ),
        ),
      ),
    );
  }
}
