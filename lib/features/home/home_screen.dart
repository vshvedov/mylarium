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
import '../library/pin_controllers.dart';
import '../library/widgets/item_context_menu.dart';
import '../library/widgets/library_tiles.dart';
import '../library/widgets/rail.dart';
import '../offline/offline_providers.dart';

/// The home shelf: Keep-Reading (On-Deck) plus Recently Added/Updated rails,
/// over the active source. A "Browse" action opens the full virtualized grid.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sourceId = ref.watch(activeSourceIdProvider).valueOrNull;
    final pinned = ref.watch(pinnedItemsProvider);
    final keepReading = ref.watch(keepReadingProvider);
    final downloaded = ref.watch(downloadedBooksProvider);
    final addedBooks = ref.watch(recentlyAddedBooksProvider);
    final added = ref.watch(recentlyAddedSeriesProvider);
    final updated = ref.watch(recentlyUpdatedSeriesProvider);

    List<Widget> seriesTiles(List<dynamic> series) => [
          for (final s in series)
            CoverTile(
              sourceId: sourceId ?? '',
              ownerType: 'series',
              ownerId: s.id as String,
              title: s.title as String,
              // A multi-book series reads as a "stack of books"; a one-book
              // series stays flat, like a single chapter.
              stacked: (s.booksCount as int) > 1,
              onTap: () =>
                  context.push('/series/$sourceId/${s.id}'),
              onLongPress: () => showItemContextMenu(
                context,
                sourceId: sourceId ?? '',
                ownerType: 'series',
                ownerId: s.id as String,
                title: s.title as String,
              ),
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
                ref.invalidate(keepReadingProvider);
                ref.invalidate(recentlyAddedBooksProvider);
                ref.invalidate(recentlyAddedSeriesProvider);
                ref.invalidate(recentlyUpdatedSeriesProvider);
              },
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 820),
                  child: ListView(
                children: [
                  Rail(
                    title: 'Pinned',
                    children: [
                      for (final e in pinned.valueOrNull ?? const [])
                        CoverTile(
                          sourceId: sourceId,
                          ownerType: e.ownerType,
                          ownerId: e.ownerId,
                          title: e.title,
                          subtitle: e.subtitle,
                          stacked: e.stacked,
                          leadingBadge: e.ownerType == 'book'
                              ? OfflineBadge(
                                  sourceId: sourceId,
                                  bookId: e.ownerId,
                                )
                              : null,
                          onTap: () => context.push(
                            e.ownerType == 'series'
                                ? '/series/$sourceId/${e.ownerId}'
                                : '/book/$sourceId/${e.ownerId}',
                          ),
                          onLongPress: () => showItemContextMenu(
                            context,
                            sourceId: sourceId,
                            ownerType: e.ownerType,
                            ownerId: e.ownerId,
                            title: e.title,
                          ),
                        ),
                    ],
                  ),
                  Rail(
                    title: 'Keep reading',
                    children: [
                      for (final b in keepReading.valueOrNull ?? const [])
                        CoverTile(
                          sourceId: sourceId,
                          ownerType: 'book',
                          ownerId: b.id,
                          title: b.title,
                          subtitle: b.number.isEmpty ? null : 'No. ${b.number}',
                          leadingBadge: OfflineBadge(
                            sourceId: sourceId,
                            bookId: b.id,
                          ),
                          onTap: () =>
                              context.push('/reader/$sourceId/${b.id}'),
                          onLongPress: () => showItemContextMenu(
                            context,
                            sourceId: sourceId,
                            ownerType: 'book',
                            ownerId: b.id,
                            title: b.title,
                          ),
                        ),
                    ],
                  ),
                  Rail(
                    title: 'Recently added chapters',
                    children: [
                      for (final b in addedBooks.valueOrNull ?? const [])
                        CoverTile(
                          sourceId: sourceId,
                          ownerType: 'book',
                          ownerId: b.id,
                          title: b.title,
                          subtitle: b.number.isEmpty ? null : 'No. ${b.number}',
                          leadingBadge: OfflineBadge(
                            sourceId: sourceId,
                            bookId: b.id,
                          ),
                          onTap: () =>
                              context.push('/reader/$sourceId/${b.id}'),
                          onLongPress: () => showItemContextMenu(
                            context,
                            sourceId: sourceId,
                            ownerType: 'book',
                            ownerId: b.id,
                            title: b.title,
                          ),
                        ),
                    ],
                  ),
                  Rail(
                    title: 'Recently added series',
                    children: seriesTiles(added.valueOrNull ?? const []),
                  ),
                  Rail(
                    title: 'Recently updated series',
                    children: seriesTiles(updated.valueOrNull ?? const []),
                  ),
                  Rail(
                    title: 'Downloaded',
                    children: [
                      for (final b in downloaded.valueOrNull ?? const [])
                        CoverTile(
                          sourceId: sourceId,
                          ownerType: 'book',
                          ownerId: b.id,
                          title: b.title,
                          subtitle: b.number.isEmpty ? null : 'No. ${b.number}',
                          onTap: () =>
                              context.push('/reader/$sourceId/${b.id}'),
                          onLongPress: () => showItemContextMenu(
                            context,
                            sourceId: sourceId,
                            ownerType: 'book',
                            ownerId: b.id,
                            title: b.title,
                          ),
                        ),
                    ],
                  ),
                  if ((pinned.valueOrNull ?? const []).isEmpty &&
                      (keepReading.valueOrNull ?? const []).isEmpty &&
                      (downloaded.valueOrNull ?? const []).isEmpty &&
                      (addedBooks.valueOrNull ?? const []).isEmpty &&
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
              title: 'Comic Vine',
              onTap: () {
                Navigator.of(sheetContext).pop();
                context.push('/settings/comic-vine');
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
