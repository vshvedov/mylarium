import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Tap-zone tokens for the reader (used from T4 onward). Carried now so the
/// design-token system is complete.
@immutable
class TapZoneTokens {
  const TapZoneTokens({required this.overlay, required this.edgeFraction});

  final Color overlay;
  final double edgeFraction;

  TapZoneTokens copyWith({Color? overlay, double? edgeFraction}) =>
      TapZoneTokens(
        overlay: overlay ?? this.overlay,
        edgeFraction: edgeFraction ?? this.edgeFraction,
      );

  static TapZoneTokens lerp(TapZoneTokens a, TapZoneTokens b, double t) =>
      TapZoneTokens(
        overlay: Color.lerp(a.overlay, b.overlay, t)!,
        edgeFraction: ui.lerpDouble(a.edgeFraction, b.edgeFraction, t)!,
      );
}

/// Motion tokens: the shared curves and durations the app animates with. Curves
/// are not interpolable, so [lerp] snaps them at the midpoint; durations
/// interpolate.
@immutable
class MotionTokens {
  const MotionTokens({
    required this.standard,
    required this.emphasized,
    required this.short,
    required this.medium,
  });

  final Curve standard;
  final Curve emphasized;
  final Duration short;
  final Duration medium;

  MotionTokens copyWith({
    Curve? standard,
    Curve? emphasized,
    Duration? short,
    Duration? medium,
  }) => MotionTokens(
    standard: standard ?? this.standard,
    emphasized: emphasized ?? this.emphasized,
    short: short ?? this.short,
    medium: medium ?? this.medium,
  );

  static MotionTokens lerp(MotionTokens a, MotionTokens b, double t) =>
      MotionTokens(
        standard: t < 0.5 ? a.standard : b.standard,
        emphasized: t < 0.5 ? a.emphasized : b.emphasized,
        short: Duration(
          milliseconds: ui
              .lerpDouble(a.short.inMilliseconds, b.short.inMilliseconds, t)!
              .round(),
        ),
        medium: Duration(
          milliseconds: ui
              .lerpDouble(a.medium.inMilliseconds, b.medium.inMilliseconds, t)!
              .round(),
        ),
      );
}

/// Elevation tokens: the shadow recipes for raised surfaces. `card` is the
/// subtle lift under cover tiles; `hero` is the heavier lift for hero art.
@immutable
class ElevationTokens {
  const ElevationTokens({required this.card, required this.hero});

  final List<BoxShadow> card;
  final List<BoxShadow> hero;

  ElevationTokens copyWith({List<BoxShadow>? card, List<BoxShadow>? hero}) =>
      ElevationTokens(card: card ?? this.card, hero: hero ?? this.hero);

  static ElevationTokens lerp(ElevationTokens a, ElevationTokens b, double t) =>
      ElevationTokens(
        card: BoxShadow.lerpList(a.card, b.card, t) ?? b.card,
        hero: BoxShadow.lerpList(a.hero, b.hero, t) ?? b.hero,
      );
}

/// Gradient tokens: `coverFallback` is the theme-derived background shown when a
/// cover (or its palette) is unavailable; `scrim` is the top-to-bottom
/// legibility scrim over hero art.
@immutable
class GradientTokens {
  const GradientTokens({required this.coverFallback, required this.scrim});

  final Gradient coverFallback;
  final Gradient scrim;

  GradientTokens copyWith({Gradient? coverFallback, Gradient? scrim}) =>
      GradientTokens(
        coverFallback: coverFallback ?? this.coverFallback,
        scrim: scrim ?? this.scrim,
      );

  static GradientTokens lerp(GradientTokens a, GradientTokens b, double t) =>
      GradientTokens(
        coverFallback:
            Gradient.lerp(a.coverFallback, b.coverFallback, t) ??
            b.coverFallback,
        scrim: Gradient.lerp(a.scrim, b.scrim, t) ?? b.scrim,
      );
}

/// Shared motion recipe (same in light and dark).
const _motion = MotionTokens(
  standard: Curves.easeOutCubic,
  emphasized: Curves.fastOutSlowIn,
  short: Duration(milliseconds: 180),
  medium: Duration(milliseconds: 280),
);

/// Shared legibility scrim over hero art (transparent at the top, ~0.55 black at
/// the bottom). Sized so body text over the darkened hero stays readable.
const _scrim = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0x00000000), Color(0x8C000000)],
  stops: [0.35, 1.0],
);

/// App-specific theme tokens that have no Material slot (reader surfaces,
/// grid metrics, cover typography, motion, elevation, gradients). Wired via
/// [ThemeData.extensions].
@immutable
class DesignTokens extends ThemeExtension<DesignTokens> {
  const DesignTokens({
    required this.readerBackground,
    required this.gridGutter,
    required this.coverRadius,
    required this.sheetRadius,
    required this.tapZones,
    required this.coverTitleStyle,
    required this.coverSubtitleStyle,
    required this.motion,
    required this.elevation,
    required this.gradients,
  });

