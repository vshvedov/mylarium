import 'package:flutter/material.dart';

import '../../../app/theme/app_icons.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/widgets/pressable_scale.dart';

/// A tap-to-rate row of stars (T3). [value] is 1..[count] or null (unrated);
/// tapping a star sets that rating, and tapping the current rating clears it to
/// null. Uses the app's press-and-haptic feel rather than a Material ripple.
class StarRating extends StatelessWidget {
  const StarRating({
    super.key,
    required this.value,
    required this.onChanged,
    this.count = 5,
    this.size = 28,
    this.readOnly = false,
  });

  final int? value;
  final ValueChanged<int?> onChanged;
  final int count;
  final double size;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final v = value ?? 0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++) _star(context, i, i < v, scheme),
      ],
    );
  }

  Widget _star(BuildContext context, int i, bool filled, ColorScheme scheme) {
    final icon = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Icon(
        filled ? AppIcons.starFill : AppIcons.star,
        size: size,
        color: filled
            ? scheme.primary
            : scheme.onSurfaceVariant.withValues(alpha: 0.45),
      ),
    );
    if (readOnly) return icon;
    return PressableScale(
      onTap: () {
        AppHaptics.selection();
        onChanged(value == i + 1 ? null : i + 1);
      },
      child: Semantics(
        button: true,
        label: '${i + 1} star${i == 0 ? '' : 's'}',
        child: icon,
      ),
    );
  }
}

/// A "Your rating" label paired with the tap-to-rate stars, shared by the book
/// and series detail screens. Ratings are local-only: Komga's API has no
/// user-rating field (see the live-sync PRD, OQ1), so the caption is honest
/// rather than implying a sync that cannot happen.
class RatingRow extends StatelessWidget {
  const RatingRow({super.key, required this.value, required this.onChanged});

  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Your rating',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            StarRating(value: value, onChanged: onChanged, size: 26),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Saved on this device',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}
