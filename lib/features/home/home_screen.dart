import 'package:flutter/material.dart';
import '../../app/theme/app_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/theme_controller.dart';
import '../../app/widgets/app_bottom_sheet.dart';
import '../../app/widgets/app_list_row.dart';
import '../../app/widgets/app_segmented_toggle.dart';
import '../../data/source/source_providers.dart';
import '../library/library_browse_controllers.dart';
import '../library/widgets/library_tiles.dart';
import '../library/widgets/rail.dart';

/// The home shelf: Keep-Reading (On-Deck) plus Recently Added/Updated rails,
/// over the active source. A "Browse" action opens the full virtualized grid.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sourceId = ref.watch(activeSourceIdProvider).valueOrNull;
    final onDeck = ref.watch(onDeckProvider);
    final added = ref.watch(recentlyAddedSeriesProvider);
    final updated = ref.watch(recentlyUpdatedSeriesProvider);

    List<Widget> seriesTiles(List<dynamic> series) => [
          for (final s in series)
            CoverTile(
              sourceId: sourceId ?? '',
              ownerType: 'series',
              ownerId: s.id as String,
              title: s.title as String,
              onTap: () =>
                  context.push('/series/$sourceId/${s.id}'),
            ),
        ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mylarium'),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.search),
            onPressed: () => context.push('/search'),
          ),
          IconButton(
            icon: const Icon(AppIcons.browse),
            tooltip: 'Browse all',
            onPressed: sourceId == null
                ? null
                : () => context.push('/browse/$sourceId'),
          ),
          IconButton(
            icon: const Icon(AppIcons.stats),
            tooltip: 'Reading stats',
            onPressed: () => context.push('/stats'),
          ),
          IconButton(
            icon: const Icon(AppIcons.settings),
            onPressed: () => _openSettings(context, ref),
          ),
        ],
      ),
      body: sourceId == null
          ? const _NoSource()
          : RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(onDeckProvider);
                ref.invalidate(recentlyAddedSeriesProvider);
                ref.invalidate(recentlyUpdatedSeriesProvider);
              },
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 820),
                  child: ListView(
                children: [
                  Rail(
                    title: 'Keep reading',
                    children: [
                      for (final b in onDeck.valueOrNull ?? const [])
                        CoverTile(
                          sourceId: sourceId,
                          ownerType: 'book',
                          ownerId: b.id,
                          title: b.title,
                          subtitle: b.number.isEmpty ? null : 'No. ${b.number}',
                          onTap: () =>
                              context.push('/reader/$sourceId/${b.id}'),
                        ),
                    ],
                  ),
                  Rail(
                    title: 'Recently added',
                    children: seriesTiles(added.valueOrNull ?? const []),
                  ),
                  Rail(
                    title: 'Recently updated',
                    children: seriesTiles(updated.valueOrNull ?? const []),
                  ),
                  if ((onDeck.valueOrNull ?? const []).isEmpty &&
                      (added.valueOrNull ?? const []).isEmpty &&
                      (updated.valueOrNull ?? const []).isEmpty)
                    const _EmptyHome(),
                ],
                  ),
                ),
              ),
            ),
    );
  }

  void _openSettings(BuildContext context, WidgetRef ref) {
    AppBottomSheet.show<void>(
      context,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Appearance',
                style: Theme.of(sheetContext).textTheme.titleMedium),
            const SizedBox(height: 12),
            Consumer(
              builder: (context, ref, _) {
                final mode = ref.watch(themeControllerProvider);
                return AppSegmentedToggle<AppThemeMode>(
                  segments: const [
                    AppSegment(AppThemeMode.light, 'Light'),
                    AppSegment(AppThemeMode.dark, 'Dark'),
                    AppSegment(AppThemeMode.system, 'Auto'),
                  ],
                  selected: mode,
                  onChanged: (m) =>
                      ref.read(themeControllerProvider.notifier).set(m),
                );
              },
            ),
            const SizedBox(height: 16),
            Consumer(
              builder: (context, ref, _) {
                final sourceId =
                    ref.watch(activeSourceIdProvider).valueOrNull;
                return Column(
                  children: [
                    AppListRow(
                      icon: AppIcons.libraries,
                      title: 'Libraries',
                      enabled: sourceId != null,
                      onTap: sourceId == null
                          ? null
                          : () {
                              Navigator.of(sheetContext).pop();
                              context.push('/libraries/$sourceId');
                            },
                    ),
                    AppListRow(
                      icon: AppIcons.collections,
                      title: 'Collections & read lists',
                      enabled: sourceId != null,
                      onTap: sourceId == null
                          ? null
                          : () {
                              Navigator.of(sheetContext).pop();
                              context.push('/collections/$sourceId');
                            },
                    ),
                  ],
                );
              },
            ),
            AppListRow(
              icon: AppIcons.storage,
              title: 'Storage',
              onTap: () {
                Navigator.of(sheetContext).pop();
                context.push('/settings/storage');
              },
            ),
            AppListRow(
              icon: AppIcons.lock,
              title: 'Library locks',
              onTap: () {
                Navigator.of(sheetContext).pop();
                context.push('/settings/library-lock');
              },
            ),
            AppListRow(
              icon: AppIcons.sources,
              title: 'Sources (debug)',
              onTap: () {
                Navigator.of(sheetContext).pop();
                context.push('/debug/sources');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _NoSource extends StatelessWidget {
  const _NoSource();

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(AppIcons.noSource, size: 48),
              const SizedBox(height: 12),
              const Text('No source connected.'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => context.push('/onboarding'),
                child: const Text('Connect a server'),
              ),
            ],
          ),
        ),
      );
}

class _EmptyHome extends StatelessWidget {
  const _EmptyHome();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.all(48),
        child: Center(child: Text('Nothing to show yet. Pull to refresh.')),
      );
}
