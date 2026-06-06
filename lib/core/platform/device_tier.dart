import 'dart:io' show Platform;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'device_tier.g.dart';

/// Largest single-texture long edge we ever upload to the GPU. GLES2 guarantees
/// only 2048; 4096 is safe on essentially every modern GPU. Page decodes are
/// clamped to this so a page texture never silently fails to upload. Pages whose
/// native resolution exceeds this are served at this size for now (band tiling to
/// exceed it is a follow-up).
const int kMaxSafeTextureDim = 4096;

/// Device capability class. Drives the focused-page decode cap and the GPU
/// sampling quality so weak hardware stays smooth while normal and high-end
/// devices get full quality.
enum DeviceTier {
  low,
  normal,
  high;

  /// Focused-page decode cap (physical px, long edge). The reader clamps the
  /// actual decode to [kMaxSafeTextureDim] and the page sources never upscale a
  /// page past its native size, so this is an upper bound on detail, not a forced
  /// resolution.
  int get focusCap => switch (this) {
        DeviceTier.low => 2048,
        DeviceTier.normal => 4096,
        // High is forward-looking; the reader clamps to kMaxSafeTextureDim until
        // band tiling lands, at which point this can be served in full.
        DeviceTier.high => 8192,
      };

  /// GPU sampling quality for page rendering. Low tier trades a little sharpness
  /// for cheaper sampling; normal and high use bicubic.
  FilterQuality get sampling =>
      this == DeviceTier.low ? FilterQuality.medium : FilterQuality.high;
}

/// Classifies a device from cheap, always-available signals (logical CPU count
/// and total screen pixels). Pure and unit-tested. A RAM-based refinement via a
/// native channel is a future enhancement; this heuristic is the cross-platform
/// default and is intentionally conservative (defaults to normal, demotes only
/// weak devices to low).
DeviceTier resolveDeviceTier({
  required int processors,
  required int screenPixels,
}) {
  if (processors <= 4) return DeviceTier.low;
  if (processors >= 8 && screenPixels >= 3000000) return DeviceTier.high;
  return DeviceTier.normal;
}

/// The resolved device tier for this launch. Computed once from
/// `Platform.numberOfProcessors` and the implicit view's physical size, with a
/// safe fallback to normal when those signals are unavailable (for example on
/// web, where `dart:io Platform` is not used here).
@Riverpod(keepAlive: true)
DeviceTier deviceTier(Ref ref) {
  final int processors;
  try {
    processors = Platform.numberOfProcessors;
  } catch (_) {
    // Unavailable (for example on web): assume a capable default.
    return DeviceTier.normal;
  }
  final view = WidgetsBinding.instance.platformDispatcher.implicitView;
  final size = view?.physicalSize ?? const Size(2000, 1500);
  final pixels = (size.width * size.height).round();
  return resolveDeviceTier(processors: processors, screenPixels: pixels);
}
