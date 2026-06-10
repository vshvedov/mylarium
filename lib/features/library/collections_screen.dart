import 'package:flutter/material.dart';
import '../../app/l10n.dart';
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
        title: Text(context.l10n.collectionsAndReadListsTitle),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(AppIcons.add),
            tooltip: context.l10n.collectionsNew,
            onSelected: (mode) => _createNew(context, ref, mode),
            itemBuilder: (_) => [
              PopupMenuItem(
                  value: 'collection',
                  child: Text(context.l10n.collectionsNewCollection)),
              PopupMenuItem(
                  value: 'readlist',
                  child: Text(context.l10n.collectionsNewReadList)),
            ],
          ),
        ],
      ),
      body: ListView(
        children: [
          _Header(label: context.l10n.collectionsHeader),
          ...switch (collections) {
            AsyncData(:final value) when value.isEmpty => [
                _Empty(label: context.l10n.collectionsEmpty),
              ],
            AsyncData(:final value) => [
                for (final c in value)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: AppListRow(
                      icon: AppIcons.collections,
                      title: c.name,
                      subtitle: context.l10n.seriesCount(c.seriesIds.length),
                      onTap: () =>
                          context.push('/collection/$sourceId/${c.id}'),
                    ),
                  ),
              ],
            AsyncError() => [_Empty(label: context.l10n.collectionsLoadError)],
            _ => [const _Loading()],
          },
          const Divider(),
          _Header(label: context.l10n.readListsHeader),
          ...switch (readLists) {
            AsyncData(:final value) when value.isEmpty => [
                _Empty(label: context.l10n.readListsEmpty),
              ],
            AsyncData(:final value) => [
                for (final r in value)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: AppListRow(
                      icon: AppIcons.readList,
                      title: r.name,
                      subtitle: context.l10n.bookCount(r.bookIds.length),
                      onTap: () => context.push('/readlist/$sourceId/${r.id}'),
                    ),
                  ),
              ],
            AsyncError() => [_Empty(label: context.l10n.readListsLoadError)],
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
    // Title with the collection's actual name (already cached by the index
    // screen's list); the generic label only flashes on a cold deep-link.
    final name = ref
        .watch(collectionsProvider)
        .valueOrNull
        ?.where((c) => c.id == collectionId)
        .firstOrNull
        ?.name;
    return Scaffold(
      appBar: AppBar(title: Text(name ?? context.l10n.collectionFallbackName)),
      body: series.when(
        loading: () => const _Loading(),
        error: (e, _) => _Empty(label: context.l10n.collectionLoadError('$e')),
        data: (list) => list.isEmpty
            ? _Empty(label: context.l10n.collectionEmpty)
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
                      title: context.l10n.removeFromCollectionTitle,
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
    // Same pattern as the collection detail: real name when cached.
    final name = ref
        .watch(readListsProvider)
        .valueOrNull
        ?.where((r) => r.id == readListId)
        .firstOrNull
        ?.name;
    return Scaffold(
      appBar: AppBar(title: Text(name ?? context.l10n.readListFallbackName)),
      body: books.when(
        loading: () => const _Loading(),
        error: (e, _) => _Empty(label: context.l10n.collectionLoadError('$e')),
        data: (list) => list.isEmpty
            ? _Empty(label: context.l10n.readListEmpty)
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
                      title: context.l10n.removeFromReadListTitle,
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
                      cornerOverlay:
                          BookReadCorner(sourceId: sourceId, bookId: b.id),
                      leadingBadge:
                          DownloadBadge(sourceId: sourceId, bookId: b.id),
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
    title: mode == 'collection'
        ? context.l10n.collectionsNewCollection
        : context.l10n.collectionsNewReadList,
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
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.collectionCreateError(name))));
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
          child: Text(context.l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(context.l10n.remove),
        ),
      ],
    ),
  );
  if (ok != true) return;
  try {
    await onRemove();
  } on ContentException {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.collectionRemoveError)));
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
