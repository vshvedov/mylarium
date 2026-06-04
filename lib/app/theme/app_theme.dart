import 'package:flutter/material.dart';

import 'design_tokens.dart';

/// Distinctive violet seed; deliberately not a stock Material blue.
const kSeed = Color(0xFF6B4EFF);

const motionTransitions = PageTransitionsTheme(builders: {
  TargetPlatform.android: ZoomPageTransitionsBuilder(),
  TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
});

const noMotionTransitions = PageTransitionsTheme(builders: {
  TargetPlatform.android: NoTransitionsBuilder(),
  TargetPlatform.iOS: NoTransitionsBuilder(),
});

/// Page transition that renders the destination with no animation. Used when
/// the OS (or the in-app override) requests reduced motion.
class NoTransitionsBuilder extends PageTransitionsBuilder {
  const NoTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      child;
}

ThemeData withTransitions(ThemeData theme, PageTransitionsTheme pt) =>
    theme.copyWith(pageTransitionsTheme: pt);

ThemeData _base(Brightness b, {double contrastLevel = 0.0}) {
  final scheme = ColorScheme.fromSeed(
    seedColor: kSeed,
    brightness: b,
    contrastLevel: contrastLevel,
  );
  final tokens = b == Brightness.dark ? DesignTokens.dark : DesignTokens.light;
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    extensions: <ThemeExtension<dynamic>>[tokens],
    pageTransitionsTheme: motionTransitions,
  );
}

final lightTheme = _base(Brightness.light);
final darkTheme = _base(Brightness.dark);
final highContrastLightTheme = _base(Brightness.light, contrastLevel: 1.0);
final highContrastDarkTheme = _base(Brightness.dark, contrastLevel: 1.0);
