import 'package:flutter/material.dart';

import 'gestures/fit_scale.dart';
import 'gestures/focal_zoom.dart';
import 'reader_models.dart';
import 'upscaled_image.dart';
import 'widgets/page_error.dart';

/// Double-page (spread) reader. Renders precomputed [pairs] (each `[i]` solo or
/// `[i, i+1]`) in a [PageView], honoring reading direction. Each spread is
/// pinch/double-tap zoomable via [FocalZoomViewer] (focal-anchored), and pages
/// render through the upscale shader. Taps are reported as a normalized position
/// for the screen's tap-zone resolver.
class DoublePageView extends StatelessWidget {
  const DoublePageView({
    super.key,
    required this.pageController,
    required this.pairs,
    required this.imageBuilder,
    required this.fit,
    required this.rtl,
    required this.doubleTapZoom,
    required this.onPageChanged,
    required this.onTap,
  });

  final PageController pageController;
  final List<List<int>> pairs;
  final ImageProvider Function(int index) imageBuilder;
  final FitMode fit;
  final bool rtl;
  final bool doubleTapZoom;
  final void Function(int spreadIndex) onPageChanged;
  final void Function(Offset normalized) onTap;

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: pageController,
      reverse: rtl,
      onPageChanged: onPageChanged,
      itemCount: pairs.length,
      itemBuilder: (context, i) {
        final group = pairs[i];
        // In RTL the right page is the lower index.
        final ordered = rtl ? group.reversed.toList() : group;
        return FocalZoomViewer(
          doubleTapZoom: doubleTapZoom,
          onTap: onTap,
          builder: (context, zoomed) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final p in ordered)
                Flexible(
                  child: UpscaledImage(
                    image: imageBuilder(p),
                    fit: boxFitFor(fit),
                    highQuality: zoomed,
                    errorBuilder: (_) => const PageError(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
