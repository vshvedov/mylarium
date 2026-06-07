import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

/// Loads and caches the reader's high-quality upscale [ui.FragmentProgram]
/// (Catmull-Rom bicubic). Loaded once on first use; callers create cheap
/// per-paint [ui.FragmentShader] instances from it.
class ReaderUpscaleShader {
  ReaderUpscaleShader._();

  static ui.FragmentProgram? _program;
  static Future<ui.FragmentProgram>? _loading;

  /// The compiled program, or null until [ensureLoaded] has resolved. Painters
  /// fall back to plain drawing while this is null.
  static ui.FragmentProgram? get program => _program;

  /// Kicks off (and de-dupes) loading the shader program. Safe to call often.
  static Future<ui.FragmentProgram> ensureLoaded() {
    final cached = _program;
    if (cached != null) return Future<ui.FragmentProgram>.value(cached);
    return _loading ??= ui.FragmentProgram.fromAsset(
      'lib/features/reader/shaders/reader_upscale.frag',
    ).then((p) {
      _program = p;
      return p;
    });
  }

  /// Paints [image] into [dst] on [canvas] using the Catmull-Rom shader, so an
  /// upscale (dst larger than the image) stays sharp instead of going soft. The
  /// shader samples in destination pixel space, so [dst] must be the actual
  /// on-screen rect (device-resolution painter, no ancestor scale transform).
  static void paintImage(
    Canvas canvas,
    ui.Image image,
    Rect dst,
    ui.FragmentProgram program,
  ) {
    final shader = program.fragmentShader()
      ..setFloat(0, dst.width) // uResolution.x
      ..setFloat(1, dst.height) // uResolution.y
      ..setFloat(2, dst.left) // uOffset.x
      ..setFloat(3, dst.top) // uOffset.y
      ..setFloat(4, image.width.toDouble()) // uTexSize.x
      ..setFloat(5, image.height.toDouble()) // uTexSize.y
      ..setImageSampler(0, image);
    canvas.drawRect(dst, Paint()..shader = shader);
    shader.dispose();
  }
}
