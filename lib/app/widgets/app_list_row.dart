import 'package:flutter/material.dart';

import '../theme/app_icons.dart';
import '../theme/app_theme.dart' show AppHaptics;
import '../theme/design_tokens.dart';
import 'pressable_scale.dart';

/// A tappable navigation/selection row in the app's card language: a filled,
/// rounded cell with an optional leading icon, a title and one-line subtitle,
/// and a trailing affordance (a chevron by default). Press scales it down with
/// a light haptic. Used for settings, libraries, and collection lists in place
/// of stock [ListTile]s.
class AppListRow extends StatelessWidget {
  const AppListRow({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
    this.onTap,
    this.enabled = true,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;

  /// Replaces the default trailing chevron when set.
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tokens = Theme.of(context).extension<DesignTokens>()!;
    final tappable = enabled && onTap != null;

    final row = Opacity(
      opacity: tappable ? 1.0 : 0.5,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(tokens.coverRadius + 4),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 22, color: scheme.onSurfaceVariant),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            trailing ??
                Transform.flip(
                  flipX: true,
                  child: Icon(
                    AppIcons.back,
                    size: 18,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
          ],
        ),
      ),
    );

    if (!tappable) return row;
    return PressableScale(
      onTap: () {
        AppHaptics.selection();
        onTap!();
      },
      child: row,
    );
  }
}
