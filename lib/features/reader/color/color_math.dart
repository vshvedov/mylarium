import 'dart:math' as math;
import 'dart:typed_data';

import 'color_settings.dart';

/// Per-channel black/white points (normalized 0..1) for an auto-levels stretch.
class Levels {
  const Levels({
    required this.rLo,
    required this.rHi,
    required this.gLo,
    required this.gHi,
    required this.bLo,
    required this.bHi,
  });

  /// The identity stretch (full 0..1 range per channel).
  static const identity =
      Levels(rLo: 0, rHi: 1, gLo: 0, gHi: 1, bLo: 0, bHi: 1);

  final double rLo, rHi, gLo, gHi, bLo, bHi;
}

/// Smallest gap below which a levels stretch for a channel is treated as
/// identity (a flat channel would otherwise divide by ~0).
const double _kLevelsEpsilon = 1e-4;

double _clamp01(double v) => v < 0
    ? 0
    : v > 1
        ? 1
        : v;

/// Builds a 4x5 row-major color matrix (20 floats) for `ColorFilter.matrix`,
/// composing the affine adjustments (contrast, brightness, mode) in pipeline
/// order. Asserts [adj] is affine-only (no gamma, no auto-levels): those are
/// non-linear and handled by the isolate pixel path, not a matrix.
///
/// The engine applies the matrix in 0..255 space with the translation column
/// (index 4 of each row) in 0..255 units, so additive offsets are scaled x255.
List<double> buildMatrix(ColorAdjustments adj) {
  assert(adj.isAffineOnly, 'buildMatrix only handles affine adjustments');
  // Right-to-left application: contrast first, then brightness, then mode.
  final m = _mul(_modeMatrix(adj.mode),
      _mul(_brightnessMatrix(adj.brightness), _contrastMatrix(adj.contrast)));
  return _toColorFilter(m);
}

/// Applies the 4x5 [m] to a single pixel (0..255 channels), clamping to
/// 0..255. Returns a packed ARGB int. Used to cross-check [buildMatrix]
/// against [applyToBytes] in tests.
int applyMatrixToPixel(List<double> m, int r, int g, int b, int a) {
  int row(int o) {
    final v = m[o] * r + m[o + 1] * g + m[o + 2] * b + m[o + 3] * a + m[o + 4];
    final i = v.round();
    return i < 0
        ? 0
        : i > 255
            ? 255
            : i;
  }

  final rr = row(0), gg = row(5), bb = row(10), aa = row(15);
  return (aa << 24) | (rr << 16) | (gg << 8) | bb;
}

/// Applies the full adjustment pipeline to [rgba] in place (RGBA8888,
/// row-major, [width] x [height]). Order: levels -> gamma -> contrast ->
/// brightness -> mode. Alpha is untouched. Pure; runs in a background isolate.
///
/// [levels] (from [computeAutoLevels]) is applied only when [adj.autoLevels];
/// gamma only when `adj.gamma != 1`. The per-channel levels+gamma prefix is
/// precomputed into 256-entry lookup tables, so the inner loop is table
/// lookups plus the affine tail.
void applyToBytes(
  Uint8List rgba,
  int width,
  int height,
  ColorAdjustments adj, {
  Levels? levels,
}) {
  final lv = adj.autoLevels ? (levels ?? Levels.identity) : Levels.identity;
  final lutR = _channelLut(lv.rLo, lv.rHi, adj.gamma);
  final lutG = _channelLut(lv.gLo, lv.gHi, adj.gamma);
  final lutB = _channelLut(lv.bLo, lv.bHi, adj.gamma);
  final c = 1 + adj.contrast; // contrast factor in [0, 2]
  final cOffset = 0.5 - 0.5 * c;
  final brightness = adj.brightness;
  final mode = adj.mode;

  for (var i = 0; i + 3 < rgba.length; i += 4) {
    // levels + gamma (per-channel LUT, normalized output)
    var r = lutR[rgba[i]];
    var g = lutG[rgba[i + 1]];
    var b = lutB[rgba[i + 2]];
    // contrast
    r = r * c + cOffset;
    g = g * c + cOffset;
    b = b * c + cOffset;
    // brightness
    r += brightness;
    g += brightness;
    b += brightness;
    // mode (mixes channels; computed from the pre-clamp affine result)
    switch (mode) {
      case ColorMode.none:
        break;
      case ColorMode.invert:
        r = 1 - r;
        g = 1 - g;
        b = 1 - b;
      case ColorMode.grayscale:
        final y = 0.299 * r + 0.587 * g + 0.114 * b;
        r = y;
        g = y;
        b = y;
      case ColorMode.sepia:
        final nr = 0.393 * r + 0.769 * g + 0.189 * b;
        final ng = 0.349 * r + 0.686 * g + 0.168 * b;
        final nb = 0.272 * r + 0.534 * g + 0.131 * b;
        r = nr;
        g = ng;
        b = nb;
    }
    rgba[i] = (_clamp01(r) * 255).round();
    rgba[i + 1] = (_clamp01(g) * 255).round();
    rgba[i + 2] = (_clamp01(b) * 255).round();
    // alpha (i + 3) untouched
  }
}

