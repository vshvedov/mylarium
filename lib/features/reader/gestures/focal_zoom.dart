import 'package:flutter/widgets.dart';

/// Pinch-to-zoom + pan + double-tap-to-zoom that anchor on the gesture's focal
/// point (where you pinch / where you double-tap becomes the centre of the
/// zoom), built on [InteractiveViewer] (whose pinch is already focal-correct,
/// unlike photo_view which zooms toward the centre).
///
/// Wraps a single [child] sized to the viewport. Single taps are reported via
/// [onTap] (normalized 0..1) for the reader's tap zones; double-tap toggles
/// between fit and [doubleTapScale], centred on the tap. Zoom state changes are
/// reported via [onZoomChanged] so the caller can gate page swiping.
class FocalZoomViewer extends StatefulWidget {
  const FocalZoomViewer({
    super.key,
    required this.child,
    this.minScale = 1.0,
    this.maxScale = 5.0,
    this.doubleTapZoom = true,
    this.doubleTapScale = 2.5,
    this.onTap,
    this.onZoomChanged,
  });

  final Widget child;
  final double minScale;
  final double maxScale;

  /// When false, double-tap is not captured (so a reader double-tap can read as
  /// two page turns instead).
  final bool doubleTapZoom;

  /// Target scale a double-tap zooms to (from fit). A second double-tap returns
  /// to fit.
  final double doubleTapScale;

  /// Single tap, as a position normalized to the viewport (0..1 on each axis).
  final void Function(Offset normalized)? onTap;

  /// Fired when the zoom crosses between fit (1x) and zoomed-in.
  final ValueChanged<bool>? onZoomChanged;

  @override
  State<FocalZoomViewer> createState() => _FocalZoomViewerState();
}

class _FocalZoomViewerState extends State<FocalZoomViewer>
    with SingleTickerProviderStateMixin {
  final _controller = TransformationController();
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  );
  Animation<Matrix4>? _animation;
  Offset? _doubleTapLocal;
  Offset? _tapLocal;
  bool _zoomed = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onMatrixChanged);
    _anim.addListener(_onAnimTick);
  }

  void _onMatrixChanged() {
    final z = _controller.value.getMaxScaleOnAxis() > 1.001;
    if (z != _zoomed) {
      _zoomed = z;
      widget.onZoomChanged?.call(z);
    }
  }

  void _onAnimTick() {
    final a = _animation;
    if (a != null) _controller.value = a.value;
  }

  void _animateTo(Matrix4 target) {
    _animation = Matrix4Tween(begin: _controller.value, end: target)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));
    _anim.forward(from: 0);
  }

  void _handleDoubleTap() {
    final size = context.size;
    if (size == null) return;
    if (_controller.value.getMaxScaleOnAxis() > 1.001) {
      _animateTo(Matrix4.identity());
      return;
    }
    final p = _doubleTapLocal ?? size.center(Offset.zero);
    final s = widget.doubleTapScale;
    // Scale about p (the tapped point stays put): t = p * (1 - s), clamped so the
    // page still covers the viewport. Matrix4 column-major: scale on the diagonal,
    // translation in the last column.
    final tx = (p.dx * (1 - s)).clamp(size.width * (1 - s), 0.0);
    final ty = (p.dy * (1 - s)).clamp(size.height * (1 - s), 0.0);
    _animateTo(Matrix4(
      s, 0, 0, 0, //
      0, s, 0, 0, //
      0, 0, 1, 0, //
      tx, ty, 0, 1, //
    ));
  }

  @override
  void dispose() {
    _anim.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // onTapDown records the position; onTap (disambiguated against double-tap)
    // acts on it. With doubleTapZoom on, a single tap is delayed until a second
    // tap is ruled out, so a double-tap-to-zoom never also fires a tap zone.
    return GestureDetector(
      onTapDown: widget.onTap == null ? null : (d) => _tapLocal = d.localPosition,
      onTap: widget.onTap == null
          ? null
          : () {
              final size = context.size;
              final p = _tapLocal;
              if (p == null || size == null || size.width == 0 || size.height == 0) {
                return;
              }
              widget.onTap!(Offset(p.dx / size.width, p.dy / size.height));
            },
      onDoubleTapDown:
          widget.doubleTapZoom ? (d) => _doubleTapLocal = d.localPosition : null,
      onDoubleTap: widget.doubleTapZoom ? _handleDoubleTap : null,
      child: InteractiveViewer(
        transformationController: _controller,
        minScale: widget.minScale,
        maxScale: widget.maxScale,
        child: widget.child,
      ),
    );
  }
}
