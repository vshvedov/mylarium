import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

/// Resolves [provider] to a [ui.Image] via a one-shot image-stream listener
/// (the listener is removed as soon as the first frame or an error arrives).
///
/// Ownership: the caller owns the returned image. Dispose it only when the
/// provider was a throwaway (e.g. a `ResizeImage` created just for this call);
/// do NOT dispose an image that belongs to a cache-backed provider still in use.
Future<ui.Image> resolveImageProvider(ImageProvider provider) {
  final completer = Completer<ui.Image>();
  final stream = provider.resolve(ImageConfiguration.empty);
  late final ImageStreamListener listener;
  listener = ImageStreamListener(
    (info, _) {
      stream.removeListener(listener);
      if (!completer.isCompleted) completer.complete(info.image);
    },
    onError: (error, stack) {
      stream.removeListener(listener);
      if (!completer.isCompleted) completer.completeError(error, stack);
    },
  );
  stream.addListener(listener);
  return completer.future;
}
