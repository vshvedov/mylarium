import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/features/reader/widgets/capture_overlay.dart';

/// Decodes [png] and returns the [r, g, b] (0-255) at pixel (x, y).
Future<List<int>> _pixel(Uint8List png, int x, int y) async {
  final codec = await ui.instantiateImageCodec(png);
  final frame = await codec.getNextFrame();
  final data =
      await frame.image.toByteData(format: ui.ImageByteFormat.rawRgba);
  final bytes = data!.buffer.asUint8List();
  final i = (y * frame.image.width + x) * 4;
  frame.image.dispose();
  return [bytes[i], bytes[i + 1], bytes[i + 2]];
}

Widget _boundary(GlobalKey key, {Widget? wrap}) {
  // Fixed widths (not Expanded): the headless test rasterizer captures flex
  // children as transparent under toImage, so size the halves explicitly.
  Widget page = const SizedBox(
    width: 100,
    height: 100,
    child: Row(
      children: [
        SizedBox(
            width: 50,
            height: 100,
            child: ColoredBox(color: Color(0xFFFF0000))), // left: red
        SizedBox(
            width: 50,
            height: 100,
            child: ColoredBox(color: Color(0xFF0000FF))), // right: blue
      ],
    ),
  );
  if (wrap != null) page = wrap;
  return MaterialApp(
    home: Scaffold(
      body: Center(child: RepaintBoundary(key: key, child: page)),
    ),
  );
}

void main() {
  testWidgets('crops the selected region to the right size and content',
      (tester) async {
    final key = GlobalKey();
    await tester.pumpWidget(_boundary(key));
    await tester.pump();

    late ({Uint8List png, int width, int height}) shot;
    await tester.runAsync(() async {
      shot = await cropBoundaryToPng(
        boundaryKey: key,
        selectionLogical: const Rect.fromLTWH(0, 0, 50, 100), // left half
        pixelRatio: 1,
      );
    });

    expect(shot.width, 50);
    expect(shot.height, 100);

    final rgb = await tester.runAsync(() => _pixel(shot.png, 25, 50));
    // Left half is red.
    expect(rgb![0], greaterThan(200));
    expect(rgb[1], lessThan(60));
    expect(rgb[2], lessThan(60));
  });

  testWidgets('capture bakes in an active color filter (WYSIWYG)',
      (tester) async {
    final key = GlobalKey();
    // Invert matrix: red (255,0,0) -> cyan (0,255,255).
    const invert = ColorFilter.matrix(<double>[
      -1, 0, 0, 0, 255, //
      0, -1, 0, 0, 255, //
      0, 0, -1, 0, 255, //
      0, 0, 0, 1, 0, //
    ]);
    await tester.pumpWidget(_boundary(
      key,
      wrap: const ColorFiltered(
        colorFilter: invert,
        child: SizedBox(width: 100, height: 100, child: ColoredBox(color: Color(0xFFFF0000))),
      ),
    ));
    await tester.pump();

    late ({Uint8List png, int width, int height}) shot;
    await tester.runAsync(() async {
      shot = await cropBoundaryToPng(
        boundaryKey: key,
        selectionLogical: const Rect.fromLTWH(0, 0, 100, 100),
        pixelRatio: 1,
      );
    });

    final rgb = await tester.runAsync(() => _pixel(shot.png, 50, 50));
    // The filter is inside the boundary, so the captured pixel is the INVERTED
    // color (cyan), not the source red.
    expect(rgb![0], lessThan(60)); // r low
    expect(rgb[1], greaterThan(200)); // g high
    expect(rgb[2], greaterThan(200)); // b high
  });
}
