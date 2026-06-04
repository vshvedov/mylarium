import 'package:flutter/material.dart';

import '../../../app/theme/design_tokens.dart';
import 'cover_image.dart';

/// A cover tile: rounded cover image with a title/subtitle beneath. Used in
/// grids and horizontal rails. The cover keeps a 0.7 aspect (comic portrait).
class CoverTile extends StatelessWidget {
  const CoverTile({
    super.key,
    required this.sourceId,
    required this.ownerType,
    required this.ownerId,
    required this.title,
    this.subtitle,
    this.onTap,
    this.badge,
  });

  final String sourceId;
  final String ownerType;
  final String ownerId;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<DesignTokens>()!;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(tokens.coverRadius),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(tokens.coverRadius),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CoverImage(
                    sourceId: sourceId,
                    ownerType: ownerType,
                    ownerId: ownerId,
                    title: title,
                  ),
                  if (badge != null)
                    Positioned(top: 6, right: 6, child: badge!),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: tokens.coverTitleStyle,
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: tokens.coverSubtitleStyle.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}
