import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/theme/theme_controller.dart' show appDatabaseProvider;
import '../../core/age_rating.dart';
import '../../core/security/app_lock.dart';
import '../../data/source/source_providers.dart';

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

/// The active source's pinned items, newest first, AGE-GATED exactly like the
/// other home rails: a restricted series (or a book whose series is restricted)
/// is hidden unless its library is currently restricted-visible, and an item
/// whose gating series is not cached is hidden outright (never leaks an
/// unclassified restricted entry). Reads only the local cache, so the rail and
/// its gating work offline.
///
/// [lock] is captured before the `.map` and `appLockProvider` is watched, so
/// unlocking a library re-runs this provider and re-subscribes the stream with
/// the new lock, revealing previously-hidden pins live. That ordering is
/// load-bearing (a test covers it); do not fold the `lock` read into the `.map`.
@riverpod
Stream<List<PinnedEntry>> pinnedItems(Ref ref) async* {
  final sourceId = await ref.watch(activeSourceIdProvider.future);
  if (sourceId == null) {
    yield const [];
    return;
  }
  final lock = await ref.watch(appLockProvider.future);
  final db = ref.watch(appDatabaseProvider);
  yield* db.watchPinnedItems(sourceId).map(
        (rows) => [
          for (final r in rows)
            if (r.gatingResolved && r.title != null)
              // gatingResolved guarantees the gating series row exists, so its
              // (non-null in the table) libraryId is present; the null check is
              // a leak-safe belt-and-braces (a restricted item with no library
              // resolves to hidden).
              if (!isRestrictedAgeRating(r.ageRating) ||
                  (r.libraryId != null &&
                      lock.restrictedVisible(r.libraryId!)))
                (
                  ownerType: r.ownerType,
                  ownerId: r.ownerId,
                  title: r.title!,
                  subtitle: r.ownerType == 'book' &&
                          (r.number?.isNotEmpty ?? false)
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
