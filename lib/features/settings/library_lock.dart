import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/security/app_lock.dart';
import '../library/library_browse_controllers.dart';

/// Per-library lock and show-restricted toggles. Locking a library gates its
/// contents behind a biometric/PIN unlock; show-restricted reveals age-gated
/// series, but only while the library is unlocked.
class LibraryLockScreen extends ConsumerWidget {
  const LibraryLockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraries = ref.watch(librariesProvider);
    final lock = ref.watch(appLockProvider).valueOrNull ?? AppLockState.empty;

    return Scaffold(
      appBar: AppBar(title: const Text('Library locks')),
      body: libraries.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load libraries: $e')),
        data: (libs) => libs.isEmpty
            ? const Center(child: Text('No libraries.'))
            : ListView(
                children: [
                  for (final lib in libs)
                    ExpansionTile(
                      leading: Icon(
                        (lock.locked[lib.id] ?? false)
                            ? Icons.lock
                            : Icons.lock_open,
                      ),
                      title: Text(lib.name),
                      children: [
                        SwitchListTile(
                          title: const Text('Require unlock'),
                          subtitle: const Text(
                              'Biometric or device passcode to view'),
                          value: lock.locked[lib.id] ?? false,
                          onChanged: (v) => ref
                              .read(appLockProvider.notifier)
                              .setLocked(lib.id, v),
                        ),
                        SwitchListTile(
                          title: const Text('Show age-restricted series'),
                          subtitle: const Text(
                              'Visible only while the library is unlocked'),
                          value: lock.showRestricted[lib.id] ?? false,
                          onChanged: (v) => ref
                              .read(appLockProvider.notifier)
                              .setShowRestricted(lib.id, v),
                        ),
                      ],
                    ),
                ],
              ),
      ),
    );
  }
}
