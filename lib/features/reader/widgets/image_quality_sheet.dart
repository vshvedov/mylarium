import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Image quality', style: text.titleMedium),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Smart'),
            subtitle: const Text('Mylarium picks the best quality for your device'),
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
                    Text('Smoother', style: text.labelMedium),
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
                    Text('Sharper', style: text.labelMedium),
                  ],
                ),
                Text(
                  'Sharper looks crisper but uses more memory.',
                  style: text.bodySmall
                      ?.copyWith(color: Theme.of(context).hintColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
