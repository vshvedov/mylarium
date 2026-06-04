import 'package:flutter/material.dart';

/// One labelled bar.
class BarDatum {
  const BarDatum(this.label, this.value);
  final String label;
  final int value;
}

/// A minimal vertical bar chart drawn with a [CustomPainter] (no charting
/// dependency). Bars share a baseline; the tallest fills the height. An empty
/// or all-zero series renders a flat baseline.
class BarChart extends StatelessWidget {
  const BarChart({super.key, required this.data, this.height = 140});

  final List<BarDatum> data;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _BarPainter(
          data: data,
          barColor: scheme.primary,
          axisColor: scheme.outlineVariant,
          labelStyle: Theme.of(
            context,
          ).textTheme.labelSmall!.copyWith(color: scheme.onSurfaceVariant),
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _BarPainter extends CustomPainter {
  _BarPainter({
    required this.data,
    required this.barColor,
    required this.axisColor,
    required this.labelStyle,
  });

  final List<BarDatum> data;
  final Color barColor;
  final Color axisColor;
  final TextStyle labelStyle;

  @override
  void paint(Canvas canvas, Size size) {
    const labelBand = 18.0;
    final chartHeight = size.height - labelBand;
    final axisY = chartHeight;
    canvas.drawLine(
      Offset(0, axisY),
      Offset(size.width, axisY),
      Paint()
        ..color = axisColor
        ..strokeWidth = 1,
    );
    if (data.isEmpty) return;

    final maxValue = data.fold<int>(0, (m, d) => d.value > m ? d.value : m);
    final slot = size.width / data.length;
    final barWidth = (slot * 0.6).clamp(2.0, 28.0);
    final paint = Paint()..color = barColor;

    // Only label a sparse subset so ticks never overlap.
    final labelStep = (data.length / 6).ceil().clamp(1, data.length);

    for (var i = 0; i < data.length; i++) {
      final d = data[i];
      final cx = slot * i + slot / 2;
      final h = maxValue == 0 ? 0.0 : (d.value / maxValue) * (chartHeight - 4);
      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(cx - barWidth / 2, axisY - h, barWidth, h),
        topLeft: const Radius.circular(3),
        topRight: const Radius.circular(3),
      );
      canvas.drawRRect(rect, paint);

      if (i % labelStep == 0) {
        final tp = TextPainter(
          text: TextSpan(text: d.label, style: labelStyle),
          textDirection: TextDirection.ltr,
          maxLines: 1,
          ellipsis: '',
        )..layout(maxWidth: slot * labelStep);
        tp.paint(canvas, Offset(cx - tp.width / 2, axisY + 4));
      }
    }
  }

  @override
  bool shouldRepaint(_BarPainter old) =>
      old.data != data || old.barColor != barColor;
}
