import 'package:flutter/material.dart';
import '../../app/theme/app_icons.dart';
import '../../app/theme/design_tokens.dart';
import '../../app/widgets/app_list_row.dart';
import '../../app/widgets/app_loading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/content_exception.dart';
import '../../data/source/source_providers.dart';
import 'library_browse_controllers.dart';
import 'widgets/add_to_collection_sheet.dart';
import 'widgets/library_tiles.dart';

/// Browses the active source's collections and read lists. Tapping one opens a
/// grid of its series (collection) or books (read list).
class CollectionsScreen extends ConsumerWidget {
  const CollectionsScreen({super.key, required this.sourceId});

  final String sourceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collections = ref.watch(collectionsProvider);
    final readLists = ref.watch(readListsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Collections & read lists'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(AppIcons.add),
            tooltip: 'New',
            onSelected: (mode) => _createNew(context, ref, mode),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'collection', child: Text('New collection')),
              PopupMenuItem(value: 'readlist', child: Text('New read list')),
            ],
          ),
        ],
      ),
      body: ListView(
        children: [
          _Header(label: 'Collections'),
          ...switch (collections) {
            AsyncData(:final value) when value.isEmpty => [
                const _Empty(label: 'No collections.'),
              ],
            AsyncData(:final value) => [
                for (final c in value)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: AppListRow(
                      icon: AppIcons.collections,
                      title: c.name,
                      subtitle: '${c.seriesIds.length} series',
                      onTap: () =>
                          context.push('/collection/$sourceId/${c.id}'),
                    ),
                  ),
              ],
            AsyncError() => [const _Empty(label: 'Could not load collections.')],
            _ => [const _Loading()],
          },
          const Divider(),
          _Header(label: 'Read lists'),
          ...switch (readLists) {
            AsyncData(:final value) when value.isEmpty => [
                const _Empty(label: 'No read lists.'),
              ],
            AsyncData(:final value) => [
                for (final r in value)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: AppListRow(
                      icon: AppIcons.readList,
                      title: r.name,
                      subtitle: '${r.bookIds.length} books',
                      onTap: () => context.push('/readlist/$sourceId/${r.id}'),
                    ),
                  ),
              ],
            AsyncError() => [const _Empty(label: 'Could not load read lists.')],
            _ => [const _Loading()],
          },
        ],
      ),
    );
  }
}

/// A collection's series as a grid.
class CollectionDetailScreen extends ConsumerWidget {
  const CollectionDetailScreen({
    super.key,
    required this.sourceId,
    required this.collectionId,
  });

  final String sourceId;
  final String collectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final series = ref.watch(collectionSeriesProvider(collectionId));
    return Scaffold(
      appBar: AppBar(title: const Text('Collection')),
      body: series.when(
        loading: () => const _Loading(),
        error: (e, _) => _Empty(label: 'Could not load: $e'),
        data: (list) => list.isEmpty
            ? const _Empty(label: 'Empty collection.')
            : GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 160,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.58,
                ),
                itemCount: list.length,
                itemBuilder: (context, i) {
                  final s = list[i];
                  return GestureDetector(
                    onLongPress: () => _confirmRemove(
                      context,
                      title: 'Remove from collection?',
                      label: s.title,
                      onRemove: () async {
                        final repo = await ref
                            .read(collectionRepositoryProvider.future);
                        await repo?.removeSeries(collectionId, s.id);
                        ref.invalidate(collectionSeriesProvider(collectionId));
                      },
                    ),
                    child: CoverTile(
                      sourceId: sourceId,
                      ownerType: 'series',
                      ownerId: s.id,
                      title: s.title,
                      stacked: s.booksCount > 1,
                      onTap: () => context.push('/series/$sourceId/${s.id}'),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

/// A read list's books as a grid.
class ReadListDetailScreen extends ConsumerWidget {
  const ReadListDetailScreen({
    super.key,
    required this.sourceId,
    required this.readListId,
  });

  final String sourceId;
  final String readListId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final books = ref.watch(readListBooksProvider(readListId));
    return Scaffold(
      appBar: AppBar(title: const Text('Read list')),
      body: books.when(
        loading: () => const _Loading(),
        error: (e, _) => _Empty(label: 'Could not load: $e'),
        data: (list) => list.isEmpty
            ? const _Empty(label: 'Empty read list.')
            : GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 160,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.58,
                ),
                itemCount: list.length,
                itemBuilder: (context, i) {
                  final b = list[i];
                  return GestureDetector(
                    onLongPress: () => _confirmRemove(
                      context,
                      title: 'Remove from read list?',
                      label: b.title,
                      onRemove: () async {
                        final repo =
                            await ref.read(readListRepositoryProvider.future);
                        await repo?.removeBook(readListId, b.id);
                        ref.invalidate(readListBooksProvider(readListId));
                      },
                    ),
                    child: CoverTile(
                      sourceId: sourceId,
                      ownerType: 'book',
                      ownerId: b.id,
                      title: b.title,
                      subtitle: b.number.isEmpty ? null : 'No. ${b.number}',
                      onTap: () => context.push('/book/$sourceId/${b.id}'),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

/// Prompts for a name and creates an empty collection or read list.
Future<void> _createNew(
  BuildContext context,
  WidgetRef ref,
  String mode,
) async {
  final name = await promptName(
    context,
    title: mode == 'collection' ? 'New collection' : 'New read list',
  );
  if (name == null) return;
  try {
    if (mode == 'collection') {
      final repo = await ref.read(collectionRepositoryProvider.future);
      await repo?.create(name);
      ref.invalidate(collectionsProvider);
    } else {
      final repo = await ref.read(readListRepositoryProvider.future);
      await repo?.create(name);
      ref.invalidate(readListsProvider);
    }
  } on ContentException {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not create $name.')));
    }
  }
}

/// Confirms then runs an item removal, surfacing a snackbar on failure.
Future<void> _confirmRemove(
  BuildContext context, {
  required String title,
  required String label,
  required Future<void> Function() onRemove,
}) async {
  final ok = await showDialog<bool>(
    context: context,
    barrierColor: einkOf(context) ? kEinkBarrierColor : null,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(label),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Remove'),
        ),
      ],
    ),
  );
  if (ok != true) return;
  try {
    await onRemove();
  } on ContentException {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Could not remove.')));
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Text(label, style: Theme.of(context).textTheme.titleMedium),
      );
}

class _Empty extends StatelessWidget {
  const _Empty({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Center(child: Text(label)),
      );
}

class _Loading extends StatelessWidget {
  const _Loading();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.all(24),
        child: AppLoadingIndicator(),
      );
}
