import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../app/l10n.dart';

import '../../../app/theme/design_tokens.dart';

/// Minimum side (logical px) before a marquee selection is savable.
const double _kMinSelectionSide = 24;

/// Captures the boundary identified by [boundaryKey] and crops it to
/// [selectionLogical] (in the boundary's local logical coordinates), returning
/// PNG bytes and the crop's pixel dimensions.
///
/// [pixelRatio] is the device pixel ratio: [RenderRepaintBoundary.toImage]
/// rasterizes the layer at `logicalSize * pixelRatio` (screen resolution,
/// independent of any decode headroom), so a capture is screen-resolution WYSIWYG
/// of whatever is rendered (including color correction and the current zoom).
Future<({Uint8List png, int width, int height})> cropBoundaryToPng({
  required GlobalKey boundaryKey,
  required Rect selectionLogical,
  required double pixelRatio,
}) async {
  final boundary =
      boundaryKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: pixelRatio);
  try {
    final src = Rect.fromLTWH(
      selectionLogical.left * pixelRatio,
      selectionLogical.top * pixelRatio,
      selectionLogical.width * pixelRatio,
      selectionLogical.height * pixelRatio,
    );
    final w = src.width.round().clamp(1, image.width);
    final h = src.height.round().clamp(1, image.height);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawImageRect(
      image,
      src,
      Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble()),
      Paint(),
    );
    final picture = recorder.endRecording();
    final cropped = await picture.toImage(w, h);
    try {
      final data = await cropped.toByteData(format: ui.ImageByteFormat.png);
      return (png: data!.buffer.asUint8List(), width: w, height: h);
    } finally {
      cropped.dispose();
      picture.dispose();
    }
  } finally {
    image.dispose();
  }
}

/// Full-screen overlay for selecting a region to capture (macOS-screenshot
/// style): drag a rectangle over the page, or use "Capture whole page" (the
/// accessible, non-pointer path). The page underneath is set to ignore pointers
/// by the reader while this is up, so this overlay's gesture detector is the sole
/// pointer handler (no photo_view gesture-arena contention).
class CaptureOverlay extends StatefulWidget {
  const CaptureOverlay({
    super.key,
    required this.onCancel,
    required this.onSave,
    this.busy = false,
  });

  final VoidCallback onCancel;

  /// Called with the selection rectangle in the overlay's (== boundary's) local
  /// logical coordinates.
  final void Function(Rect selection) onSave;

  /// True while a save is in flight (disables the action buttons).
  final bool busy;

  @override
  State<CaptureOverlay> createState() => _CaptureOverlayState();
}

class _CaptureOverlayState extends State<CaptureOverlay> {
  Offset? _start;
  Offset? _current;
  Size _size = Size.zero;

  Rect? get _selection {
    final start = _start;
    final current = _current;
    if (start == null || current == null) return null;
    return Rect.fromPoints(start, current);
  }

  bool get _savable {
    final s = _selection;
    return s != null &&
        s.width >= _kMinSelectionSide &&
        s.height >= _kMinSelectionSide;
  }

  Offset _clamp(Offset o) => Offset(
        o.dx.clamp(0.0, _size.width),
        o.dy.clamp(0.0, _size.height),
      );

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final eink = einkOf(context);
    // Scrim from the theme (e-ink uses a light, low-ink barrier), never a
    // hardcoded dark color.
    final scrim = eink
        ? kEinkBarrierColor
        : scheme.scrim.withValues(alpha: 0.55);
    return LayoutBuilder(
      builder: (context, constraints) {
        _size = constraints.biggest;
        final selection = _selection;
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: widget.busy
                    ? null
                    : (d) => setState(() {
                          _start = _clamp(d.localPosition);
                          _current = _start;
                        }),
                onPanUpdate: widget.busy
                    ? null
                    : (d) =>
                        setState(() => _current = _clamp(d.localPosition)),
                child: CustomPaint(
                  painter: _ScrimPainter(
                    selection: selection,
                    scrim: scrim,
                    border: scheme.onPrimary,
                  ),
                ),
              ),
            ),
            if (selection == null)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      context.l10n.captureHint,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: scheme.onPrimary,
                          ),
                    ),
                  ),
                ),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _ActionBar(
                savable: _savable && !widget.busy,
                busy: widget.busy,
                onCancel: widget.onCancel,
                onSave: () {
                  final s = _selection;
                  if (s != null) widget.onSave(s);
                },
                onWholePage: widget.busy
                    ? null
                    : () => widget.onSave(Offset.zero & _size),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.savable,
    required this.busy,
    required this.onCancel,
    required this.onSave,
    required this.onWholePage,
  });

  final bool savable;
  final bool busy;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final VoidCallback? onWholePage;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface.withValues(alpha: 0.96),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: busy ? null : onCancel,
                child: Text(context.l10n.cancel),
              ),
              // The trailing pair is the only flex child, so the whole-page
              // label keeps its intrinsic width when it fits and ellipsizes
              // on narrow phones / large text instead of overflowing the bar.
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: TextButton(
                        onPressed: onWholePage,
                        child: Text(
                          context.l10n.captureWholePage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: savable ? onSave : null,
                      child: Text(context.l10n.save),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScrimPainter extends CustomPainter {
  _ScrimPainter({
    required this.selection,
    required this.scrim,
    required this.border,
  });

  final Rect? selection;
  final Color scrim;
  final Color border;

  @override
  void paint(Canvas canvas, Size size) {
    final full = Offset.zero & size;
    // Dim everything, then clear the selection window so the chosen region shows
    // through at full clarity.
    canvas.saveLayer(full, Paint());
    canvas.drawRect(full, Paint()..color = scrim);
    final s = selection;
    if (s != null) {
      canvas.drawRect(s, Paint()..blendMode = BlendMode.clear);
    }
    canvas.restore();
    if (s != null) {
      canvas.drawRect(
        s,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = border,
      );
    }
  }

  @override
  bool shouldRepaint(_ScrimPainter old) =>
      old.selection != selection ||
      old.scrim != scrim ||
      old.border != border;
}
