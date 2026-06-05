import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_icons.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/theme/design_tokens.dart';
import '../../../app/widgets/pressable_scale.dart';
import '../../offline/offline_providers.dart';
import 'cover_image.dart';

/// A cover tile: rounded cover image with a title/subtitle beneath. Used in
/// grids and horizontal rails. The cover keeps a 0.7 aspect (comic portrait),
/// sits on a subtle elevation, and scales briefly on press (with a light
/// haptic) instead of a Material ripple.
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
    this.leadingBadge,
  });

  final String sourceId;
  final String ownerType;
  final String ownerId;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  /// Top-right overlay (e.g. the completed check).
  final Widget? badge;

  /// Top-left overlay (e.g. the offline indicator), kept opposite [badge] so the
  /// two never collide.
  final Widget? leadingBadge;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<DesignTokens>()!;
    return PressableScale(
      onTap: onTap == null
          ? null
          : () {
              AppHaptics.selection();
              onTap!();
            },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              key: const ValueKey('coverShadow'),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(tokens.coverRadius),
                boxShadow: tokens.elevation.card,
              ),
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
                    if (leadingBadge != null)
                      Positioned(top: 6, left: 6, child: leadingBadge!),
                  ],
                ),
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

/// A small "available offline" indicator for a book cover, shown only when the
/// book has a cached archive. Pass as [CoverTile.leadingBadge] for book tiles.
class OfflineBadge extends ConsumerWidget {
  const OfflineBadge({super.key, required this.sourceId, required this.bookId});

  final String sourceId;
  final String bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cached =
        ref.watch(cachedAssetProvider(sourceId, bookId)).valueOrNull;
    if (cached == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(
        color: Color(0x99000000),
        shape: BoxShape.circle,
      ),
      child: const Icon(AppIcons.downloaded, size: 13, color: Colors.white),
    );
  }
}
