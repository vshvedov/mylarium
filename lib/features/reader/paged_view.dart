import 'package:flutter/material.dart';

import '../../app/widgets/app_loading.dart';
import 'gestures/fit_scale.dart';
import 'gestures/focal_zoom.dart';
import 'reader_models.dart';
import 'upscaled_image.dart';
import 'widgets/page_error.dart';

/// Paged reader (LTR / RTL). A [PageView] of [FocalZoomViewer] pages: pinch-zoom
/// and double-tap anchor on the gesture's focal point, and horizontal page swipe
/// is gated off while a page is zoomed (so panning a zoomed page never turns the
/// page). Taps are reported as a normalized position for the tap-zone resolver;
/// double-tap zoom is disabled when [doubleTapZoom] is off (so a double tap reads
/// as two page turns). Pages render through the Lanczos upscale shader.
class PagedView extends StatefulWidget {
  const PagedView({
    super.key,
    required this.pageController,
    required this.pageCount,
    required this.imageBuilder,
    required this.fit,
    required this.rtl,
    required this.doubleTapZoom,
    required this.zoomed,
    required this.onPageChanged,
    required this.onTap,
  });

  final PageController pageController;
  final int pageCount;
  final ImageProvider Function(int index) imageBuilder;
  final FitMode fit;
  final bool rtl;
  final bool doubleTapZoom;

  /// True while the current page is zoomed in; gates page swipe.
  final ValueNotifier<bool> zoomed;
  final void Function(int index) onPageChanged;
  final void Function(Offset normalized) onTap;

  @override
  State<PagedView> createState() => _PagedViewState();
}

class _PagedViewState extends State<PagedView> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: widget.zoomed,
      builder: (context, isZoomed, _) => PageView.builder(
        controller: widget.pageController,
        reverse: widget.rtl,
        physics: isZoomed
            ? const NeverScrollableScrollPhysics()
            : const PageScrollPhysics(),
        onPageChanged: (i) {
          // A fresh page starts at fit; clear the gate so swiping works again.
          widget.zoomed.value = false;
          widget.onPageChanged(i);
        },
        itemCount: widget.pageCount,
        itemBuilder: (context, index) => FocalZoomViewer(
          key: ValueKey(index),
          doubleTapZoom: widget.doubleTapZoom,
          onTap: widget.onTap,
          onZoomChanged: (z) => widget.zoomed.value = z,
          builder: (context, zoomed) => UpscaledImage(
            image: widget.imageBuilder(index),
            fit: boxFitFor(widget.fit),
            highQuality: zoomed,
            loadingBuilder: (_) => const AppLoadingIndicator(),
            errorBuilder: (_) => const PageError(),
          ),
        ),
      ),
    );
  }
}
