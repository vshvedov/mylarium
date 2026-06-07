import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/features/reader/upscaled_image.dart';

/// Provider that never completes (pending decode).
class _PendingProvider extends ImageProvider<_PendingProvider> {
  @override
  Future<_PendingProvider> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture(this);
  @override
  ImageStreamCompleter loadImage(_PendingProvider key, ImageDecoderCallback d) =>
      OneFrameImageStreamCompleter(Completer<ImageInfo>().future);
  @override
  bool operator ==(Object other) => other is _PendingProvider;
  @override
  int get hashCode => 0;
}

/// Provider that fails to decode.
class _ErrorProvider extends ImageProvider<_ErrorProvider> {
  @override
  Future<_ErrorProvider> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture(this);
  @override
  ImageStreamCompleter loadImage(_ErrorProvider key, ImageDecoderCallback d) =>
      OneFrameImageStreamCompleter(Future<ImageInfo>.error('boom'));
  @override
  bool operator ==(Object other) => other is _ErrorProvider;
  @override
  int get hashCode => 1;
}

void main() {
  testWidgets('shows the loading builder while the page decodes',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: UpscaledImage(
        image: _PendingProvider(),
        loadingBuilder: (_) => const Text('loading'),
        errorBuilder: (_) => const Text('error'),
      ),
    ));
    await tester.pump();
    expect(find.text('loading'), findsOneWidget);
    expect(find.text('error'), findsNothing);
  });

  testWidgets('shows the error builder when the page fails to decode',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: UpscaledImage(
        image: _ErrorProvider(),
        loadingBuilder: (_) => const Text('loading'),
        errorBuilder: (_) => const Text('error'),
      ),
    ));
    await tester.pump(); // deliver the error frame
    await tester.pump();
    expect(find.text('error'), findsOneWidget);
  });
}
