import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

/// A non-scrolling grid for use inside a scrolling parent. Tile width is capped
/// by [tileExtent]; spacing uses the design-token grid gutter.
class AppGrid extends StatelessWidget {
  const AppGrid({
    super.key,
    required this.children,
    this.tileExtent = 160,
    this.childAspectRatio = 0.7,
  });

  final List<Widget> children;
  final double tileExtent;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    final gutter = Theme.of(context).extension<DesignTokens>()!.gridGutter;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(gutter),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: tileExtent,
        mainAxisSpacing: gutter,
        crossAxisSpacing: gutter,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: children.length,
      itemBuilder: (_, i) => children[i],
    );
  }
}
