import 'package:flutter/material.dart';
import '../../app/theme/app_icons.dart';
import '../../app/theme/app_theme.dart' show kSeed;
import '../../app/theme/design_tokens.dart';
import '../../app/widgets/app_list_row.dart';
import '../../app/widgets/app_loading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/security/app_lock.dart';
import 'library_browse_controllers.dart';
import 'series_grid.dart';
import 'widgets/detail_header.dart';

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
        loading: () => const AppLoadingIndicator(),
        error: (e, _) => Center(child: Text('Could not load libraries: $e')),
        data: (libs) => ListView(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          children: [
            for (final lib in libs)
              AppListRow(
                icon: lock.isLocked(lib.id)
                    ? AppIcons.lock
                    : AppIcons.libraries,
                title: lib.name,
                onTap: () => context.push('/library/$sourceId/${lib.id}'),
              ),
          ],
        ),
      ),
    );
  }

}

/// A single library's series grid. A locked library shows the cinematic unlock
/// gate ([_LockedLibraryView]) instead of its content.
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
      return _LockedLibraryView(
        name: name ?? 'Library',
        onUnlock: () => ref
            .read(appLockProvider.notifier)
            .unlock(libraryId, libraryName: name),
      );
    }

    return SeriesGridScreen(
      sourceId: sourceId,
      libraryId: libraryId,
      title: name ?? 'Library',
    );
  }
}

/// The cinematic "this library is locked" gate: a violet-glowing filled lock over
/// the dark cover-forward backdrop, the library name in the hero font, and a
/// primary unlock action.
class _LockedLibraryView extends StatelessWidget {
  const _LockedLibraryView({required this.name, required this.onUnlock});

  final String name;
  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final eink = Theme.of(context).extension<DesignTokens>()?.isEink ?? false;
    return Scaffold(
      body: Stack(
        children: [
          // A soft violet wash bleeding down from the top, echoing the detail
          // hero, so the lock badge sits in a pool of brand light.
          if (!eink)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 360,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      kSeed.withValues(alpha: 0.22),
                      scheme.surface.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Glowing lock badge.
                  Container(
                    width: 116,
                    height: 116,
                    decoration: eink
                        ? BoxDecoration(
                            shape: BoxShape.circle,
                            color: scheme.surface,
                            border: Border.all(color: scheme.onSurface, width: 2),
                          )
                        : BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Color.lerp(kSeed, Colors.white, 0.22)!,
                                kSeed,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: kSeed.withValues(alpha: 0.55),
                                blurRadius: 60,
                                spreadRadius: 6,
                              ),
                            ],
                          ),
                    child: Icon(AppIcons.lockFill,
                        size: 52,
                        color: eink ? scheme.onSurface : Colors.white),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Anton',
                      fontSize: 34,
                      height: 1.05,
                      letterSpacing: 0.5,
                      color: eink ? scheme.onSurface : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'This library is locked',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 28),
                  HeroAction(
                    label: 'Unlock',
                    icon: AppIcons.lockOpen,
                    compact: true,
                    onPressed: onUnlock,
                  ),
                ],
              ),
            ),
          ),
          const Positioned(top: 0, left: 4, child: HeroBackButton()),
        ],
      ),
    );
  }
}