/// Computes per-channel auto-levels from [rgba] (RGBA8888). Each channel's lo
/// and hi are the nearest-rank 0.5th and 99.5th percentiles of that channel's
/// own 256-bin histogram (alpha ignored). A degenerate channel (hi <= lo)
/// falls back to the full 0..1 range. Pure; runs in a background isolate.
Levels computeAutoLevels(Uint8List rgba, int width, int height) {
  final hr = Uint32List(256);
  final hg = Uint32List(256);
  final hb = Uint32List(256);
  var n = 0;
  for (var i = 0; i + 3 < rgba.length; i += 4) {
    hr[rgba[i]]++;
    hg[rgba[i + 1]]++;
    hb[rgba[i + 2]]++;
    n++;
  }
  if (n == 0) return Levels.identity;
  final (rLo, rHi) = _channelBounds(hr, n);
  final (gLo, gHi) = _channelBounds(hg, n);
  final (bLo, bHi) = _channelBounds(hb, n);
  return Levels(
    rLo: rLo,
    rHi: rHi,
    gLo: gLo,
    gHi: gHi,
    bLo: bLo,
    bHi: bHi,
  );
}

// --- internals -------------------------------------------------------------

/// Nearest-rank 0.5th / 99.5th percentile bounds for one channel histogram,
/// returned normalized (0..1). Falls back to (0, 1) when degenerate.
(double, double) _channelBounds(Uint32List hist, int n) {
  final loRank = math.max(1, (0.005 * n).ceil());
  final hiRank = math.max(1, (0.995 * n).ceil());
  var cum = 0;
  var lo = 0, hi = 255;
  var gotLo = false;
  for (var v = 0; v < 256; v++) {
    cum += hist[v];
    if (!gotLo && cum >= loRank) {
      lo = v;
      gotLo = true;
    }
    if (cum >= hiRank) {
      hi = v;
      break;
    }
  }
  if (hi <= lo) return (0, 1);
  return (lo / 255, hi / 255);
}

/// A 256-entry LUT mapping an input byte to a normalized value after the
/// per-channel levels stretch then gamma.
Float64List _channelLut(double lo, double hi, double gamma) {
  final lut = Float64List(256);
  final span = hi - lo;
  final stretch = span >= _kLevelsEpsilon;
  final inv = stretch ? 1.0 / span : 1.0;
  final applyGamma = gamma != 1.0;
  final g = applyGamma ? 1.0 / gamma : 1.0;
  for (var x = 0; x < 256; x++) {
    var v = x / 255;
    if (stretch) v = _clamp01((v - lo) * inv);
    if (applyGamma) v = math.pow(v, g).toDouble();
    lut[x] = v;
  }
  return lut;
}

/// 5x5 row-major identity-extended affine matrix multiply (a * b).
List<double> _mul(List<double> a, List<double> b) {
  final out = List<double>.filled(25, 0);
  for (var r = 0; r < 5; r++) {
    for (var c = 0; c < 5; c++) {
      var s = 0.0;
      for (var k = 0; k < 5; k++) {
        s += a[r * 5 + k] * b[k * 5 + c];
      }
      out[r * 5 + c] = s;
    }
  }
  return out;
}

/// Extracts the 4x5 `ColorFilter.matrix` (20 floats) from a 5x5 affine matrix.
List<double> _toColorFilter(List<double> m) => [
      for (var r = 0; r < 4; r++)
        for (var c = 0; c < 5; c++) m[r * 5 + c],
    ];

/// 5x5 identity.
List<double> _identity5() => [
      1, 0, 0, 0, 0, //
      0, 1, 0, 0, 0,
      0, 0, 1, 0, 0,
      0, 0, 0, 1, 0,
      0, 0, 0, 0, 1,
    ];

List<double> _contrastMatrix(double contrast) {
  final c = 1 + contrast;
  final off = (0.5 - 0.5 * c) * 255;
  return [
    c, 0, 0, 0, off, //
    0, c, 0, 0, off,
    0, 0, c, 0, off,
    0, 0, 0, 1, 0,
    0, 0, 0, 0, 1,
  ];
}

List<double> _brightnessMatrix(double brightness) {
  final off = brightness * 255;
  return [
    1, 0, 0, 0, off, //
    0, 1, 0, 0, off,
    0, 0, 1, 0, off,
    0, 0, 0, 1, 0,
    0, 0, 0, 0, 1,
  ];
}

List<double> _modeMatrix(ColorMode mode) {
  switch (mode) {
    case ColorMode.none:
      return _identity5();
    case ColorMode.invert:
      return [
        -1, 0, 0, 0, 255, //
        0, -1, 0, 0, 255,
        0, 0, -1, 0, 255,
        0, 0, 0, 1, 0,
        0, 0, 0, 0, 1,
      ];
    case ColorMode.grayscale:
      const wr = 0.299, wg = 0.587, wb = 0.114;
      return [
        wr, wg, wb, 0, 0, //
        wr, wg, wb, 0, 0,
        wr, wg, wb, 0, 0,
        0, 0, 0, 1, 0,
        0, 0, 0, 0, 1,
      ];
    case ColorMode.sepia:
      return [
        0.393, 0.769, 0.189, 0, 0, //
        0.349, 0.686, 0.168, 0, 0,
        0.272, 0.534, 0.131, 0, 0,
        0, 0, 0, 1, 0,
        0, 0, 0, 0, 1,
      ];
  }
}
