import 'package:flutter/material.dart';

import '../../../app/theme/app_icons.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/theme/cover_palette.dart';
import '../../../app/theme/design_tokens.dart';
import '../../../app/widgets/pressable_scale.dart';
import 'cover_image.dart';

/// A floating back affordance for cover-forward detail screens: a light Phosphor
/// icon on a subtle dark scrim, legible over any cover art and the dark bar.
class HeroBackButton extends StatelessWidget {
  const HeroBackButton({super.key});

  @override
  Widget build(BuildContext context) => SafeArea(
    bottom: false,
    child: Padding(
      padding: const EdgeInsets.all(4),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Color(0x66000000),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          iconSize: 20,
          color: Colors.white,
          icon: const Icon(AppIcons.back),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
    ),
  );
}

/// The cover-derived hero: the blurred cover + palette glow ([CoverBackground])
/// over a solid page-background base, with its ALPHA masked to fade to fully
/// transparent toward the bottom. Because the art dissolves to transparent
/// (revealing the exact page colour beneath) rather than blending its colour
/// toward the background, there is no residual tint, no structure and no knee to
/// read as a seam: the texture stays beautiful at the top and vanishes into the
/// page with zero visible transition. Fills its parent (e.g. via Positioned.fill).
class CoverHeroBackdrop extends StatelessWidget {
  const CoverHeroBackdrop({
    super.key,
    required this.sourceId,
    required this.ownerType,
    required this.ownerId,
  });

  final String sourceId;
  final String ownerType;
  final String ownerId;

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;
    // Clip to the leak bounds: the blurred cover is a paint-time overflow (the
    // blur spreads past the layer), and a Stack only clips on *layout* overflow,
    // so without this the blur bleeds below the fade and hard-cuts at the bottom
    // edge as a seam. ClipRect clips unconditionally; the fade has already
    // reached the page colour by the edge, so the clip itself is invisible.
    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: bg),
          ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (rect) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Colors.white, Colors.transparent],
              stops: [0.0, 0.35, 1.0],
            ).createShader(rect),
            child: CoverBackground(
              sourceId: sourceId,
              ownerType: ownerType,
              ownerId: ownerId,
              showBlurredCover: true,
              showScrim: false,
            ),
          ),
        ],
      ),
    );
  }
}

/// The sharp cover for a detail hero: a comic-ratio card on the hero elevation.
class HeroCover extends StatelessWidget {
  const HeroCover({
    super.key,
    required this.sourceId,
    required this.ownerType,
    required this.ownerId,
    required this.title,
    required this.width,
  });

  final String sourceId;
  final String ownerType;
  final String ownerId;
  final String title;
  final double width;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<DesignTokens>()!;
    return Container(
      width: width,
      height: width / 0.7,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(tokens.coverRadius),
        boxShadow: tokens.elevation.hero,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(tokens.coverRadius),
        child: CoverImage(
          sourceId: sourceId,
          ownerType: ownerType,
          ownerId: ownerId,
          title: title,
        ),
      ),
    );
  }
}

