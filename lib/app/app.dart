import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

class MylariumApp extends ConsumerWidget {
  const MylariumApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reduce =
        ref.watch(reduceMotionProvider) ||
        MediaQuery.disableAnimationsOf(context);
    final pt = reduce ? noMotionTransitions : motionTransitions;
    return MaterialApp.router(
      title: 'Mylarium',
      theme: withTransitions(lightTheme, pt),
      darkTheme: withTransitions(darkTheme, pt),
      highContrastTheme: withTransitions(highContrastLightTheme, pt),
      highContrastDarkTheme: withTransitions(highContrastDarkTheme, pt),
      themeMode: toThemeMode(ref.watch(themeControllerProvider)),
      routerConfig: ref.watch(appRouterProvider),
      // Fold the in-app reduce-motion override and the OS flag into one signal
      // every descendant reads via MediaQuery.disableAnimationsOf (so e.g.
      // PressableScale honors the in-app toggle, not just the OS flag). Goes in
      // builder: so it reaches the routed subtree's MediaQuery.
      builder: (context, child) => reduce
          ? MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: child!,
            )
          : child!,
    );
  }
}
