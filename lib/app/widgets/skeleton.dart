import 'package:flutter/material.dart';

/// A rounded placeholder box with a left-to-right shimmer sweep, used to build
/// loading skeletons. Honors reduce-motion: when animations are disabled it
/// renders a static tint and runs no ticker (so widget tests that pumpAndSettle
/// do not hang). Sizes itself to [width] / [height] when given, else fills its
/// parent (use inside an Expanded / SizedBox).
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 6,
  });

  final double? width;
  final double? height;
  final double borderRadius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Start/stop the repeating sweep based on reduce-motion. Stopping under
    // reduce-motion also means no perpetual ticker in tests.
    final reduce = MediaQuery.disableAnimationsOf(context);
    if (reduce) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = scheme.surfaceContainerHighest;
    final radius = BorderRadius.circular(widget.borderRadius);

    if (MediaQuery.disableAnimationsOf(context)) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(color: base, borderRadius: radius),
      );
    }

    final highlight = Color.alphaBlend(
      scheme.onSurface.withValues(alpha: 0.06),
      base,
    );
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: LinearGradient(
            colors: [base, highlight, base],
            stops: const [0.1, 0.5, 0.9],
            transform: _SweepTransform(_controller.value),
          ),
        ),
      ),
    );
  }
}

/// Slides a gradient horizontally across its bounds as [t] goes 0 -> 1.
class _SweepTransform extends GradientTransform {
  const _SweepTransform(this.t);

  final double t;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * (2 * t - 1), 0, 0);
}
