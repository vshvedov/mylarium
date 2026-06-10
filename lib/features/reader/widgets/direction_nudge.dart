import 'package:flutter/material.dart';

import '../../../app/theme/app_icons.dart';

/// First-open reading-direction nudge: a small dismissible pill shown when a
/// book opened left-to-right purely by default (no persisted settings and no
/// direction hint from the source; see `ReaderData.directionUnset`). Manga is
/// usually right-to-left, so it offers a one-tap fix. Both actions persist the
/// per-series settings, so the pill shows at most once per series, ever.
class DirectionNudge extends StatelessWidget {
  const DirectionNudge({
    super.key,
    required this.onRightToLeft,
    required this.onDismiss,
  });

  /// Switch this series to right-to-left (persists via the reader controller).
  final VoidCallback onRightToLeft;

  /// Keep left-to-right and persist the current settings as-is.
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Inverse-surface roles: AA contrast over any page in both themes.
    return Material(
      color: scheme.inverseSurface,
      borderRadius: BorderRadius.circular(24),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 2, top: 2, bottom: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Reading manga? Try right-to-left',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onInverseSurface,
                  ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: onRightToLeft,
              style: TextButton.styleFrom(
                foregroundColor: scheme.inversePrimary,
                // 44px minimum touch target (WCAG).
                minimumSize: const Size(44, 44),
              ),
              child: const Text('Right-to-left'),
            ),
            IconButton(
              icon: const Icon(AppIcons.close, size: 18),
              color: scheme.onInverseSurface,
              tooltip: 'Dismiss',
              // IconButton's default 48x48 constraints cover the 44px target.
              onPressed: onDismiss,
            ),
          ],
        ),
      ),
    );
  }
}
