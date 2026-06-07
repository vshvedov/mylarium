import 'package:flutter/material.dart';

import 'gestures/focal_zoom.dart';
import 'page_source.dart';
import 'upscaled_image.dart';
import 'widgets/page_error.dart';

/// Gapless (or gapped) vertical-scroll webtoon reader. Each page reserves its
/// aspect ratio up front (from [aspectRatio], else [kDefaultPageAspect]) so a
/// page loading in does not jump the scroll position. The reserved extent is
/// never recomputed after a real decode. The strip is pinch/double-tap zoomable
/// (focal-anchored) and pages render through the upscale shader.
class WebtoonView extends StatelessWidget {
  const WebtoonView({
    super.key,
    required this.scrollController,
    required this.pageCount,
    required this.imageBuilder,
    required this.aspectRatio,
    required this.gaps,
    required this.doubleTapZoom,
    required this.onTapToggle,
  });

  final ScrollController scrollController;
  final int pageCount;
  final ImageProvider Function(int index) imageBuilder;
  final double? Function(int index) aspectRatio;
  final bool gaps;
  final bool doubleTapZoom;
  final VoidCallback onTapToggle;

  @override
  Widget build(BuildContext context) {
    return FocalZoomViewer(
      doubleTapZoom: doubleTapZoom,
      onTap: (_) => onTapToggle(),
      child: ListView.builder(
        controller: scrollController,
        itemCount: pageCount,
        itemBuilder: (context, i) => Padding(
          padding:
              gaps ? const EdgeInsets.symmetric(vertical: 6) : EdgeInsets.zero,
          child: AspectRatio(
            aspectRatio: aspectRatio(i) ?? kDefaultPageAspect,
            child: UpscaledImage(
              image: imageBuilder(i),
              fit: BoxFit.fitWidth,
              errorBuilder: (_) => const PageError(),
            ),
          ),
        ),
      ),
    );
  }
}
