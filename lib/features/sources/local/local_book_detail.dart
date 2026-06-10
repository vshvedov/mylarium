import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_icons.dart';
import '../../../core/db/database.dart';
import '../../library/library_browse_controllers.dart'
    show bookReadStateProvider;
import '../../library/widgets/cover_image.dart';
import 'local_providers.dart';

/// Detail screen for one imported comic: cover, facts, Read, and remove. Read
/// opens the shared reader on the local archive (T3); the reader resumes at
/// the saved position automatically.
class LocalBookDetailScreen extends ConsumerWidget {
  const LocalBookDetailScreen({
    super.key,
    required this.sourceId,
    required this.comicId,
  });

  final String sourceId;
  final String comicId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comicAsync = ref.watch(localComicProvider(comicId));
    final comic = comicAsync.valueOrNull;
    if (comic == null) {
      return Scaffold(
        appBar: AppBar(),
        body: comicAsync.isLoading
            ? const Center(child: CircularProgressIndicator())
            : const Center(child: Text('This comic was removed.')),
      );
    }
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(comic.title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: SizedBox(
              width: 180,
              child: AspectRatio(
                aspectRatio: 0.7,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CoverImage(
                    sourceId: sourceId,
                    ownerType: 'book',
                    ownerId: comic.id,
                    title: comic.title,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(comic.series, style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          _Fact('Number', comic.number),
          _Fact('Pages', '${comic.pagesCount}'),
          if (comic.sizeBytes != null)
            _Fact('Size', _formatBytes(comic.sizeBytes!)),
          _Fact(
              'Reading direction',
              comic.readingDirection == 'rtl'
                  ? 'Right to left'
                  : 'Left to right'),
          _Fact(
              'Imported',
              _formatDate(
                  DateTime.fromMillisecondsSinceEpoch(comic.importedAt))),
          const SizedBox(height: 24),
          _ReadButton(sourceId: sourceId, comic: comic),
          // Tree (in-place) books are managed by the folder rescan, not per
          // book: "removing" one here could not delete the on-card file and
          // the next rescan would just re-add the row.
          if (comic.kind != 'safTree') ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: Icon(AppIcons.delete, color: theme.colorScheme.error),
              label: const Text('Remove from library'),
              onPressed: () => _confirmRemove(context, ref, comic),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmRemove(
    BuildContext context,
    WidgetRef ref,
    LocalComic comic,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove this comic?'),
        content: const Text(
            'The imported copy is deleted from this device. Reading history is kept.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    if (!context.mounted) return;
    await ref.read(importServiceProvider).deleteImported(comic);
    ref.invalidate(localComicProvider(comic.id));
    if (context.mounted) context.pop();
  }
}

/// The Read action: opens the shared reader on this comic. Labelled
/// "Continue reading" once a local read position exists (the reader resumes
/// there) and "Read again" after completion (a re-read).
class _ReadButton extends ConsumerWidget {
  const _ReadButton({required this.sourceId, required this.comic});

  final String sourceId;
  final LocalComic comic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state =
        ref.watch(bookReadStateProvider(sourceId, comic.id)).valueOrNull;
    final completed = state?.status == 'completed';
    final inProgress =
        !completed && state != null && state.currentPage > 0;
    final label = completed
        ? 'Read again'
        : inProgress
            ? 'Continue reading'
            : 'Read';
    return FilledButton.icon(
      icon: const Icon(AppIcons.read),
      label: Text(label),
      onPressed: () => context.push('/reader/$sourceId/${comic.id}'),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: theme.textTheme.bodySmall),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

String _formatBytes(int bytes) {
  if (bytes >= 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
  if (bytes >= 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  if (bytes >= 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
  return '$bytes B';
}

String _formatDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
