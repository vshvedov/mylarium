import 'package:flutter/material.dart';

import '../../../app/theme/design_tokens.dart';
import '../../../app/widgets/skeleton.dart';
import 'rail.dart';

/// A rail-shaped loading placeholder: the real header (so it does not shift when
/// content arrives) over a row of shimmer tiles at the exact [Rail] metrics, so
/// the home reserves the right vertical space and nothing pops in.
class RailSkeleton extends StatelessWidget {
  const RailSkeleton({
    super.key,
    required this.title,
    this.icon,
    this.count = 6,
    this.height = 230,
    this.tileWidth = 130,
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
                SizedBox(width: tileWidth, child: const _SkeletonTile()),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// One placeholder tile: a cover-shaped shimmer box over two short text bars,
/// matching [CoverTile]'s cover + title + subtitle layout.
class _SkeletonTile extends StatelessWidget {
  const _SkeletonTile();

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<DesignTokens>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: SkeletonBox(borderRadius: tokens.coverRadius)),
        const SizedBox(height: 6),
        const SkeletonBox(height: 12, width: 100),
        const SizedBox(height: 4),
        const SkeletonBox(height: 10, width: 60),
      ],
    );
  }
}
