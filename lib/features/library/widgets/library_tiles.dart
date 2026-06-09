import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_icons.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/theme/design_tokens.dart';
import '../../../app/widgets/pressable_scale.dart';
import '../../offline/offline_providers.dart';
import '../library_browse_controllers.dart' show bookCompletedProvider;
import 'cover_image.dart';

/// Horizontal peek of each back card in a [CoverTile] deck (series only).
const double _deckStep = 5;

/// Vertical inset of each back card, so deeper cards read as shorter "pages".
const double _deckVStep = 4;

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
    this.cornerOverlay,
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

  /// Top-right corner overlay (the completed "read" fold), drawn flush to the
  /// cover corner and clipped by its radius. Pass a [ReadCorner] when the caller
  /// already knows the read state, or a [BookReadCorner] that resolves it.
  final Widget? cornerOverlay;

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
            if (cornerOverlay != null)
              Positioned(top: 0, right: 0, child: cornerOverlay!),
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

/// The layered "stack of books" treatment: [cover] fills the tile at the same
/// size a flat (chapter) tile uses, with two neutral cards stepping out PAST its
/// right edge so a multi-book series reads as a small deck. The cards overhang
/// the cover's footprint (the Stack does not clip), widening the painted tile by
/// up to `2 * _deckStep`; that overhang lands in the rail separator / grid
/// spacing (both wider than it), so it never collides with a neighbour, and the
/// cover keeps the full thumbnail instead of being cropped narrower than a
/// chapter. The back cards sit OUTSIDE the cover's own clip so their shadows
/// render.
class _Deck extends StatelessWidget {
  const _Deck({required this.cover});

  final Widget cover;

  @override
  Widget build(BuildContext context) {
    return Stack(
      key: const ValueKey('coverDeck'),
      clipBehavior: Clip.none,
      children: [
        // Deepest card first so the front cover paints last (on top). Each card
        // steps further past the right edge (and is inset top/bottom) so deeper
        // cards read as shorter "pages" peeking from behind the cover.
        for (final j in const [2, 1])
          Positioned(
            left: 0,
            right: -j * _deckStep,
            top: j * _deckVStep,
            bottom: j * _deckVStep,
            child: const _DeckCard(),
          ),
        Positioned.fill(child: cover),
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

/// The "read" indicator for a completed book: a right-triangle folded into the
/// top-right corner of a cover, with a bold check inside. Pass as
/// [CoverTile.cornerOverlay]. The fold is a saturated "read" green with a white
/// check (the universal completed convention); the monochrome e-ink theme
/// overrides it to onSurface/surface to stay pure black-and-white.
///
/// Everything is hand-painted by [_CornerFoldPainter]: the fold rounds its own
/// top-right corner to [DesignTokens.coverRadius] (so it matches the cover and
/// can NEVER overhang the edge, independent of any parent clip), and the check
/// is a stroked path (guaranteed bold and centred, with no icon-font weight to
/// depend on).
class ReadCorner extends StatelessWidget {
  const ReadCorner({super.key, this.size = 36});

  /// The "read" green: saturated enough to read as completed over any cover art.
  static const Color _readGreen = Color(0xFF22C55E);

  /// Side length of the square the fold occupies (its legs along the cover's
  /// top and right edges).
  final double size;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<DesignTokens>();
    final eink = tokens?.isEink ?? false;
    final scheme = Theme.of(context).colorScheme;
    final fold = eink ? scheme.onSurface : _readGreen;
    final tick = eink ? scheme.surface : Colors.white;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CornerFoldPainter(
          fold: fold,
          tick: tick,
          cornerRadius: tokens?.coverRadius ?? 10,
        ),
      ),
    );
  }
}

/// Paints the corner fold: a right-triangle (right angle top-right, hypotenuse
/// from top-left to bottom-right) whose top-right corner is rounded to
/// [cornerRadius] so it hugs the cover's own rounded corner with no overhang,
/// plus a bold stroked checkmark centred in the triangle.
class _CornerFoldPainter extends CustomPainter {
  const _CornerFoldPainter({
    required this.fold,
    required this.tick,
    required this.cornerRadius,
  });

  final Color fold;
  final Color tick;
  final double cornerRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final r = cornerRadius.clamp(0, s / 2).toDouble();

    // Triangle with a rounded top-right corner; stays entirely within 0..s, so
    // it cannot extend past the cover edge even if nothing clips it.
    final triangle = Path()
      ..moveTo(0, 0)
      ..lineTo(s - r, 0)
      ..arcToPoint(Offset(s, r), radius: Radius.circular(r))
      ..lineTo(s, s)
      ..close();
    canvas.drawPath(triangle, Paint()..color = fold..isAntiAlias = true);

