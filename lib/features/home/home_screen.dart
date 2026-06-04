import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/design_tokens.dart';
import '../../app/theme/theme_controller.dart';
import '../../app/widgets/app_bottom_sheet.dart';
import '../../app/widgets/app_button.dart';
import '../../app/widgets/app_card.dart';
import '../../app/widgets/app_grid.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeControllerProvider);
    final tokens = Theme.of(context).extension<DesignTokens>()!;
    return Scaffold(
      appBar: AppBar(title: const Text('Mylarium')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<AppThemeMode>(
            segments: const [
              ButtonSegment(value: AppThemeMode.light, label: Text('Light')),
              ButtonSegment(value: AppThemeMode.dark, label: Text('Dark')),
              ButtonSegment(value: AppThemeMode.system, label: Text('Auto')),
            ],
            selected: {mode},
            multiSelectionEnabled: false,
            showSelectedIcon: false,
            onSelectionChanged: (s) =>
                ref.read(themeControllerProvider.notifier).set(s.first),
          ),
          const SizedBox(height: 16),
          AppGrid(
            children: [
              for (var i = 1; i <= 6; i++)
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Spacer(),
                      Text('Series $i', style: tokens.coverTitleStyle),
                      Text('Vol. 1', style: tokens.coverSubtitleStyle),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Open sheet',
            onPressed: () => AppBottomSheet.show<void>(
              context,
              builder: (_) => const SizedBox(
                height: 160,
                child: Center(child: Text('Sheet')),
              ),
            ),
          ),
          const SizedBox(height: 8),
          AppButton(
            label: 'Continue',
            kind: AppButtonKind.tonal,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
