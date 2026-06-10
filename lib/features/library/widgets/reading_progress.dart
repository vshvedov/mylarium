import 'package:flutter/material.dart';

import '../../../app/l10n.dart';

/// A thin determinate progress bar: theme-primary fill on a surface track,
/// rounded caps. Pure rendering; pass a 0..1 [value]. Spans the full width its
/// parent gives it (under a cover tile, or as the strip overlay on a cover).
class ReadingProgressBar extends StatelessWidget {
  const ReadingProgressBar({super.key, required this.value, this.height = 4});

  /// Fractional progress, clamped to 0..1 at render time.
  final double value;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(height / 2);
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: radius,
      ),
      child: FractionallySizedBox(
        alignment: AlignmentDirectional.centerStart,
        widthFactor: value.clamp(0.0, 1.0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.primary,
            borderRadius: radius,
          ),
        ),
      ),
    );
  }
}

/// The page-progress block under a keep-reading cover tile: the thin
/// [ReadingProgressBar] plus a "p. 133 of 219" caption. Renders nothing when
/// the page data is missing or invalid ([total] or [current] not positive), so
/// tiles without progress degrade gracefully instead of showing a broken bar.
class ReadingProgressLabel extends StatelessWidget {
  const ReadingProgressLabel({
    super.key,
    required this.current,
    required this.total,
  });

  /// The 1-based page the reader is on (clamped to [total] for display).
  final int current;

  /// The book's page count.
  final int total;

  @override
  Widget build(BuildContext context) {
    if (total <= 0 || current <= 0) return const SizedBox.shrink();
    final page = current > total ? total : current;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 6),
        ReadingProgressBar(value: page / total),
        const SizedBox(height: 4),
        Text(
          context.l10n.pageProgress(page, total),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
