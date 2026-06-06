import 'package:flutter/material.dart';

import 'gestures/fit_scale.dart';
import 'reader_models.dart';
import 'widgets/page_error.dart';

/// Double-page (spread) reader. Renders precomputed [pairs] (each `[i]` solo or
/// `[i, i+1]`) in a [PageView], honoring reading direction. Each spread is
/// pinch-zoomable via [InteractiveViewer]; taps are reported as a normalized
/// position for the screen's tap-zone resolver.
class DoublePageView extends StatelessWidget {
  const DoublePageView({
    super.key,
    required this.pageController,
    required this.pairs,
    required this.imageBuilder,
    required this.fit,
    required this.rtl,
    required this.filterQuality,
    required this.onPageChanged,
    required this.onTap,
  });

  final PageController pageController;
  final List<List<int>> pairs;
  final ImageProvider Function(int index) imageBuilder;
  final FitMode fit;
  final bool rtl;

  /// GPU sampling quality for the page textures (device-tier driven).
  final FilterQuality filterQuality;
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
        return LayoutBuilder(
          builder: (context, constraints) => GestureDetector(
            onTapUp: (details) {
              final w = constraints.maxWidth, h = constraints.maxHeight;
              if (w == 0 || h == 0) return;
              onTap(Offset(
                details.localPosition.dx / w,
                details.localPosition.dy / h,
              ));
            },
            child: InteractiveViewer(
              maxScale: 4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final p in ordered)
                    Flexible(
                      child: Image(
                        image: imageBuilder(p),
                        fit: boxFitFor(fit),
                        filterQuality: filterQuality,
                        gaplessPlayback: true,
                        errorBuilder: (_, _, _) => const PageError(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
