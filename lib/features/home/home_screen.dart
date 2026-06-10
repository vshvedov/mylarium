import 'package:flutter/material.dart';
import '../../app/theme/app_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/theme_controller.dart';
import '../../app/widgets/app_bottom_sheet.dart';
import '../../app/widgets/brand_mark.dart';
import '../../app/widgets/ephemeral_storage_banner.dart';
import '../../app/widgets/app_list_row.dart';
import '../../app/widgets/app_segmented_toggle.dart';
import '../../data/source/content_source.dart';
import '../../data/source/source_providers.dart';
import '../sources/local/folder_home.dart';
import '../sources/local/local_home.dart';
import '../library/library_browse_controllers.dart';
import '../library/pin_controllers.dart';
import '../library/rail_item.dart';
import '../library/widgets/item_context_menu.dart';
import '../library/widgets/library_tiles.dart';
import '../library/widgets/rail.dart';
import '../library/widgets/rail_skeleton.dart';
import '../offline/offline_providers.dart';
import '../sources/source_status_button.dart';
import '../sources/sources_sheet.dart';
import 'home_layout.dart';
import 'home_layout_controller.dart';

/// The home shelf: Keep-Reading (On-Deck) plus Recently Added/Updated rails,
/// over the active source. A "Browse" action opens the full virtualized grid.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sourceId = ref.watch(activeSourceIdProvider).valueOrNull;
    // A local source has no server rails; render the local home body inside
    // the same scaffold and app bar so sources, search, and settings remain
    // accessible. The server tree must not build until the Sources row
    // MATCHING the current id has resolved: building it transiently (boot,
    // hot restart, source switch) spins up api-backed providers that are
    // disposed mid-load a frame later, which riverpod surfaces as an
    // unhandled "disposed during loading state" error.
    final activeSource = ref.watch(activeSourceProvider).valueOrNull;
    final resolved = sourceId == null ||
        (activeSource != null && activeSource.id == sourceId);
    final isLocal = resolved &&
        activeSource != null &&
        activeSource.kind == SourceKind.local.name;
    final isTree = resolved &&
        activeSource != null &&
        activeSource.kind == SourceKind.safTree.name;
    final isDeviceSource = isLocal || isTree;

    return Scaffold(
      appBar: AppBar(
        // Collapses the wordmark to the brand monogram when the action icons
        // leave too little width for the text (narrow phones).
        title: const BrandTitle(),
        actions: [
          if (sourceId != null && resolved && !isDeviceSource)
            SourceStatusButton(sourceId: sourceId),
          // The status button doubles as the visible source affordance on
          // server sources; without this a local/folder-source home has no
          // obvious way to switch sources (the settings-sheet row is too
          // buried).
          if (isDeviceSource)
            IconButton(
              icon: const Icon(AppIcons.sources),
              tooltip: 'Sources',
              onPressed: () => showSourcesSheet(context),
            ),
          IconButton(
            icon: const Icon(AppIcons.search),
            onPressed: () => context.push('/search'),
          ),
          if (!isDeviceSource)
            IconButton(
              icon: const Icon(AppIcons.browse),
              tooltip: 'Browse all',
              onPressed: sourceId == null || !resolved
                  ? null
                  : () => context.push('/browse/$sourceId'),
            ),
          IconButton(
            icon: const Icon(AppIcons.gallery),
            tooltip: 'Gallery',
            onPressed: () => context.push('/gallery'),
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
      body: Column(
        children: [
          // Non-blocking: visible only when the on-disk DB failed to open and we
          // are running in memory only; renders nothing otherwise.
          const EphemeralStorageBanner(),
          Expanded(
            child: sourceId == null
                ? const _NoSource()
                : !resolved
                    // One frame at most while the active row loads; rendering
                    // either real body here would watch providers that the
                    // resolved branch immediately disposes.
                    ? const SizedBox.shrink()
                    : isLocal
                        ? LocalHomeBody(sourceId: sourceId)
                        : isTree
                            ? FolderHomeBody(sourceId: sourceId)
                            : _ServerHomeBody(sourceId: sourceId),
          ),
        ],
      ),
    );
  }

  void _openSettings(BuildContext context, WidgetRef ref) {
    AppBottomSheet.show<void>(
      context,
      // Scrollable so the sheet never overflows on short phone screens (the
      // sheet caps at roughly half the screen height; the row list can exceed
      // that on small phones and in landscape).
      builder: (sheetContext) => SingleChildScrollView(
        child: SafeArea(
          top: false,
          child: Padding(
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
                        AppSegment(AppThemeMode.eink, 'E-ink'),
                      ],
                      selected: mode,
                      onChanged: (m) =>
                          ref.read(themeControllerProvider.notifier).set(m),
                    );
                  },
                ),
                const SizedBox(height: 16),
                AppListRow(
                  icon: AppIcons.options,
                  title: 'Settings',
                  subtitle: 'Home rows and more',
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    context.push('/settings');
                  },
                ),
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
                  icon: AppIcons.sources,
                  title: 'Comic Vine',
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    context.push('/settings/comic-vine');
                  },
                ),
                AppListRow(
                  icon: AppIcons.sources,
                  title: 'Sources',
                  subtitle: 'Switch, add, or remove servers',
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    showSourcesSheet(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The server-source home body: the seven cache/network rails inside a
/// pull-to-refresh list. Kept out of [HomeScreen.build] so the api-backed rail
/// providers are only ever watched for a RESOLVED server source; watching them
/// during a transient (boot, source switch) would dispose them mid-load.
class _ServerHomeBody extends ConsumerWidget {
  const _ServerHomeBody({required this.sourceId});

  final String sourceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Rail providers are keyed by source: switching the active source yields a
    // fresh provider per source, so a switch never renders the previous
    // source's items (and never fetches their covers from the new server).
    final pinned = ref.watch(pinnedItemsProvider(sourceId));
    final keepReading = ref.watch(keepReadingProvider(sourceId));
    final downloaded = ref.watch(downloadedBooksProvider(sourceId));
    final addedBooks = ref.watch(recentlyAddedBooksProvider(sourceId));
    final added = ref.watch(recentlyAddedSeriesProvider(sourceId));
    final updated = ref.watch(recentlyUpdatedSeriesProvider(sourceId));
    final recentRead = ref.watch(recentlyReadProvider(sourceId));
    final visibleRails = ref.watch(visibleHomeRailsProvider);

    // One uniform AsyncValue<List<RailItem>> per rail. The three local rails are
    // adapted here (their providers still emit their native types); the four
    // network rails already emit RailItem.
    final byKind = <HomeRailKind, AsyncValue<List<RailItem>>>{
      HomeRailKind.pinned:
          pinned.whenData((l) => [for (final e in l) RailItem.fromPinned(e)]),
      HomeRailKind.keepReading: keepReading,
      HomeRailKind.recentlyAddedChapters: addedBooks,
      HomeRailKind.recentlyAddedSeries: added,
      HomeRailKind.recentlyUpdatedSeries: updated,
      HomeRailKind.downloaded:
          downloaded.whenData((l) => [for (final b in l) RailItem.fromBookRow(b)]),
      HomeRailKind.recentlyRead:
          recentRead.whenData((l) => [for (final b in l) RailItem.fromBookRow(b)]),
    };

    // The rail's resolved items, or null while it is genuinely still loading
    // (no value yet) so the home can show a skeleton. An error without a value
    // is treated as empty (graceful), not a perpetual skeleton.
    List<RailItem>? itemsFor(HomeRailKind kind) {
      final async = byKind[kind]!;
      return async.valueOrNull ??
          (async.hasError ? const <RailItem>[] : null);
    }

    // A book tile taps into the reader, except a pinned book which opens its
    // detail; a series tile (or pinned series) opens the series. The Downloaded
    // rail omits the offline badge (every item is already offline).
    CoverTile tileFor(HomeRailKind kind, RailItem it) {
      final isBook = it.ownerType == 'book';
      final bookRoute = kind == HomeRailKind.pinned ? 'book' : 'reader';
      return CoverTile(
        sourceId: sourceId,
        ownerType: it.ownerType,
        ownerId: it.ownerId,
        title: it.title,
        subtitle: it.subtitle,
        stacked: it.stacked,
        leadingBadge: (isBook && kind != HomeRailKind.downloaded)
            ? DownloadBadge(sourceId: sourceId, bookId: it.ownerId)
            : null,
        cornerOverlay: isBook
            ? BookReadCorner(sourceId: sourceId, bookId: it.ownerId)
            : null,
        onTap: () => context.push(
          it.ownerType == 'series'
              ? '/series/$sourceId/${it.ownerId}'
              : '/$bookRoute/$sourceId/${it.ownerId}',
        ),
        onLongPress: () => showItemContextMenu(
          context,
          sourceId: sourceId,
          ownerType: it.ownerType,
          ownerId: it.ownerId,
          title: it.title,
        ),
      );
    }

    // Builds the slot for a rail: skeleton while loading (no value yet), the
    // real rail when populated, or a smoothly-collapsing empty when resolved
    // empty. The header is identical between skeleton and real rail, so only
    // the tiles swap.
    Widget railSlot(HomeRailKind kind) {
      final items = itemsFor(kind);
      final Widget child;
      if (items == null) {
        child = RailSkeleton(title: kind.title, icon: kind.icon);
      } else if (items.isEmpty) {
        child = const SizedBox.shrink();
      } else {
        child = Rail(
          title: kind.title,
          icon: kind.icon,
          children: [for (final it in items) tileFor(kind, it)],
        );
      }
      // Under reduce-motion, render the child directly: there is no animation
      // to play, and a zero-duration AnimatedSize asserts in performLayout when
      // it collapses (a rail resolving empty), so skip the wrapper entirely.
      if (MediaQuery.disableAnimationsOf(context)) return child;
      return AnimatedSize(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.topCenter,
        child: child,
      );
    }

    // The empty-state message must never flash during loading: show it only
    // once every visible rail has resolved (no value pending) and all are empty.
    // Requires at least one visible rail, so hiding every rail in settings does
    // not vacuously trigger the "nothing to show" message.
    final allResolved = visibleRails.every((k) => itemsFor(k) != null);
    final everythingEmpty = visibleRails.isNotEmpty &&
        visibleRails
            .every((k) => (itemsFor(k) ?? const <RailItem>[]).isEmpty);

    return RefreshIndicator(
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
              for (final kind in visibleRails) railSlot(kind),
              if (allResolved && everythingEmpty) const _EmptyHome(),
            ],
          ),
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
