import 'package:flutter/material.dart';

/// A GitHub-style daily reading heatmap for the trailing [weeks] weeks, drawn
/// with a [CustomPainter]. Each cell is one local day; colour intensity scales
/// with that day's pages relative to the busiest day.
class Heatmap extends StatelessWidget {
  const Heatmap({super.key, required this.pagesByDay, this.weeks = 26});

  /// Local-midnight day -> pages read.
  final Map<DateTime, int> pagesByDay;
  final int weeks;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 7 * 14.0,
      child: CustomPaint(
        painter: _HeatmapPainter(
          pagesByDay: pagesByDay,
          weeks: weeks,
          base: scheme.surfaceContainerHighest,
          accent: scheme.primary,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _HeatmapPainter extends CustomPainter {
  _HeatmapPainter({
    required this.pagesByDay,
    required this.weeks,
    required this.base,
    required this.accent,
  });

  final Map<DateTime, int> pagesByDay;
  final int weeks;
  final Color base;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final maxPages = pagesByDay.values.fold<int>(0, (m, v) => v > m ? v : m);
    const gap = 3.0;
    final cell = ((size.height - gap * 6) / 7).clamp(6.0, 16.0);
    final step = cell + gap;

    // End on today; walk back to the start of the grid (Monday-aligned).
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final totalDays = weeks * 7;
    final start = today.subtract(Duration(days: totalDays - 1));
    // Align the first column to Monday.
    final aligned = start.subtract(
      Duration(days: start.weekday - DateTime.monday),
    );

    final paint = Paint();
    var col = 0;
    var cursor = aligned;
    while (!cursor.isAfter(today)) {
      for (var row = 0; row < 7; row++) {
        final day = cursor.add(Duration(days: row));
        if (day.isAfter(today)) continue;
        final pages = pagesByDay[DateTime(day.year, day.month, day.day)] ?? 0;
        final t = maxPages == 0 ? 0.0 : (pages / maxPages).clamp(0.0, 1.0);
        paint.color = pages == 0
            ? base
            : Color.lerp(base, accent, 0.25 + 0.75 * t)!;
        final x = col * step;
        final y = row * step;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, cell, cell),
            const Radius.circular(2),
          ),
          paint,
        );
      }
      col += 1;
      cursor = cursor.add(const Duration(days: 7));
    }
  }

  @override
  bool shouldRepaint(_HeatmapPainter old) => old.pagesByDay != pagesByDay;
}
