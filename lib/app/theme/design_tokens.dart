import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Tap-zone tokens for the reader (used from T4 onward). Carried now so the
/// design-token system is complete.
@immutable
class TapZoneTokens {
  const TapZoneTokens({required this.overlay, required this.edgeFraction});

  final Color overlay;
  final double edgeFraction;

  TapZoneTokens copyWith({Color? overlay, double? edgeFraction}) => TapZoneTokens(
        overlay: overlay ?? this.overlay,
        edgeFraction: edgeFraction ?? this.edgeFraction,
      );

  static TapZoneTokens lerp(TapZoneTokens a, TapZoneTokens b, double t) =>
      TapZoneTokens(
        overlay: Color.lerp(a.overlay, b.overlay, t)!,
        edgeFraction: ui.lerpDouble(a.edgeFraction, b.edgeFraction, t)!,
      );
}

/// App-specific theme tokens that have no Material slot (reader surfaces,
/// grid metrics, cover typography). Wired via [ThemeData.extensions].
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
  });

  final Color readerBackground;
  final double gridGutter;
  final double coverRadius;
  final double sheetRadius;
  final TapZoneTokens tapZones;
  final TextStyle coverTitleStyle;
  final TextStyle coverSubtitleStyle;

  @override
  DesignTokens copyWith({
    Color? readerBackground,
    double? gridGutter,
    double? coverRadius,
    double? sheetRadius,
    TapZoneTokens? tapZones,
    TextStyle? coverTitleStyle,
    TextStyle? coverSubtitleStyle,
  }) =>
      DesignTokens(
        readerBackground: readerBackground ?? this.readerBackground,
        gridGutter: gridGutter ?? this.gridGutter,
        coverRadius: coverRadius ?? this.coverRadius,
        sheetRadius: sheetRadius ?? this.sheetRadius,
        tapZones: tapZones ?? this.tapZones,
        coverTitleStyle: coverTitleStyle ?? this.coverTitleStyle,
        coverSubtitleStyle: coverSubtitleStyle ?? this.coverSubtitleStyle,
      );

  @override
  DesignTokens lerp(ThemeExtension<DesignTokens>? other, double t) {
    if (other is! DesignTokens) return this;
    return DesignTokens(
      readerBackground: Color.lerp(readerBackground, other.readerBackground, t)!,
      gridGutter: ui.lerpDouble(gridGutter, other.gridGutter, t)!,
      coverRadius: ui.lerpDouble(coverRadius, other.coverRadius, t)!,
      sheetRadius: ui.lerpDouble(sheetRadius, other.sheetRadius, t)!,
      tapZones: TapZoneTokens.lerp(tapZones, other.tapZones, t),
      coverTitleStyle: TextStyle.lerp(coverTitleStyle, other.coverTitleStyle, t)!,
      coverSubtitleStyle:
          TextStyle.lerp(coverSubtitleStyle, other.coverSubtitleStyle, t)!,
    );
  }

  static const light = DesignTokens(
    readerBackground: Color(0xFFF7F5F2),
    gridGutter: 12.0,
    coverRadius: 10.0,
    sheetRadius: 28.0,
    tapZones: TapZoneTokens(overlay: Color(0x1A000000), edgeFraction: 0.30),
    coverTitleStyle:
        TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.2),
    coverSubtitleStyle:
        TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1.2),
  );

  static const dark = DesignTokens(
    readerBackground: Color(0xFF0E0E10),
    gridGutter: 12.0,
    coverRadius: 10.0,
    sheetRadius: 28.0,
    tapZones: TapZoneTokens(overlay: Color(0x1FFFFFFF), edgeFraction: 0.30),
    coverTitleStyle:
        TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.2),
    coverSubtitleStyle:
        TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1.2),
  );
}
