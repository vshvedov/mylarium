import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n.dart';
import '../../../app/theme/app_icons.dart';
import '../../../app/theme/theme_controller.dart' show appDatabaseProvider;
import '../../../app/widgets/app_bottom_sheet.dart';
import '../../../app/widgets/app_list_row.dart';
import '../../sync/sync_providers.dart';
import '../library_browse_controllers.dart';
import '../pin_controllers.dart';

/// Long-press context menu for a series or chapter: Pin/Unpin, Mark as not read,
/// and (chapters only) Preview - open the reader without reporting progress.
Future<void> showItemContextMenu(
  BuildContext context, {
  required String sourceId,
  required String ownerType,
  required String ownerId,
  required String title,
}) =>
    AppBottomSheet.show<void>(
      context,
      builder: (ctx) => _ItemMenu(
        sourceId: sourceId,
        ownerType: ownerType,
        ownerId: ownerId,
        title: title,
      ),
    );

class _ItemMenu extends ConsumerWidget {
  const _ItemMenu({
    required this.sourceId,
    required this.ownerType,
    required this.ownerId,
    required this.title,
  });

  final String sourceId;
  final String ownerType;
  final String ownerId;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pinned =
        ref.watch(isPinnedProvider(sourceId, ownerType, ownerId)).valueOrNull ??
            false;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          AppListRow(
            title: pinned ? context.l10n.unpin : context.l10n.pin,
            icon: pinned ? AppIcons.unpin : AppIcons.pin,
            trailing: const SizedBox.shrink(),
            onTap: () async {
              await ref.read(appDatabaseProvider).setPinned(
                    sourceId,
                    ownerType,
                    ownerId,
                    pinned: !pinned,
                    now: DateTime.now().millisecondsSinceEpoch,
                  );
              if (context.mounted) Navigator.pop(context);
            },
          ),
          AppListRow(
            title: context.l10n.markAsNotRead,
            icon: AppIcons.markUnread,
            trailing: const SizedBox.shrink(),
            onTap: () async {
              final engine = await ref.read(syncEngineProvider.future);
              if (ownerType == 'series') {
                await engine.markSeriesUnread(sourceId, ownerId);
              } else {
                await engine.markUnread(sourceId, ownerId);
              }
              // The "Keep reading" rail is derived from the server's in-progress
              // list; refetch it so the now-unread item leaves the rail without a
              // manual refresh. (Riverpod keeps the prior list shown until the
              // refetch returns, so it removes smoothly with no empty flash.)
              ref.invalidate(keepReadingProvider);
              if (context.mounted) Navigator.pop(context);
            },
          ),
          if (ownerType == 'book')
            AppListRow(
              title: context.l10n.preview,
              icon: AppIcons.preview,
              trailing: const SizedBox.shrink(),
              onTap: () {
                // Capture the router before popping the sheet, then open the
                // reader in preview mode (no progress, no auto-cache).
                final router = GoRouter.of(context);
                Navigator.pop(context);
                router.push('/reader/$sourceId/$ownerId?preview=true');
              },
            ),
        ],
      ),
    );
  }
}
