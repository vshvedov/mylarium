import 'package:flutter/material.dart';

/// Default rail metrics: the standard home cover tile.
const double kRailHeight = 230;
const double kRailTileWidth = 130;

/// Hero rail metrics (the keep-reading rail): larger covers plus room for the
/// page-progress bar and "p. X of Y" caption beneath each tile.
const double kHeroRailHeight = 292;
const double kHeroRailTileWidth = 156;

/// A titled horizontal rail of cover tiles. Hidden entirely when [children] is
/// empty so empty rails do not clutter the home.
class Rail extends StatelessWidget {
  const Rail({
    super.key,
    required this.title,
    required this.children,
    this.icon,
    this.height = kRailHeight,
    this.tileWidth = kRailTileWidth,
  });

  final String title;

  /// Optional leading glyph shown before the title (one per home category).
  final IconData? icon;
  final List<Widget> children;
  final double height;
  final double tileWidth;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RailHeader(title: title, icon: icon),
        SizedBox(
          height: height,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: children.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, i) =>
                SizedBox(width: tileWidth, child: children[i]),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// The title row shared by [Rail] and its loading skeleton, so the header does
/// not shift when a rail swaps from skeleton to real content.
class RailHeader extends StatelessWidget {
  const RailHeader({super.key, required this.title, this.icon});

  final String title;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon,
                  size: 18,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
            ],
            Text(title, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      );
}
