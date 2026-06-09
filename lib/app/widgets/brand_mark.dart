import 'package:flutter/material.dart';

import '../theme/app_theme.dart' show kSeed;
import '../theme/design_tokens.dart';

/// The Mylarium "M" monogram, drawn with the same polyline as the launcher icon
/// (`branding/icon-fg.svg`) so onboarding reads as a continuation of the app
/// icon and splash. Violet stroke with a soft glow; theme-independent so it
/// holds up on both light and dark backgrounds.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 72});

  final double size;

  @override
  Widget build(BuildContext context) {
    final eink = Theme.of(context).extension<DesignTokens>()?.isEink ?? false;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MonogramPainter(eink),
        isComplex: false,
        willChange: false,
      ),
    );
  }
}

class _MonogramPainter extends CustomPainter {
  const _MonogramPainter(this.eink);

  final bool eink;

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

    if (eink) {
      // Flat black stroke, no glow, no gradient.
      final stroke = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.16
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = const Color(0xFF000000);
      canvas.drawPath(path, stroke);
      return;
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
  bool shouldRepaint(_MonogramPainter oldDelegate) => oldDelegate.eink != eink;
}

/// The app-bar brand: the "Mylarium" wordmark when it fits the space the app
/// bar gives the title, collapsing to the [BrandMark] monogram on narrow
/// phones where the action icons leave no room for the text. Measures the
/// wordmark at the effective title style (honoring the user's text scale) so
/// the swap happens exactly when the text would no longer fit.
class BrandTitle extends StatelessWidget {
  const BrandTitle({super.key});

  static const _wordmark = 'Mylarium';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style =
        theme.appBarTheme.titleTextStyle ?? theme.textTheme.titleLarge;
    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: _wordmark, style: style),
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
          maxLines: 1,
        )..layout();
        final fits = painter.width <= constraints.maxWidth;
        painter.dispose();
        if (fits) return const Text(_wordmark);
        // scaleDown keeps the monogram intact even when the actions squeeze
        // the title to less than the mark's own size.
        return const Align(
          alignment: AlignmentDirectional.centerStart,
          child: SizedBox(
            height: 36,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: BrandMark(size: 32),
            ),
          ),
        );
      },
    );
  }
}
