import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/features/reader/color/color_corrected_image_provider.dart';
import 'package:mylarium/features/reader/color/color_settings.dart';
import 'package:mylarium/features/reader/page_source.dart';

/// A value-equal solid-color image provider for exercising the decorator.
@immutable
class _SolidImageProvider extends ImageProvider<_SolidImageProvider> {
  const _SolidImageProvider(this.id, this.size, this.fill);
  final String id;
  final int size;
  final int fill;

  @override
  Future<_SolidImageProvider> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture<_SolidImageProvider>(this);

  @override
  ImageStreamCompleter loadImage(
    _SolidImageProvider key,
    ImageDecoderCallback decode,
  ) =>
      OneFrameImageStreamCompleter(_load());

  Future<ImageInfo> _load() async {
    final px = Uint8List(size * size * 4);
    for (var i = 0; i < px.length; i += 4) {
      px[i] = fill;
      px[i + 1] = fill;
      px[i + 2] = fill;
      px[i + 3] = 255;
    }
    final c = Completer<ui.Image>();
    ui.decodeImageFromPixels(px, size, size, ui.PixelFormat.rgba8888, c.complete);
    return ImageInfo(image: await c.future, scale: 1.0);
  }

  @override
  bool operator ==(Object other) =>
      other is _SolidImageProvider &&
      other.id == id &&
      other.size == size &&
      other.fill == fill;

  @override
  int get hashCode => Object.hash(id, size, fill);
}

class _FakePageSource implements PageSource {
  @override
  int get pageCount => 3;

  @override
  ImageProvider imageProvider(int i) => _SolidImageProvider('p$i', 2, 100);

  @override
  Future<ImageProvider> page(int i) async => imageProvider(i);

  @override
  double? aspectRatio(int i) => 0.5;

  @override
  Set<int> get widePages => const {1};
}

Future<ui.Image> _resolve(ImageProvider provider) {
  final completer = Completer<ui.Image>();
  final stream = provider.resolve(ImageConfiguration.empty);
  late final ImageStreamListener listener;
  listener = ImageStreamListener((info, _) {
    stream.removeListener(listener);
    if (!completer.isCompleted) completer.complete(info.image);
  }, onError: (e, s) {
    stream.removeListener(listener);
    if (!completer.isCompleted) completer.completeError(e, s);
  });
  stream.addListener(listener);
  return completer.future;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final base = _FakePageSource();

  group('colorCorrectedSource', () {
    test('returns the base unchanged for an identity residual', () {
      expect(
        identical(colorCorrectedSource(base, ColorAdjustments.identity), base),
        isTrue,
      );
    });

    test('wraps in a ColorCorrectingPageSource for a non-identity residual', () {
      final s = colorCorrectedSource(base, const ColorAdjustments(gamma: 1.5));
      expect(s, isA<ColorCorrectingPageSource>());
      expect(s.pageCount, 3);
      expect(s.aspectRatio(0), 0.5); // delegated, not re-derived
      expect(s.widePages, {1});
    });
  });

  group('ColorCorrectedImageProvider', () {
    test('is value-equal over (base, signature)', () {
      const adj = ColorAdjustments(gamma: 1.5);
      final a = ColorCorrectedImageProvider(base.imageProvider(0), adj);
      final b = ColorCorrectedImageProvider(base.imageProvider(0), adj);
      expect(a, b);
      expect(a.hashCode, b.hashCode);

      final c = ColorCorrectedImageProvider(
          base.imageProvider(0), const ColorAdjustments(gamma: 2.0));
      expect(a, isNot(c));
    });

    test('resolves to a corrected image of the same dimensions', () async {
      final provider = ColorCorrectedImageProvider(
        base.imageProvider(0),
        const ColorAdjustments(gamma: 2.0),
      );
      final image = await _resolve(provider);
      expect(image.width, 2);
      expect(image.height, 2);
    });
  });
}
