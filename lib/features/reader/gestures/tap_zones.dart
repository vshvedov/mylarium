import 'dart:ui' show Offset;

import '../reader_models.dart';

/// Resolves a normalized tap position (x, y in [0,1]) to a [TapAction] for a
/// given preset, honoring invert and reading direction.
///
/// A center box (x in [0.4,0.6] and y in [0.4,0.6]) always toggles chrome in
/// every preset so the user can reach the overlay regardless of preset.
TapAction resolveTapZone({
  required Offset normalized,
  required TapZonePreset preset,
  required bool invert,
  required bool rtl,
}) {
  final x = normalized.dx;
  final y = normalized.dy;

  if (x >= 0.4 && x <= 0.6 && y >= 0.4 && y <= 0.6) {
    return TapAction.toggleChrome;
  }

  TapAction action;
  switch (preset) {
    case TapZonePreset.lrEdges:
      action = x < 0.30
          ? TapAction.prev
          : (x > 0.70 ? TapAction.next : TapAction.toggleChrome);
    case TapZonePreset.lmr:
      action = x < 1 / 3
          ? TapAction.prev
          : (x > 2 / 3 ? TapAction.next : TapAction.toggleChrome);
    case TapZonePreset.kindleStyle:
      action = x < 0.30 ? TapAction.prev : TapAction.next;
    case TapZonePreset.edgeTopBottom:
      action = y < 0.5 ? TapAction.prev : TapAction.next;
    case TapZonePreset.halves:
      action = x < 0.5 ? TapAction.prev : TapAction.next;
  }

  // RTL flips the horizontal presets (edgeTopBottom is vertical, untouched).
  if (rtl && preset != TapZonePreset.edgeTopBottom) {
    action = _flip(action);
  }
  if (invert) action = _flip(action);
  return action;
}

TapAction _flip(TapAction a) => switch (a) {
      TapAction.prev => TapAction.next,
      TapAction.next => TapAction.prev,
      TapAction.toggleChrome => TapAction.toggleChrome,
    };
