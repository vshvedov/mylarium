import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/l10n.dart';
import '../../app/theme/app_icons.dart';
import '../../app/widgets/ephemeral_storage_banner.dart';
import '../../app/widgets/brand_mark.dart';
import '../../data/source/source_providers.dart';
import '../sources/local/local_providers.dart';
import 'widgets/source_option_card.dart';

/// First-run welcome and source picker. The brand mark and wordmark continue
/// the launch screen; below them the user chooses where their comics come from.
/// Komga and Kavita open their dedicated connect forms; Local files creates the
/// local source immediately and lands on home. Connecting Komga opens the
/// dedicated connect form at `/onboarding/komga`.
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                // Tells testers/users this run is non-persistent, so an in-memory
                // fallback is not mistaken for a normal first run. Self-hides when
                // storage is healthy.
                const EphemeralStorageBanner(
                  margin: EdgeInsets.only(bottom: 24),
                ),
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
                  context.l10n.onboardingTagline,
                  textAlign: TextAlign.center,
                  style: text.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 36),
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 10),
                  child: Text(
                    context.l10n.onboardingChooseSource,
                    style: text.labelLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SourceOptionCard(
                  icon: AppIcons.sourceKomga,
                  title: 'Komga',
                  subtitle: context.l10n.onboardingKomgaSubtitle,
                  onTap: () => context.push('/onboarding/komga'),
                ),
                const SizedBox(height: 12),
                SourceOptionCard(
                  icon: AppIcons.sourceKavita,
                  title: 'Kavita',
                  subtitle: context.l10n.onboardingKavitaSubtitle,
                  onTap: () => context.push('/onboarding/kavita'),
                ),
                const SizedBox(height: 12),
                SourceOptionCard(
                  icon: AppIcons.sourceLocal,
                  title: context.l10n.onboardingLocalTitle,
                  subtitle: context.l10n.onboardingLocalSubtitle,
                  onTap: () async {
                    final service = ref.read(importServiceProvider);
                    final id = await service.ensureLocalSource();
                    ref.read(activeSourceIdProvider.notifier).select(id);
                    if (context.mounted) context.go('/');
                  },
                ),
                const SizedBox(height: 28),
                Text(
                  context.l10n.onboardingMoreSourcesHint,
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
