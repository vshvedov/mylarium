import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'color_math.dart';
import 'color_settings.dart';

/// Applies [adj] to [src], returning a new corrected image. The caller owns
/// [src] (never disposed here) and the returned image.
///
/// Identity short-circuits to [src]. Affine-only adjustments are expressible as
/// a GPU color matrix and are NOT meant to flow through here (the reader layers
/// those on at render via `ColorFilter.matrix`); this is the decode-time path
/// for the non-linear residual (gamma, auto-levels). It resolves the raw RGBA
/// on the UI isolate, runs the histogram + pixel transform off the UI isolate
/// via [Isolate.run], then re-encodes the corrected pixels back on the UI
/// isolate.
Future<ui.Image> applyColor(ui.Image src, ColorAdjustments adj) async {
  if (adj.isIdentity) return src;

  final data = await src.toByteData(format: ui.ImageByteFormat.rawRgba);
  if (data == null) return src;
  final w = src.width;
  final h = src.height;
  // Compact, contiguous, sendable copy (toByteData may carry a non-zero offset).
  final px = Uint8List.fromList(
    data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
  );

  // Both the histogram (auto-levels) and the pixel transform run inside the
  // single Isolate.run, off the UI isolate.
  final out = await Isolate.run(() {
    final levels = adj.autoLevels ? computeAutoLevels(px, w, h) : null;
    applyToBytes(px, w, h, adj, levels: levels);
    return px;
  });

  // Re-encode on the UI isolate (decodeImageFromPixels needs the engine).
  final completer = Completer<ui.Image>();
  ui.decodeImageFromPixels(
    out,
    w,
    h,
    ui.PixelFormat.rgba8888,
    completer.complete,
  );
  return completer.future;
}
