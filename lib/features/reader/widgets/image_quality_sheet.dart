import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/l10n.dart';
import '../image_quality.dart';

/// Global reader image-quality controls: a Smart switch (Mylarium picks the
/// decode ceiling) and, when Smart is off, a Smoother to Sharper slider. Opened
/// from the reader chrome; changes apply live (the open page re-decodes).
class ImageQualitySheet extends ConsumerWidget {
  const ImageQualitySheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quality = ref.watch(imageQualityControllerProvider);
    final controller = ref.read(imageQualityControllerProvider.notifier);
    final text = Theme.of(context).textTheme;
    final maxLevel = kManualDecodeCeilings.length - 1;

    // Scrollable so the sheet never overflows on short phone screens or in
    // landscape (the sheet caps at roughly half the screen height).
    return SingleChildScrollView(
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.readerImageQuality, style: text.titleMedium),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(context.l10n.qualitySmart),
                subtitle: Text(context.l10n.qualitySmartSubtitle),
                value: quality.smart,
                onChanged: controller.setSmart,
              ),
              // Manual control: only meaningful when Smart is off. Disabled (greyed)
              // while Smart is on so the relationship stays clear.
              AnimatedOpacity(
                opacity: quality.smart ? 0.4 : 1,
                duration: const Duration(milliseconds: 150),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(context.l10n.qualitySmoother,
                            style: text.labelMedium),
                        Expanded(
                          child: Slider(
                            min: 0,
                            max: maxLevel.toDouble(),
                            divisions: maxLevel,
                            value: quality.manualLevel.clamp(0, maxLevel).toDouble(),
                            onChanged: quality.smart
                                ? null
                                : (v) => controller.setManualLevel(v.round()),
                          ),
                        ),
                        Text(context.l10n.qualitySharper,
                            style: text.labelMedium),
                      ],
                    ),
                    Text(
                      context.l10n.qualitySharperHint,
                      style: text.bodySmall
                          ?.copyWith(color: Theme.of(context).hintColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
