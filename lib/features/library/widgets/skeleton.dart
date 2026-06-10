import 'package:flutter/material.dart';

import '../../../app/theme/design_tokens.dart';
import 'rail.dart';

/// A rail-shaped loading placeholder: the real [RailHeader] (so the header does
/// not shift when content arrives) over a row of pulsing [SkeletonTile]s at the
/// exact [Rail] metrics, so the home reserves the right vertical space and
/// nothing jumps when data lands. Pass the hero metrics ([kHeroRailHeight] /
/// [kHeroRailTileWidth]) for the keep-reading slot.
class SkeletonRail extends StatelessWidget {
  const SkeletonRail({
    super.key,
    required this.title,
    this.icon,
    this.count = 6,
    this.height = kRailHeight,
    this.tileWidth = kRailTileWidth,
  });

  final String title;
  final IconData? icon;
  final int count;
  final double height;
  final double tileWidth;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RailHeader(title: title, icon: icon),
        SizedBox(
          height: height,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: count,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, _) =>
                SizedBox(width: tileWidth, child: const SkeletonTile()),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// One placeholder tile: a cover-shaped rounded rect over two short text stubs,
/// matching a cover tile's cover + title + subtitle layout, pulsing gently
/// (opacity 0.35..0.65 over 1.2s) while content loads. Static on e-ink (no
/// animation; every frame is a visible ink refresh) and under reduce-motion
/// (which also keeps widget-test pumpAndSettle from hanging on the ticker).
class SkeletonTile extends StatefulWidget {
  const SkeletonTile({super.key});

  @override
  State<SkeletonTile> createState() => _SkeletonTileState();
}

class _SkeletonTileState extends State<SkeletonTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  /// True when the pulse must not run (e-ink theme or reduce-motion).
  bool _still(BuildContext context) =>
      einkOf(context) || MediaQuery.disableAnimationsOf(context);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_still(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<DesignTokens>()!;
    final color = Theme.of(context).colorScheme.surfaceContainerHigh;
    final tile = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(tokens.coverRadius),
            ),
          ),
        ),
        const SizedBox(height: 6),
        _Stub(color: color, height: 12, width: 100),
        const SizedBox(height: 4),
        _Stub(color: color, height: 10, width: 60),
      ],
    );
    if (_still(context)) {
      // Midpoint of the pulse range, frozen: reads as the same skeleton without
      // running any animation.
      return Opacity(opacity: 0.5, child: tile);
    }
    return FadeTransition(
      opacity: _controller.drive(
        Tween(begin: 0.35, end: 0.65)
            .chain(CurveTween(curve: Curves.easeInOut)),
      ),
      child: tile,
    );
  }
}

/// A short rounded text-line stub inside a [SkeletonTile].
class _Stub extends StatelessWidget {
  const _Stub({required this.color, required this.height, required this.width});

  final Color color;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) => Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(height / 2),
        ),
      );
}
