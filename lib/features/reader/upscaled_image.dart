import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import 'upscale_shader.dart';

/// Renders a page [ImageProvider] through the reader's high-quality Catmull-Rom
/// upscale shader instead of the engine's default sampler. Used as photo_view's
/// `customChild` (with `filterQuality: none`, so photo_view scales this widget
/// via its Transform): the shader is evaluated at device resolution under that
/// scale, so pinch-zoom stays sharp on every platform (the engine default goes
/// soft on Impeller/Android above 1x).
///
/// Resolves the provider itself (photo_view's loadingBuilder does not run for a
/// customChild), keeps the previous frame while a new provider decodes
/// (gapless), and reports the decoded pixel size so the caller can give
/// photo_view a correctly-proportioned `childSize`.
class UpscaledImage extends StatefulWidget {
  const UpscaledImage({
    super.key,
    required this.image,
    this.fit = BoxFit.contain,
    this.onSize,
    this.loadingBuilder,
    this.errorBuilder,
  });

  final ImageProvider image;

  /// How the page is sized within its box (matches [Image.fit]).
  final BoxFit fit;

  /// Called with the decoded pixel size once known (for `childSize`).
  final ValueChanged<Size>? onSize;
  final WidgetBuilder? loadingBuilder;
  final WidgetBuilder? errorBuilder;

  @override
  State<UpscaledImage> createState() => _UpscaledImageState();
}

class _UpscaledImageState extends State<UpscaledImage> {
  ImageStream? _stream;
  ImageStreamListener? _listener;
  ui.Image? _image;
  Object? _error;
  ui.FragmentProgram? _program;

  /// True if the shader failed to load (e.g. an unsupported backend). We then
  /// fall back to a plain [RawImage] so pages still render, just without the
  /// high-quality upscale.
  bool _shaderFailed = false;

  @override
  void initState() {
    super.initState();
    ReaderUpscaleShader.ensureLoaded().then(
      (p) {
        if (mounted) setState(() => _program = p);
      },
      onError: (Object _) {
        if (mounted) setState(() => _shaderFailed = true);
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolve();
  }

  @override
  void didUpdateWidget(UpscaledImage old) {
    super.didUpdateWidget(old);
    if (widget.image != old.image) _resolve();
  }

  void _resolve() {
    final newStream = widget.image.resolve(createLocalImageConfiguration(context));
    if (newStream.key == _stream?.key) return;
    final listener = ImageStreamListener(_onFrame, onError: _onError);
    _stream?.removeListener(_listener!);
    _stream = newStream;
    _listener = listener;
    newStream.addListener(listener);
  }

  void _onFrame(ImageInfo info, bool _) {
    final img = info.image;
    if (!mounted) {
      img.dispose();
      return;
    }
    setState(() {
      _image = img;
      _error = null;
    });
    widget.onSize?.call(Size(img.width.toDouble(), img.height.toDouble()));
  }

  void _onError(Object error, StackTrace? _) {
    if (mounted) setState(() => _error = error);
  }

  @override
  void dispose() {
    if (_listener != null) _stream?.removeListener(_listener!);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(context) ?? const SizedBox.shrink();
    }
    final image = _image;
    if (image == null) {
      return widget.loadingBuilder?.call(context) ?? const SizedBox.shrink();
    }
    final program = _program;
    if (program == null) {
      // Shader failed to load: fall back to a plain image so the page still
      // shows (the engine's default sampler). Still waiting? show loading.
      if (_shaderFailed) {
        return RawImage(image: image, fit: widget.fit);
      }
      return widget.loadingBuilder?.call(context) ?? const SizedBox.shrink();
    }
    // Paint the page 1:1 at its native pixel size, then let [FittedBox] scale it
    // to the box with [widget.fit]. FittedBox scales via a Transform, under
    // which the shader is still evaluated at device resolution (so it stays
    // sharp), and the intrinsic SizedBox makes this lay out like an [Image].
    final size = Size(image.width.toDouble(), image.height.toDouble());
    return FittedBox(
      fit: widget.fit,
      child: SizedBox.fromSize(
        size: size,
        child: CustomPaint(
          size: size,
          painter: _UpscalePainter(image, program),
        ),
      ),
    );
  }
}

class _UpscalePainter extends CustomPainter {
  _UpscalePainter(this.image, this.program);

  final ui.Image image;
  final ui.FragmentProgram program;

  @override
  void paint(Canvas canvas, Size size) {
    ReaderUpscaleShader.paintImage(canvas, image, Offset.zero & size, program);
  }

  @override
  bool shouldRepaint(_UpscalePainter old) =>
      old.image != image || old.program != program;
}
