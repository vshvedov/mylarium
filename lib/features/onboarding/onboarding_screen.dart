import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_icons.dart';
import 'widgets/brand_mark.dart';
import 'widgets/source_option_card.dart';

/// First-run welcome and source picker. The brand mark and wordmark continue
/// the launch screen; below them the user chooses where their comics come from.
/// Komga is connectable today; Kavita and local files are flagged coming-soon
/// until their sources land (the "More sources" phase). Connecting Komga opens
/// the dedicated connect form at `/onboarding/komga`.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      // First run is the root (nothing to pop); when reached as "Add a source"
      // from the running app it is pushed, so offer a way back.
      appBar: context.canPop()
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: IconButton(
                icon: const Icon(AppIcons.back),
                onPressed: () => context.pop(),
              ),
            )
          : null,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
              children: [
                const Center(child: BrandMark(size: 76)),
                const SizedBox(height: 20),
                Text(
                  'Mylarium',
                  textAlign: TextAlign.center,
                  style: text.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your comics and manga, beautifully offline.',
                  textAlign: TextAlign.center,
                  style: text.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 36),
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 10),
                  child: Text(
                    'Choose a source',
                    style: text.labelLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SourceOptionCard(
                  icon: AppIcons.sourceKomga,
                  title: 'Komga',
                  subtitle: 'Connect to your self-hosted server',
                  onTap: () => context.push('/onboarding/komga'),
                ),
                const SizedBox(height: 12),
                SourceOptionCard(
                  icon: AppIcons.sourceKavita,
                  title: 'Kavita',
                  subtitle: 'Another self-hosted library server',
                  onTap: () => context.push('/onboarding/kavita'),
                ),
                const SizedBox(height: 12),
                const SourceOptionCard(
                  icon: AppIcons.sourceLocal,
                  title: 'Local files',
                  subtitle: 'Read comics stored on this device',
                  comingSoon: true,
                ),
                const SizedBox(height: 28),
                Text(
                  'More sources are on the way. You can add or switch '
                  'sources anytime in Settings.',
                  textAlign: TextAlign.center,
                  style: text.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
