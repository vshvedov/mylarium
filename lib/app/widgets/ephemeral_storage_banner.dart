import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n.dart';
import '../theme/app_icons.dart';
import '../theme/theme_controller.dart';

/// A non-blocking warning shown when the app could not open its on-disk database
/// at boot and fell back to an in-memory one (see [ephemeralStorageProvider]). It
/// makes a broken-storage device observable, distinguishing "storage is broken"
/// from a normal first-run "needs onboarding", with no telemetry.
///
/// Renders nothing (zero height) when storage is healthy, so screens can include
/// it unconditionally. Colors come from the active [ColorScheme], so it adapts to
/// every theme (including the monochrome e-ink theme).
class EphemeralStorageBanner extends ConsumerWidget {
  const EphemeralStorageBanner({
    super.key,
    this.margin = const EdgeInsets.fromLTRB(16, 12, 16, 0),
  });

  /// Outer spacing. Defaults suit a screen edge; pass [EdgeInsets.zero] when the
  /// host already supplies padding (e.g. inside an existing list).
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(ephemeralStorageProvider)) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: margin,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: scheme.errorContainer,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: scheme.error.withValues(alpha: 0.4)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(AppIcons.warning, size: 22, color: scheme.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.storageUnavailableTitle,
                    style: text.titleSmall?.copyWith(
                      color: scheme.onErrorContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.l10n.storageUnavailableBody,
                    style: text.bodySmall
                        ?.copyWith(color: scheme.onErrorContainer),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
