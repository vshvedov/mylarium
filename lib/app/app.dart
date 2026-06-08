import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

class MylariumApp extends ConsumerWidget {
  const MylariumApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeControllerProvider);
    final eink = mode == AppThemeMode.eink;
    // E-ink must never animate routes; fold it into the reduce-motion signal.
    final reduce =
        eink ||
        ref.watch(reduceMotionProvider) ||
        MediaQuery.disableAnimationsOf(context);
    final pt = reduce ? noMotionTransitions : motionTransitions;
    // In e-ink, supply the monochrome theme for every slot so neither OS dark
    // nor OS high-contrast can swap in the violet themes.
    final light = eink ? einkTheme : lightTheme;
    final dark = eink ? einkTheme : darkTheme;
    final hcLight = eink ? einkTheme : highContrastLightTheme;
    final hcDark = eink ? einkTheme : highContrastDarkTheme;
    return MaterialApp.router(
      title: 'Mylarium',
      theme: withTransitions(light, pt),
      darkTheme: withTransitions(dark, pt),
      highContrastTheme: withTransitions(hcLight, pt),
      highContrastDarkTheme: withTransitions(hcDark, pt),
      themeMode: toThemeMode(mode),
      routerConfig: ref.watch(appRouterProvider),
      builder: (context, child) => reduce
          ? MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: child!,
            )
          : child!,
    );
  }
}
