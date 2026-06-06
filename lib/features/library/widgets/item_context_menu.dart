import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_icons.dart';
import '../../../app/theme/theme_controller.dart' show appDatabaseProvider;
import '../../../app/widgets/app_bottom_sheet.dart';
import '../../../app/widgets/app_list_row.dart';
import '../pin_controllers.dart';

/// Long-press context menu for a series or chapter. Today it carries a single
/// toggling Pin / Unpin action; the sheet leaves room for more later.
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
            title: pinned ? 'Unpin' : 'Pin',
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
        ],
      ),
    );
  }
}