/// A calm metadata pill used in detail headers (issue number, page count,
/// status, progress). [accent] tints it with the primary color.
class DetailPill extends StatelessWidget {
  const DetailPill(this.label, {super.key, this.accent = false});

  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = accent
        ? scheme.primary.withValues(alpha: 0.16)
        : scheme.onSurface.withValues(alpha: 0.08);
    final fg = accent ? scheme.primary : scheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Visual emphasis for [HeroAction].
enum HeroActionStyle { primary, ghost }

/// A bespoke detail-screen action: the app's [PressableScale] press-and-haptic
/// feel (not a Material ripple) on a tinted gradient pill ([HeroActionStyle.
/// primary]) or a calm bordered pill ([HeroActionStyle.ghost]). Cinematic rather
/// than stock Material. Stretches to its parent unless [compact].
class HeroAction extends StatelessWidget {
  const HeroAction({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.style = HeroActionStyle.primary,
    this.compact = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final HeroActionStyle style;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final primary = style == HeroActionStyle.primary;
    final fg = primary ? scheme.onPrimary : scheme.onSurface;
    final radius = BorderRadius.circular(14);
    final decoration = primary
        ? BoxDecoration(
            borderRadius: radius,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.lerp(scheme.primary, Colors.white, 0.16)!,
                scheme.primary,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withValues(alpha: 0.42),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          )
        : BoxDecoration(
            borderRadius: radius,
            color: scheme.onSurface.withValues(alpha: 0.06),
            border: Border.all(color: scheme.onSurface.withValues(alpha: 0.16)),
          );

    final content = Row(
      mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: fg),
        const SizedBox(width: 9),
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: fg,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );

    return PressableScale(
      onTap: onPressed == null
          ? null
          : () {
              AppHaptics.selection();
              onPressed!();
            },
      child: Container(
        decoration: decoration,
        padding: compact
            ? const EdgeInsets.symmetric(horizontal: 14, vertical: 9)
            : const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: content,
      ),
    );
  }
}

/// Cover-forward detail header shared by the series and book detail screens.
///
/// A cinematic blurred-cover hero with the title centered over it (always shown
/// in full, wrapping as needed), fading into the page. Below sits the sharp
/// cover with [pills], optional [actions] and [summary]: a centered stack on
/// phones, and a cover-left / content-right two-column on tablet widths so wide
/// screens are filled rather than left empty.
class DetailHeader extends StatelessWidget {
  const DetailHeader({
    super.key,
    required this.sourceId,
    required this.ownerType,
    required this.ownerId,
    required this.title,
    required this.pills,
    this.actions,
    this.summary,
    this.details,
  });

  final String sourceId;
  final String ownerType;
  final String ownerId;
  final String title;
  final List<Widget> pills;
  final Widget? actions;
  final Widget? summary;

  /// An extra section rendered inside the metadata block (below the pills /
  /// summary), e.g. the Comic Vine panel.
  final Widget? details;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 560;
        final coverW = wide ? 188.0 : 152.0;

        final titleStyle = TextStyle(
          fontFamily: 'Anton',
          fontSize: wide ? 48 : 34,
          color: Colors.white,
          height: 1.04,
          letterSpacing: 0.5,
          shadows: const [
            Shadow(color: Color(0xCC000000), blurRadius: 18, offset: Offset(0, 3)),
          ],
        );

        // A shorter title band over the cover-derived backdrop.
        final titleBand = Padding(
          padding: EdgeInsets.fromLTRB(24, topInset + 22, 24, 0),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: wide ? 116 : 100),
            child: Center(
              child: Text(title, textAlign: TextAlign.center, style: titleStyle),
            ),
          ),
        );

        final cover = HeroCover(
          sourceId: sourceId,
          ownerType: ownerType,
          ownerId: ownerId,
          title: title,
          width: coverW,
        );

        final pillRow = Wrap(
          alignment: wide ? WrapAlignment.start : WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: pills,
        );

        final info = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: wide
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.stretch,
          children: [
            pillRow,
            if (actions != null) ...[
              const SizedBox(height: 20),
              wide
                  ? ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: actions,
                    )
                  : actions!,
            ],
            if (summary != null) ...[const SizedBox(height: 18), summary!],
            if (details != null) ...[const SizedBox(height: 18), details!],
          ],
        );

        final body = wide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  cover,
                  const SizedBox(width: 24),
                  Expanded(child: info),
                ],
              )
            : Column(
                children: [
                  Center(child: cover),
                  const SizedBox(height: 18),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: info,
                    ),
                  ),
                ],
              );

        // The light leak: a blurred backdrop behind the title and the top of the
        // cover, fading fully into the page above the dense metadata content.
        final leakHeight = topInset + (wide ? 340.0 : 300.0);

        return Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: leakHeight,
              child: CoverHeroBackdrop(
                sourceId: sourceId,
                ownerType: ownerType,
                ownerId: ownerId,
              ),
            ),
            Column(
              children: [
                titleBand,
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 40, 20, 8),
                  child: body,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
