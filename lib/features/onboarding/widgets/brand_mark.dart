import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart' show kSeed;

/// The Mylarium "M" monogram, drawn with the same polyline as the launcher icon
/// (`branding/icon-fg.svg`) so onboarding reads as a continuation of the app
/// icon and splash. Violet stroke with a soft glow; theme-independent so it
/// holds up on both light and dark backgrounds.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 72});

  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _MonogramPainter(),
          isComplex: false,
          willChange: false,
        ),
      );
}

class _MonogramPainter extends CustomPainter {
  // The M from the icon source, in its native 1024 viewBox. Bounding box is
  // x:322..702, y:322..706, so we map that box into the paint area with a
  // small inset and stroke the polyline.
  static const _pts = [
    Offset(322, 706),
    Offset(322, 322),
    Offset(512, 528),
    Offset(702, 322),
    Offset(702, 706),
  ];
  static const _minX = 322.0;
  static const _minY = 322.0;
  static const _spanX = 380.0; // 702 - 322
  static const _spanY = 384.0; // 706 - 322

  @override
  void paint(Canvas canvas, Size size) {
    final inset = size.width * 0.10;
    final w = size.width - inset * 2;
    final h = size.height - inset * 2;

    final path = Path();
    for (var i = 0; i < _pts.length; i++) {
      final p = _pts[i];
      final x = inset + (p.dx - _minX) / _spanX * w;
      final y = inset + (p.dy - _minY) / _spanY * h;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.18
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = kSeed.withValues(alpha: 0.45)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.width * 0.07);
    canvas.drawPath(path, glow);

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.16
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF9B86FF), kSeed],
      ).createShader(Offset.zero & size);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(_MonogramPainter oldDelegate) => false;
}
