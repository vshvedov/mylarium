import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_icons.dart';
import '../../../core/db/database.dart';
import '../../library/widgets/library_tiles.dart';
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
    final keepReading =
        ref.watch(localKeepReadingProvider(sourceId)).valueOrNull ??
            const <LocalComic>[];
    final recent =
        ref.watch(localRecentlyImportedProvider(sourceId)).valueOrNull ??
            const <LocalComic>[];
    final run = ref.watch(importControllerProvider);

    if (recent.isEmpty && keepReading.isEmpty) {
      return _EmptyLibrary(
        busy: run is ImportRunActive,
        onImport: () => _import(context, ref),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        Padding(
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
        ),
        if (keepReading.isNotEmpty)
          _LocalRail(
            title: 'Keep reading',
            sourceId: sourceId,
            comics: keepReading,
          ),
        if (recent.isNotEmpty)
          _LocalRail(
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

class _LocalRail extends StatelessWidget {
  const _LocalRail({
    required this.title,
    required this.sourceId,
    required this.comics,
  });

  final String title;
  final String sourceId;
  final List<LocalComic> comics;

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
          height: 210,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: comics.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final c = comics[i];
              return SizedBox(
                width: 120,
                child: CoverTile(
                  sourceId: sourceId,
                  ownerType: 'book',
                  ownerId: c.id,
                  title: c.title,
                  subtitle: c.series,
                  onTap: () =>
                      context.push('/local-book/$sourceId/${c.id}'),
                ),
              );
            },
          ),
        ),
      ],
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
