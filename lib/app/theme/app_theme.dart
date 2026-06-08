import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'design_tokens.dart';

/// Distinctive violet seed; deliberately not a stock Material blue.
const kSeed = Color(0xFF6B4EFF);

const motionTransitions = PageTransitionsTheme(
  builders: {
    TargetPlatform.android: MylariumPageTransitionsBuilder(),
    TargetPlatform.iOS: MylariumPageTransitionsBuilder(),
  },
);

const noMotionTransitions = PageTransitionsTheme(
  builders: {
    TargetPlatform.android: NoTransitionsBuilder(),
    TargetPlatform.iOS: NoTransitionsBuilder(),
  },
);

/// Bespoke page transition: the entering route fades in and scales up slightly
/// (a calm, cover-forward entry). Incoming-only by design: the covered route is
/// not separately animated (a true fade-through of the outgoing route is a
/// possible later refinement), so [secondaryAnimation] is intentionally unused.
/// Reads the standard motion curve from [DesignTokens] with a const fallback.
class MylariumPageTransitionsBuilder extends PageTransitionsBuilder {
  const MylariumPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curve =
        Theme.of(context).extension<DesignTokens>()?.motion.standard ??
        Curves.easeOutCubic;
    final c = CurvedAnimation(parent: animation, curve: curve);
    return FadeTransition(
      opacity: c,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.97, end: 1.0).animate(c),
        child: child,
      ),
    );
  }
}

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
  ) => child;
}

ThemeData withTransitions(ThemeData theme, PageTransitionsTheme pt) =>
    theme.copyWith(pageTransitionsTheme: pt);

/// Tasteful, light haptics for key interactions. Backed by the platform haptics
/// channel; a silent no-op where unavailable (and under flutter_test).
abstract final class AppHaptics {
  static void selection() => HapticFeedback.selectionClick();
  static void impact() => HapticFeedback.lightImpact();
}

ThemeData _base(Brightness b, {double contrastLevel = 0.0}) {
  final scheme = ColorScheme.fromSeed(
    seedColor: kSeed,
    brightness: b,
    contrastLevel: contrastLevel,
  );
  final tokens = b == Brightness.dark ? DesignTokens.dark : DesignTokens.light;
  // Deeper near-black scaffold in dark so cover art reads as the hero.
  final scaffold = b == Brightness.dark
      ? const Color(0xFF0B0B0E)
      : scheme.surface;
  final theme = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scaffold,
    extensions: <ThemeExtension<dynamic>>[tokens],
    pageTransitionsTheme: motionTransitions,
  );
  // Refined type scale: heavier display/title weights and tighter tracking.
  // copyWith preserves the scheme-derived text colors.
  final t = theme.textTheme;
  return theme.copyWith(
    textTheme: t.copyWith(
      displaySmall: t.displaySmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      headlineSmall: t.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      ),
      titleLarge: t.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      titleMedium: t.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
      ),
    ),
  );
}

/// Hand-built monochrome scheme for e-ink. Not ColorScheme.fromSeed: a gray
/// seed still yields tinted grays. Pure grays only; error is monochrome because
/// B/W panels cannot show red (error state is carried by text and iconography).
const einkScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF000000),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFE2E2E2),
  onPrimaryContainer: Color(0xFF111111),
  secondary: Color(0xFF333333),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFE9E9E9),
  onSecondaryContainer: Color(0xFF111111),
  tertiary: Color(0xFF333333),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFE9E9E9),
  onTertiaryContainer: Color(0xFF111111),
  error: Color(0xFF000000),
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFFE2E2E2),
  onErrorContainer: Color(0xFF111111),
  surface: Color(0xFFFFFFFF),
  onSurface: Color(0xFF111111),
  onSurfaceVariant: Color(0xFF555555),
  surfaceContainerLowest: Color(0xFFFFFFFF),
  surfaceContainerLow: Color(0xFFF7F7F7),
  surfaceContainer: Color(0xFFF0F0F0),
  surfaceContainerHigh: Color(0xFFE9E9E9),
  surfaceContainerHighest: Color(0xFFE2E2E2),
  outline: Color(0xFF6E6E6E),
  outlineVariant: Color(0xFFCFCFCF),
  inverseSurface: Color(0xFF111111),
  onInverseSurface: Color(0xFFFFFFFF),
  inversePrimary: Color(0xFFFFFFFF),
  shadow: Color(0xFF000000),
  scrim: Color(0xFF000000),
);

ThemeData _eink() {
  final theme = ThemeData(
    useMaterial3: true,
    colorScheme: einkScheme,
    scaffoldBackgroundColor: const Color(0xFFFFFFFF),
    extensions: <ThemeExtension<dynamic>>[DesignTokens.eink],
    pageTransitionsTheme: noMotionTransitions,
  );
  // Reuse the heavier display/title weights: bold reads well on e-ink.
  final t = theme.textTheme;
  return theme.copyWith(
    textTheme: t.copyWith(
      displaySmall: t.displaySmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      headlineSmall: t.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      ),
      titleLarge: t.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      titleMedium: t.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
      ),
    ),
  );
}

final einkTheme = _eink();

final lightTheme = _base(Brightness.light);
final darkTheme = _base(Brightness.dark);
final highContrastLightTheme = _base(Brightness.light, contrastLevel: 1.0);
final highContrastDarkTheme = _base(Brightness.dark, contrastLevel: 1.0);
