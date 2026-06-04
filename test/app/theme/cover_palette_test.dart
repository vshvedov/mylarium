import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/theme/cover_palette.dart';

Future<Uint8List> _solidPng(Color color, {int w = 8, int h = 8}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(
    Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble()),
    Paint()..color = color,
  );
  final image = await recorder.endRecording().toImage(w, h);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return data!.buffer.asUint8List();
}

/// An ImageProvider whose load always fails, to exercise the neutral fallback.
class _BrokenImage extends ImageProvider<_BrokenImage> {
  const _BrokenImage();

  @override
  Future<_BrokenImage> obtainKey(ImageConfiguration configuration) async =>
      this;

  @override
  ImageStreamCompleter loadImage(
    _BrokenImage key,
    ImageDecoderCallback decode,
  ) => OneFrameImageStreamCompleter(Future.error(Exception('broken cover')));
}

void main() {
  testWidgets('fromImage extracts a dominant close to a solid fill', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final png = await _solidPng(const Color(0xFFCC3344));
      final palette = await CoverPalette.fromImage(MemoryImage(png));
      expect((palette.dominant.r * 255).round(), closeTo(0xCC, 24));
      expect((palette.dominant.g * 255).round(), closeTo(0x33, 24));
      expect((palette.dominant.b * 255).round(), closeTo(0x44, 24));
    });
  });

  testWidgets('fromImage falls back to neutral when the image fails', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final palette = await CoverPalette.fromImage(const _BrokenImage());
      expect(palette, CoverPalette.neutral);
    });
    tester.takeException();
  });
}
