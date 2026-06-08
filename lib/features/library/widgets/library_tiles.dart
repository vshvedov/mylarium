import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_icons.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/theme/design_tokens.dart';
import '../../../app/widgets/pressable_scale.dart';
import '../../offline/offline_providers.dart';
import 'cover_image.dart';

/// Horizontal peek of each back card in a [CoverTile] deck (series only).
const double _deckStep = 5;

/// Vertical inset of each back card, so deeper cards read as shorter "pages".
const double _deckVStep = 4;

/// Width reserved on the right of a stacked cover for the deck to peek into, so
/// the whole stack still fits the tile's existing footprint.
const double _deckExtent = 2 * _deckStep;

/// A cover tile: rounded cover image with a title/subtitle beneath. Used in
/// grids and horizontal rails. The cover keeps a 0.7 aspect (comic portrait),
/// sits on a subtle elevation, and scales briefly on press (with a light
/// haptic) instead of a Material ripple.
///
/// When [stacked] is true the cover is drawn as the top of a small "deck" of
/// books (two neutral cards peeking along the right edge), so a multi-book
/// series reads differently from a single chapter. Pass it only for series
/// tiles; books stay flat.
class CoverTile extends StatelessWidget {
  const CoverTile({
    super.key,
    required this.sourceId,
    required this.ownerType,
    required this.ownerId,
    required this.title,
    this.subtitle,
    this.onTap,
    this.onLongPress,
    this.badge,
    this.leadingBadge,
    this.stacked = false,
  });

  final String sourceId;
  final String ownerType;
  final String ownerId;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  /// Opens the item context menu (Pin / Unpin). Fires a selection haptic at
  /// long-press recognition, like [onTap].
  final VoidCallback? onLongPress;

  /// Top-right overlay (e.g. the completed check).
  final Widget? badge;

  /// Top-left overlay (e.g. the offline indicator), kept opposite [badge] so the
  /// two never collide.
  final Widget? leadingBadge;

  /// Whether to render the layered-deck "stack of books" treatment behind the
  /// cover. Reserved for series tiles with more than one book.
  final bool stacked;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<DesignTokens>()!;
    final eink = tokens.isEink;
    final cover = Container(
      key: const ValueKey('coverShadow'),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(tokens.coverRadius),
        boxShadow: tokens.elevation.card,
        border: eink
            ? Border.all(color: Theme.of(context).colorScheme.outlineVariant)
            : null,
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
            if (badge != null) Positioned(top: 6, right: 6, child: badge!),
            if (leadingBadge != null)
              Positioned(top: 6, left: 6, child: leadingBadge!),
          ],
        ),
      ),
    );
    return PressableScale(
      onTap: onTap == null
          ? null
          : () {
              AppHaptics.selection();
              onTap!();
            },
      onLongPress: onLongPress == null
          ? null
          : () {
              AppHaptics.selection();
              onLongPress!();
            },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: stacked ? _Deck(cover: cover) : cover),
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

/// The layered "stack of books" treatment: two neutral cards stepping out along
/// the right edge, with [cover] painted on top. The cover is inset by
/// [_deckExtent] on the right so the whole deck still fits the tile footprint;
/// the back cards sit OUTSIDE the cover's own clip so their shadows render.
class _Deck extends StatelessWidget {
  const _Deck({required this.cover});

  final Widget cover;

  @override
  Widget build(BuildContext context) {
    return Stack(
      key: const ValueKey('coverDeck'),
      clipBehavior: Clip.none,
      children: [
        // Deepest card first so the front cover paints last (on top).
        for (final j in const [2, 1])
          Positioned(
            left: 0,
            right: _deckExtent - j * _deckStep,
            top: j * _deckVStep,
            bottom: j * _deckVStep,
            child: const _DeckCard(),
          ),
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          right: _deckExtent,
          child: cover,
        ),
      ],
    );
  }
}

/// A single neutral "book" behind the cover in a stacked series tile.
class _DeckCard extends StatelessWidget {
  const _DeckCard();

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<DesignTokens>()!;
    return Container(
      key: const ValueKey('deckCard'),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(tokens.coverRadius),
        boxShadow: tokens.elevation.card,
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
    final eink = Theme.of(context).extension<DesignTokens>()?.isEink ?? false;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: eink ? scheme.surface : const Color(0x99000000),
        shape: BoxShape.circle,
        border: eink ? Border.all(color: scheme.onSurface) : null,
      ),
      child: Icon(AppIcons.downloaded,
          size: 13, color: eink ? scheme.onSurface : Colors.white),
    );
  }
}