    // Bold checkmark, sized a touch smaller and placed so its visual centre
    // lands on the triangle centroid (2/3, 1/3), clear of every edge.
    final check = Path()
      ..moveTo(s * 0.55, s * 0.355)
      ..lineTo(s * 0.635, s * 0.445)
      ..lineTo(s * 0.79, s * 0.235);
    canvas.drawPath(
      check,
      Paint()
        ..color = tick
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.078
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(_CornerFoldPainter old) =>
      old.fold != fold || old.tick != tick || old.cornerRadius != cornerRadius;
}

/// A [ReadCorner] that resolves a book's completed state itself, for cover tiles
/// outside series detail (home rails, read lists) that lack a batched read-state
/// watch. Renders nothing until the book reads as completed.
class BookReadCorner extends ConsumerWidget {
  const BookReadCorner({super.key, required this.sourceId, required this.bookId});

  final String sourceId;
  final String bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completed =
        ref.watch(bookCompletedProvider(sourceId, bookId)).valueOrNull ?? false;
    if (!completed) return const SizedBox.shrink();
    return const ReadCorner();
  }
}

/// The download indicator for a book cover, shown top-left. One slot, three
/// states (a book is only ever in one):
///   - downloading (enqueued/running/paused): an animated [_DownloadRing]
///     filling with the real fraction (indeterminate spin until bytes/total are
///     known),
///   - downloaded (a cached archive on disk): a filled blue down-arrow badge,
///     shape-distinct from the green read-check (so it also reads on e-ink),
///   - neither: nothing.
/// Pass as [CoverTile.leadingBadge] for book tiles.
class DownloadBadge extends ConsumerWidget {
  const DownloadBadge({super.key, required this.sourceId, required this.bookId});

  /// The "download" blue: distinct from the green read-check and the app accent.
  static const Color _downloadBlue = Color(0xFF3B82F6);

  final String sourceId;
  final String bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eink = Theme.of(context).extension<DesignTokens>()?.isEink ?? false;
    final scheme = Theme.of(context).colorScheme;
    final accent = eink ? scheme.onSurface : _downloadBlue;
    final onAccent = eink ? scheme.surface : Colors.white;

    final progress =
        ref.watch(downloadProgressProvider(sourceId, bookId)).valueOrNull;
    final state = progress?.state;
    if (state == 'running' || state == 'enqueued' || state == 'paused') {
      final total = progress?.totalBytes ?? 0;
      // Indeterminate until bytes are flowing (still enqueued, or size unknown).
      final value = (state == 'enqueued' || total <= 0)
          ? null
          : (progress!.bytesDownloaded / total).clamp(0.0, 1.0);
      return _DownloadRing(
        value: value,
        ringColor: accent,
        glyphColor: eink ? scheme.onSurface : Colors.white,
        eink: eink,
        scheme: scheme,
      );
    }

    final cached =
        ref.watch(cachedAssetProvider(sourceId, bookId)).valueOrNull;
    if (cached == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: eink ? scheme.surface : accent,
        shape: BoxShape.circle,
        border: eink ? Border.all(color: scheme.onSurface) : null,
      ),
      child: Icon(AppIcons.downloaded, size: 13, color: onAccent),
    );
  }
}

/// A small circular download-progress ring with a down-arrow glyph inside, on a
/// subtle dark backing so it reads over any cover. A null [value] spins
/// indeterminately; a non-null value animates smoothly to the new fraction.
class _DownloadRing extends StatelessWidget {
  const _DownloadRing({
    required this.value,
    required this.ringColor,
    required this.glyphColor,
    required this.eink,
    required this.scheme,
  });

  final double? value;
  final Color ringColor;
  final Color glyphColor;
  final bool eink;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    const double size = 22;
    final track = eink
        ? scheme.surfaceContainerHighest
        : Colors.white.withValues(alpha: 0.25);
    final Widget ring = value == null
        ? CircularProgressIndicator(strokeWidth: 2.5, color: ringColor)
        : TweenAnimationBuilder<double>(
            tween: Tween(end: value),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            builder: (_, v, _) => CircularProgressIndicator(
              value: v,
              strokeWidth: 2.5,
              color: ringColor,
              backgroundColor: track,
            ),
          );
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: eink ? scheme.surface : const Color(0x99000000),
        border: eink ? Border.all(color: scheme.onSurface) : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(padding: const EdgeInsets.all(3), child: ring),
          Icon(AppIcons.download, size: 9, color: glyphColor),
        ],
      ),
    );
  }
}
