import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/theme/theme_controller.dart' show appDatabaseProvider;
import '../../core/security/app_lock.dart';

part 'pin_controllers.g.dart';

/// A pinned item, resolved for display in the home "Pinned" rail. [stacked] is
/// the multi-book "deck" treatment (series only); [subtitle] is the chapter
/// number (book only).
typedef PinnedEntry = ({
  String ownerType,
  String ownerId,
  String title,
  String? subtitle,
  bool stacked,
});

/// The active source's pinned items, newest first. An item whose owner row is
/// not cached is dropped; an item whose library is locked is hidden. Reads only
/// the local cache, so the rail and its gating work offline.
///
/// [lock] is captured before the `.map` and `appLockProvider` is watched, so
/// locking/unlocking a library re-runs this provider and re-subscribes the
/// stream with the new lock, hiding/revealing pins live. That ordering is
/// load-bearing (a test covers it); do not fold the `lock` read into the `.map`.
@riverpod
Stream<List<PinnedEntry>> pinnedItems(Ref ref, String sourceId) async* {
  if (sourceId.isEmpty) {
    yield const [];
    return;
  }
  final lock = await ref.watch(appLockProvider.future);
  final db = ref.watch(appDatabaseProvider);
  yield* db.watchPinnedItems(sourceId).map(
        (rows) => [
          for (final r in rows)
            if (r.resolved && r.title != null && !lock.isLocked(r.libraryId))
              (
                ownerType: r.ownerType,
                ownerId: r.ownerId,
                title: r.title!,
                subtitle:
                    r.ownerType == 'book' && (r.number?.isNotEmpty ?? false)
                        ? 'No. ${r.number}'
                        : null,
                stacked: r.ownerType == 'series' && r.booksCount > 1,
              ),
        ],
      );
}

/// Whether a given series/book is pinned (drives the context-menu label and the
/// series-detail pin button).
@riverpod
Stream<bool> isPinned(
  Ref ref,
  String sourceId,
  String ownerType,
  String ownerId,
) =>
    ref.watch(appDatabaseProvider).watchIsPinned(sourceId, ownerType, ownerId);
