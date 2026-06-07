import 'package:flutter/material.dart';

import 'page_source.dart';
import 'widgets/page_error.dart';

/// Gapless (or gapped) vertical-scroll webtoon reader. Each page reserves its
/// aspect ratio up front (from [aspectRatio], else [kDefaultPageAspect]) so a
/// page loading in does not jump the scroll position. The reserved extent is
/// never recomputed after a real decode.
class WebtoonView extends StatelessWidget {
  const WebtoonView({
    super.key,
    required this.scrollController,
    required this.pageCount,
    required this.imageBuilder,
    required this.aspectRatio,
    required this.gaps,
    required this.filterQuality,
    required this.onTapToggle,
  });

  final ScrollController scrollController;
  final int pageCount;
  final ImageProvider Function(int index) imageBuilder;
  final double? Function(int index) aspectRatio;
  final bool gaps;

  /// GPU sampling quality for the page textures (device-tier driven).
  final FilterQuality filterQuality;
  final VoidCallback onTapToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapToggle,
      child: InteractiveViewer(
        maxScale: 4,
        child: ListView.builder(
          controller: scrollController,
          itemCount: pageCount,
          itemBuilder: (context, i) => Padding(
            padding: gaps
                ? const EdgeInsets.symmetric(vertical: 6)
                : EdgeInsets.zero,
            child: AspectRatio(
              aspectRatio: aspectRatio(i) ?? kDefaultPageAspect,
              child: Image(
                image: imageBuilder(i),
                fit: BoxFit.fitWidth,
                filterQuality: filterQuality,
                gaplessPlayback: true,
                errorBuilder: (_, _, _) => const PageError(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
