import 'package:flutter/material.dart';
import '../../app/l10n.dart';
import '../../app/theme/app_icons.dart';
import '../../app/widgets/app_loading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/security/app_lock.dart';
import '../library/library_browse_controllers.dart';

/// Per-library lock. Locking a library hides ALL of its content everywhere
/// (home, browse, search, downloads, pins); unlocking requires biometric/PIN and
/// stays unlocked until the library is locked again.
class LibraryLockScreen extends ConsumerWidget {
  const LibraryLockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraries = ref.watch(librariesProvider);
    final lock = ref.watch(appLockProvider).valueOrNull ?? AppLockState.empty;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.settingsLibraryLocks)),
      body: libraries.when(
        loading: () => const AppLoadingIndicator(),
        error: (e, _) =>
            Center(child: Text(context.l10n.libraryLockLoadError('$e'))),
        data: (libs) => libs.isEmpty
            ? Center(child: Text(context.l10n.libraryLockNoLibraries))
            : ListView(
                children: [
                  for (final lib in libs)
                    SwitchListTile(
                      secondary: Icon(
                        lock.isLocked(lib.id)
                            ? AppIcons.lock
                            : AppIcons.lockOpen,
                      ),
                      title: Text(lib.name),
                      subtitle: Text(context.l10n.libraryLockSubtitle),
                      value: lock.isLocked(lib.id),
                      // Locking is immediate; unlocking prompts for auth and only
                      // takes effect on success (otherwise the watched state keeps
                      // the switch on).
                      onChanged: (v) {
                        final notifier = ref.read(appLockProvider.notifier);
                        if (v) {
                          notifier.lock(lib.id);
                        } else {
                          notifier.unlock(
                            lib.id,
                            reason: context.l10n.unlockLibraryReason(lib.name),
                          );
                        }
                      },
                    ),
                ],
              ),
      ),
    );
  }
}
