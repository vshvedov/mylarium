import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_icons.dart';
import '../../../core/db/database.dart';
import '../../library/library_browse_controllers.dart'
    show bookReadStateProvider;
import '../../library/widgets/library_tiles.dart';
import '../../library/widgets/rail.dart';
import '../../library/widgets/reading_progress.dart';
import '../../library/widgets/skeleton.dart';
import 'import_controller.dart';
import 'import_results_sheet.dart';
import 'local_providers.dart';

/// Home body for the Local files source: keep-reading and recently-imported
/// rails over the imported library, plus import and browse entry points. An
/// empty library renders a first-run call to action instead of rails.
class LocalHomeBody extends ConsumerWidget {
  const LocalHomeBody({super.key, required this.sourceId});

  final String sourceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keepReadingAsync = ref.watch(localKeepReadingProvider(sourceId));
    final recentAsync = ref.watch(localRecentlyImportedProvider(sourceId));
    final run = ref.watch(importControllerProvider);

    // Resolved items, or null while a rail is genuinely still loading (no
    // value yet); an error degrades to empty rather than a perpetual skeleton.
    List<LocalComic>? resolve(AsyncValue<List<LocalComic>> async) =>
        async.valueOrNull ?? (async.hasError ? const <LocalComic>[] : null);
    final keepReading = resolve(keepReadingAsync);
    final recent = resolve(recentAsync);

    final actions = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              icon: const Icon(AppIcons.importComics),
              label: Text(
                  run is ImportRunActive ? 'Importing...' : 'Import comics'),
              onPressed:
                  run is ImportRunActive ? null : () => _import(context, ref),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(AppIcons.sourceLocal),
              label: const Text('Browse all'),
              onPressed: () => context.push('/local-browse/$sourceId'),
            ),
          ),
        ],
      ),
    );

    // Skeleton rails while loading, at the real rail metrics, so the empty
    // call-to-action never flashes before the library streams in and nothing
    // jumps when data lands.
    if (keepReading == null || recent == null) {
      return ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          actions,
          const SizedBox(height: 8),
          const SkeletonRail(
            title: 'Keep reading',
            height: kHeroRailHeight,
            tileWidth: kHeroRailTileWidth,
          ),
          const SkeletonRail(
            title: 'Recently imported',
            height: _localRailHeight,
            tileWidth: _localTileWidth,
          ),
        ],
      );
    }

    if (recent.isEmpty && keepReading.isEmpty) {
      return _EmptyLibrary(
        busy: run is ImportRunActive,
        onImport: () => _import(context, ref),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        actions,
        if (keepReading.isNotEmpty)
          // Keep-reading taps straight into the reader (resuming at the saved
          // page), matching the server-source home rail. Hero treatment:
          // larger tiles plus the page-progress footer.
          LocalComicsRail(
            title: 'Keep reading',
            sourceId: sourceId,
            comics: keepReading,
            openReader: true,
            hero: true,
          ),
        if (recent.isNotEmpty)
          LocalComicsRail(
            title: 'Recently imported',
            sourceId: sourceId,
            comics: recent,
          ),
      ],
    );
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final result =
        await ref.read(importControllerProvider.notifier).pickAndImport();
    if (result != null && context.mounted) {
      await ImportResultsSheet.show(context, result);
    }
  }
}

/// Default metrics for the local home rails (the keep-reading rail uses the
/// shared hero metrics from rail.dart instead).
const double _localRailHeight = 210;
const double _localTileWidth = 120;

class LocalComicsRail extends StatelessWidget {
  const LocalComicsRail({
    super.key,
    required this.title,
    required this.sourceId,
    required this.comics,
    this.openReader = false,
    this.hero = false,
  });

  final String title;
  final String sourceId;
  final List<LocalComic> comics;

  /// When true a tile opens the reader directly; otherwise the book detail.
  final bool openReader;

  /// Hero treatment for the keep-reading rail: larger tiles plus a
  /// page-progress footer (bar + "p. X of Y") under each cover.
  final bool hero;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        SizedBox(
          height: hero ? kHeroRailHeight : _localRailHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: comics.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final c = comics[i];
              return SizedBox(
                width: hero ? kHeroRailTileWidth : _localTileWidth,
                child: CoverTile(
                  sourceId: sourceId,
                  ownerType: 'book',
                  ownerId: c.id,
                  title: c.title,
                  subtitle: c.series,
                  footer: hero
                      ? _LocalReadingProgress(sourceId: sourceId, comic: c)
                      : null,
                  onTap: () => context.push(openReader
                      ? '/reader/$sourceId/${c.id}'
                      : '/local-book/$sourceId/${c.id}'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Resolves the local read state for one imported comic and renders the
/// page-progress bar + caption (the comic row already carries its page count).
/// Renders nothing until progress exists, so a never-opened import stays clean.
class _LocalReadingProgress extends ConsumerWidget {
  const _LocalReadingProgress({required this.sourceId, required this.comic});

  final String sourceId;
  final LocalComic comic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state =
        ref.watch(bookReadStateProvider(sourceId, comic.id)).valueOrNull;
    if (state == null || comic.pagesCount <= 0) {
      return const SizedBox.shrink();
    }
    // BookState.currentPage is 0-based (reader-native); the caption is 1-based.
    return ReadingProgressLabel(
      current: state.currentPage + 1,
      total: comic.pagesCount,
    );
  }
}

class _EmptyLibrary extends StatelessWidget {
  const _EmptyLibrary({required this.busy, required this.onImport});

  final bool busy;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(AppIcons.sourceLocal,
                size: 56, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text('No comics yet', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Import CBZ or CBR files from this device. '
              'Imported comics are copied in and always readable.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              icon: const Icon(AppIcons.importComics),
              label: Text(busy ? 'Importing...' : 'Import comics'),
              onPressed: busy ? null : onImport,
            ),
          ],
        ),
      ),
    );
  }
}
