import 'package:flutter/material.dart';
import '../../app/theme/app_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/security/app_lock.dart';
import 'library_browse_controllers.dart';
import 'series_grid.dart';

/// Lists the active source's libraries. Tapping a locked library prompts a
/// biometric/PIN unlock before opening its grid.
class LibrariesScreen extends ConsumerWidget {
  const LibrariesScreen({super.key, required this.sourceId});

  final String sourceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraries = ref.watch(librariesProvider);
    final lock = ref.watch(appLockProvider).valueOrNull ?? AppLockState.empty;

    return Scaffold(
      appBar: AppBar(title: const Text('Libraries')),
      body: libraries.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load libraries: $e')),
        data: (libs) => ListView(
          children: [
            for (final lib in libs)
              ListTile(
                leading: Icon(lock.isLocked(lib.id)
                    ? AppIcons.lock
                    : AppIcons.libraries),
                title: Text(lib.name),
                onTap: () => _open(context, ref, lib.id),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _open(
      BuildContext context, WidgetRef ref, String libraryId) async {
    final lock = ref.read(appLockProvider).valueOrNull ?? AppLockState.empty;
    if (lock.isLocked(libraryId)) {
      final ok = await ref.read(appLockProvider.notifier).unlock(libraryId);
      if (!ok) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not unlock the library.')),
          );
        }
        return;
      }
    }
    if (context.mounted) {
      context.push('/library/$sourceId/$libraryId');
    }
  }
}

/// A single library's series grid, with restricted series visible only when the
/// library is unlocked and show-restricted is on.
class LibraryGridScreen extends ConsumerWidget {
  const LibraryGridScreen({
    super.key,
    required this.sourceId,
    required this.libraryId,
  });

  final String sourceId;
  final String libraryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libs = ref.watch(librariesProvider).valueOrNull ?? const [];
    final lock = ref.watch(appLockProvider).valueOrNull ?? AppLockState.empty;
    String? name;
    for (final l in libs) {
      if (l.id == libraryId) {
        name = l.name;
        break;
      }
    }

    if (lock.isLocked(libraryId)) {
      return Scaffold(
        appBar: AppBar(title: Text(name ?? 'Library')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(AppIcons.lock, size: 48),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () =>
                    ref.read(appLockProvider.notifier).unlock(libraryId),
                child: const Text('Unlock'),
              ),
            ],
          ),
        ),
      );
    }

    return SeriesGridScreen(
      sourceId: sourceId,
      libraryId: libraryId,
      title: name ?? 'Library',
      includeRestricted: lock.restrictedVisible(libraryId),
    );
  }
}
