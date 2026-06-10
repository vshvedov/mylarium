import 'package:flutter/material.dart';

import '../../../app/l10n.dart';
import '../../../app/theme/app_icons.dart';
import '../../../app/theme/app_theme.dart' show AppHaptics;
import '../../../app/theme/design_tokens.dart';
import '../../../app/widgets/pressable_scale.dart';

/// A premium, tappable source row for the onboarding picker: a tinted icon tile,
/// a title and one-line subtitle, and a trailing affordance (a chevron when
/// available, a "Soon" chip when not). Coming-soon cards are dimmed and inert.
class SourceOptionCard extends StatelessWidget {
  const SourceOptionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.comingSoon = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool comingSoon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tokens = Theme.of(context).extension<DesignTokens>()!;
    final radius = BorderRadius.circular(tokens.coverRadius + 6);
    final enabled = !comingSoon && onTap != null;

    final iconColor = enabled ? scheme.onPrimaryContainer : scheme.onSurfaceVariant;
    final tileColor = enabled
        ? scheme.primaryContainer
        : scheme.surfaceContainerHighest;

    final card = Opacity(
      opacity: enabled ? 1.0 : 0.6,
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh,
          borderRadius: radius,
          border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: tileColor,
                borderRadius: BorderRadius.circular(tokens.coverRadius),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (comingSoon)
              _SoonChip(scheme: scheme)
            else
              // Mirror the back arrow into a trailing chevron (guaranteed-correct
              // Phosphor glyph without guessing a separate codepoint).
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

    if (!enabled) {
      return Semantics(
        button: false,
        enabled: false,
        label: context.l10n.sourceComingSoonSemantic(title),
        child: card,
      );
    }
    return PressableScale(
      onTap: () {
        AppHaptics.selection();
        onTap!();
      },
      child: card,
    );
  }
}

class _SoonChip extends StatelessWidget {
  const _SoonChip({required this.scheme});

  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          context.l10n.sourceSoonChip,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
        ),
      );
}
