import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_icons.dart';
import '../../../app/theme/theme_controller.dart' show appDatabaseProvider;
import '../../../core/db/database.dart';
import 'folder_source_controller.dart';
import 'local_home.dart' show LocalComicsRail;
import 'local_providers.dart';

/// Home body for one Android folder source (SAF tree, T4): the same local
/// rails over the scanned library, plus rescan/browse entry points, a live
/// scan progress strip, and a non-blocking offline banner with a relink
/// affordance when the tree is unreachable (card ejected, permission
/// revoked). Cached rows keep rendering while offline; only fresh reads fail.
class FolderHomeBody extends ConsumerWidget {
  const FolderHomeBody({super.key, required this.sourceId});

  final String sourceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keepReading =
        ref.watch(localKeepReadingProvider(sourceId)).valueOrNull ??
            const <LocalComic>[];
    final recent =
        ref.watch(localRecentlyImportedProvider(sourceId)).valueOrNull ??
            const <LocalComic>[];
    final scan = ref.watch(folderScanControllerProvider(sourceId));
    final online = ref.watch(treeSourceOnlineProvider(sourceId)).valueOrNull;
    final scanning = scan is FolderScanRunning;
    final empty = recent.isEmpty && keepReading.isEmpty;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        if (online == false) _OfflineBanner(sourceId: sourceId),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  icon: const Icon(AppIcons.refresh),
                  label: Text(scanning ? 'Scanning...' : 'Rescan folder'),
                  onPressed: scanning || online == false
                      ? null
                      : () => ref
                          .read(
                              folderScanControllerProvider(sourceId).notifier)
                          .rescan(),
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
        if (scanning) _ScanProgressStrip(sourceId: sourceId, scan: scan),
        if (empty && !scanning)
          _EmptyFolder(
            online: online != false,
            onScan: () => ref
                .read(folderScanControllerProvider(sourceId).notifier)
                .rescan(),
          ),
        if (keepReading.isNotEmpty)
          LocalComicsRail(
            title: 'Keep reading',
            sourceId: sourceId,
            comics: keepReading,
            openReader: true,
          ),
        if (recent.isNotEmpty)
          LocalComicsRail(
            title: 'Recently added',
            sourceId: sourceId,
            comics: recent,
          ),
      ],
    );
  }
}

class _ScanProgressStrip extends ConsumerWidget {
  const _ScanProgressStrip({required this.sourceId, required this.scan});

  final String sourceId;
  final FolderScanRunning scan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final p = scan.progress;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${p.scanned} scanned, ${p.added} added'
              '${p.currentName == null ? '' : ' - ${p.currentName}'}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall,
            ),
          ),
          TextButton(
            onPressed: () => ref
                .read(folderScanControllerProvider(sourceId).notifier)
                .cancel(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

class _OfflineBanner extends ConsumerWidget {
  const _OfflineBanner({required this.sourceId});

  final String sourceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Material(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(AppIcons.offline, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'This folder is not reachable. The card may be ejected or '
                  'access was revoked. Reading from cached pages still works.',
                  style: theme.textTheme.bodySmall,
                ),
              ),
              TextButton(
                onPressed: () => _relink(context, ref),
                child: const Text('Reconnect'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _relink(BuildContext context, WidgetRef ref) async {
    final source =
        await ref.read(appDatabaseProvider).getSource(sourceId);
    if (source == null) return;
    final relinked =
        await ref.read(folderSourceServiceProvider).relink(source);
    if (!relinked) return;
    ref.invalidate(treeSourceOnlineProvider(sourceId));
    // The re-picked tree may differ; a reconcile pass brings rows in line.
    await ref.read(folderScanControllerProvider(sourceId).notifier).rescan();
  }
}

class _EmptyFolder extends StatelessWidget {
  const _EmptyFolder({required this.online, required this.onScan});

  final bool online;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.sourceLocal, size: 56, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Text('Nothing scanned yet', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Scan this folder to find CBZ and CBR comics. Files stay where '
            'they are; nothing is copied in.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            icon: const Icon(AppIcons.refresh),
            label: const Text('Scan folder'),
            onPressed: online ? onScan : null,
          ),
        ],
      ),
    );
  }
}
