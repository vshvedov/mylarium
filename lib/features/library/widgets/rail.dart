import 'package:flutter/material.dart';

/// A titled horizontal rail of cover tiles. Hidden entirely when [children] is
/// empty so empty rails do not clutter the home.
class Rail extends StatelessWidget {
  const Rail({
    super.key,
    required this.title,
    required this.children,
    this.height = 230,
    this.tileWidth = 130,
  });

  final String title;
  final List<Widget> children;
  final double height;
  final double tileWidth;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
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
      ],
    );
  }
}