  final Color readerBackground;
  final double gridGutter;
  final double coverRadius;
  final double sheetRadius;
  final TapZoneTokens tapZones;
  final TextStyle coverTitleStyle;
  final TextStyle coverSubtitleStyle;
  final MotionTokens motion;
  final ElevationTokens elevation;
  final GradientTokens gradients;

  @override
  DesignTokens copyWith({
    Color? readerBackground,
    double? gridGutter,
    double? coverRadius,
    double? sheetRadius,
    TapZoneTokens? tapZones,
    TextStyle? coverTitleStyle,
    TextStyle? coverSubtitleStyle,
    MotionTokens? motion,
    ElevationTokens? elevation,
    GradientTokens? gradients,
  }) => DesignTokens(
    readerBackground: readerBackground ?? this.readerBackground,
    gridGutter: gridGutter ?? this.gridGutter,
    coverRadius: coverRadius ?? this.coverRadius,
    sheetRadius: sheetRadius ?? this.sheetRadius,
    tapZones: tapZones ?? this.tapZones,
    coverTitleStyle: coverTitleStyle ?? this.coverTitleStyle,
    coverSubtitleStyle: coverSubtitleStyle ?? this.coverSubtitleStyle,
    motion: motion ?? this.motion,
    elevation: elevation ?? this.elevation,
    gradients: gradients ?? this.gradients,
  );

  @override
  DesignTokens lerp(ThemeExtension<DesignTokens>? other, double t) {
    if (other is! DesignTokens) return this;
    return DesignTokens(
      readerBackground: Color.lerp(
        readerBackground,
        other.readerBackground,
        t,
      )!,
      gridGutter: ui.lerpDouble(gridGutter, other.gridGutter, t)!,
      coverRadius: ui.lerpDouble(coverRadius, other.coverRadius, t)!,
      sheetRadius: ui.lerpDouble(sheetRadius, other.sheetRadius, t)!,
      tapZones: TapZoneTokens.lerp(tapZones, other.tapZones, t),
      coverTitleStyle: TextStyle.lerp(
        coverTitleStyle,
        other.coverTitleStyle,
        t,
      )!,
      coverSubtitleStyle: TextStyle.lerp(
        coverSubtitleStyle,
        other.coverSubtitleStyle,
        t,
      )!,
      motion: MotionTokens.lerp(motion, other.motion, t),
      elevation: ElevationTokens.lerp(elevation, other.elevation, t),
      gradients: GradientTokens.lerp(gradients, other.gradients, t),
    );
  }

  static const light = DesignTokens(
    readerBackground: Color(0xFFF7F5F2),
    gridGutter: 12.0,
    coverRadius: 10.0,
    sheetRadius: 28.0,
    tapZones: TapZoneTokens(overlay: Color(0x1A000000), edgeFraction: 0.30),
    coverTitleStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.2,
    ),
    coverSubtitleStyle: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.2,
    ),
    motion: _motion,
    elevation: ElevationTokens(
      card: [
        BoxShadow(
          color: Color(0x1A000000),
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ],
      hero: [
        BoxShadow(
          color: Color(0x26000000),
          blurRadius: 24,
          offset: Offset(0, 8),
        ),
      ],
    ),
    gradients: GradientTokens(
      // Dark cinematic hero in both themes (covers are the hero); light text
      // sits over it legibly. The light/dark difference is the app surfaces, not
      // the detail hero band.
      coverFallback: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF2E2B36), Color(0xFF1A1820)],
      ),
      scrim: _scrim,
    ),
  );

  static const dark = DesignTokens(
    readerBackground: Color(0xFF0E0E10),
    gridGutter: 12.0,
    coverRadius: 10.0,
    sheetRadius: 28.0,
    tapZones: TapZoneTokens(overlay: Color(0x1FFFFFFF), edgeFraction: 0.30),
    coverTitleStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.2,
    ),
    coverSubtitleStyle: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.2,
    ),
    motion: _motion,
    elevation: ElevationTokens(
      card: [
        BoxShadow(
          color: Color(0x66000000),
          blurRadius: 16,
          offset: Offset(0, 6),
        ),
      ],
      hero: [
        BoxShadow(
          color: Color(0x80000000),
          blurRadius: 32,
          offset: Offset(0, 12),
        ),
      ],
    ),
    gradients: GradientTokens(
      coverFallback: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF24222B), Color(0xFF0E0E10)],
      ),
      scrim: _scrim,
    ),
  );
}
