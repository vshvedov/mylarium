import 'package:flutter/material.dart';

import '../theme/app_theme.dart' show AppHaptics;
import '../theme/design_tokens.dart';

/// One option in an [AppSegmentedToggle].
@immutable
class AppSegment<T> {
  const AppSegment(this.value, this.label);
  final T value;
  final String label;
}

/// The app's single-select pill toggle: a rounded track with the selected
/// segment filled in the brand color. Replaces Material's [SegmentedButton] so
/// toggles read as the same bespoke control everywhere (auth method, theme
/// mode, stats period). Segments share the width equally.
class AppSegmentedToggle<T> extends StatelessWidget {
  const AppSegmentedToggle({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
    this.enabled = true,
  });

  final List<AppSegment<T>> segments;
  final T selected;
  final ValueChanged<T> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          for (final seg in segments) Expanded(child: _seg(context, seg)),
        ],
      ),
    );
  }

  Widget _seg(BuildContext context, AppSegment<T> seg) {
    final scheme = Theme.of(context).colorScheme;
    final isSelected = seg.value == selected;
    final tokens = Theme.of(context).extension<DesignTokens>();
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled
          ? () {
              if (!isSelected) {
                AppHaptics.selection();
                onChanged(seg.value);
              }
            }
          : null,
      child: AnimatedContainer(
        duration: tokens?.motion.short ?? const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? scheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          seg.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: isSelected ? scheme.onPrimary : scheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}
