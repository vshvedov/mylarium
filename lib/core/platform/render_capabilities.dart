import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'diagnostics_prefs.dart';

part 'render_capabilities.g.dart';

/// Conservative cross-platform GPU max-texture-size floor (driven by weak Android
/// GPUs; GLES2 guarantees only 2048, 4096 is safe on essentially everything).
/// Used until the real device value is probed, and as the fallback when the
/// probe is unavailable (desktop/web) or fails.
const int kFallbackMaxTextureDim = 4096;

/// Upper bound on the focused page's single-texture long edge, independent of
/// what the GPU could hold, to keep one decoded page's RAM (W x H x 4 bytes)
/// sane. A page larger than this is served at this size for now (true region
/// tiling, to reach full native on the very largest scans, is a follow-up).
const int kMaxFocusTextureDim = 8192;

/// GPU sampling quality for reader page textures (bicubic). A single universal
/// value: no device-class guessing (that ages badly as hardware improves).
const FilterQuality kReaderSampling = FilterQuality.high;

const MethodChannel _deviceChannel = MethodChannel('mylarium/device');

/// Probes the GPU max texture size via the platform channel, falling back to
/// [kFallbackMaxTextureDim] when the channel is unavailable (desktop/web) or
/// errors. Isolated so it is easy to reason about and swap in tests.
Future<int> probeMaxTextureSize() async {
  try {
    final v = await _deviceChannel.invokeMethod<int>('maxTextureSize');
    if (v != null && v >= 1024) return v;
  } catch (_) {
    // No native handler (desktop/web) or a probe failure: use the safe floor.
  }
  return kFallbackMaxTextureDim;
}

/// The focused-page decode cap implied by a device's max texture size: the GPU
/// limit, bounded by the RAM-safe focus limit. The page sources still clamp to
/// each page's native width (never upscaled), so this is an upper bound on
/// detail, not a forced resolution.
int focusTextureCap(int maxTextureSize) =>
    maxTextureSize < kMaxFocusTextureDim ? maxTextureSize : kMaxFocusTextureDim;

/// The device's GPU max texture size. Bootstrapped to the safe fallback, then
/// refined from the per-device cache (fast) or a one-time native probe (cached
/// so later launches skip it). The reader watches this so the focused page
/// re-decodes sharper once the real value is known.
@Riverpod(keepAlive: true)
class RenderCapabilities extends _$RenderCapabilities {
  @override
  int build() {
    _resolve();
    return kFallbackMaxTextureDim;
  }

  Future<void> _resolve() async {
    final cached = await DiagnosticsPrefs.readMaxTextureSize();
    if (cached != null && cached >= 1024) {
      state = cached;
      return;
    }
    final probed = await probeMaxTextureSize();
    state = probed;
    await DiagnosticsPrefs.writeMaxTextureSize(probed);
  }
}
