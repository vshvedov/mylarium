import 'dart:io' show Platform;

import 'package:flutter/services.dart';

/// Native channel for Android system-gesture exclusion (no-op on other
/// platforms / older builds). See `MainActivity.kt`.
const MethodChannel _gestureChannel = MethodChannel('mylarium/system_gestures');

/// App-wide fullscreen: hide the top status bar (clock / signal / battery) so the
/// cover-forward UI runs edge to edge, keeping the bottom inset usable. Called
/// once at startup and after returning from the reader.
Future<void> setAppFullscreen() => SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: const [SystemUiOverlay.bottom],
    );

/// Reader immersion: hide every system bar (sticky, so an edge swipe only reveals
/// them transiently instead of leaving the reader), and ask Android to exclude
/// the screen edges from the system back / app-switch gesture so a horizontal
/// page swipe near the edge is not stolen.
Future<void> enterReaderImmersive() async {
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await setReaderGestureExclusion(true);
}

/// Restores the app-wide fullscreen chrome and clears the gesture exclusion.
Future<void> exitReaderImmersive() async {
  await setReaderGestureExclusion(false);
  await setAppFullscreen();
}

/// Toggles the Android system-gesture exclusion for the reader. Android-only;
/// silently a no-op elsewhere or on a build without the native handler so a
/// platform gap can never break the reader.
Future<void> setReaderGestureExclusion(bool enabled) async {
  if (!Platform.isAndroid) return;
  try {
    await _gestureChannel.invokeMethod<void>(
      'setGestureExclusion',
      {'enabled': enabled},
    );
  } on MissingPluginException {
    // Older build without the native channel: immersive-sticky still applies.
  } on PlatformException {
    // Defensive: never let a gesture-exclusion failure surface in the reader.
  }
}
