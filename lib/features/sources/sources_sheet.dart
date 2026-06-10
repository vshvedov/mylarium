import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_icons.dart';
import '../../app/theme/design_tokens.dart';
import '../../app/theme/theme_controller.dart' show appDatabaseProvider;
import '../../app/widgets/app_bottom_sheet.dart';
import '../../app/widgets/app_list_row.dart';
import '../../core/db/database.dart';
import '../../data/kavita/kavita_providers.dart';
import '../../data/komga/komga_providers.dart';
import '../../data/source/content_source.dart';
import '../../data/source/source_providers.dart';
import '../sources/local/local_providers.dart';

/// Shows the connected-sources switcher as a bottom sheet: switch the active
/// source, add another, or remove one. Kept shallow (one tap from the home
/// settings sheet) and presented as a popup, like the rest of the home menu.
Future<void> showSourcesSheet(BuildContext context) =>
    AppBottomSheet.show<void>(context, builder: (_) => const _SourcesSheet());

class _SourcesSheet extends ConsumerWidget {
  const _SourcesSheet();

  IconData _iconFor(String kind) => switch (kind) {
        'komga' => AppIcons.sourceKomga,
        'kavita' => AppIcons.sourceKavita,
        _ => AppIcons.sourceLocal,
      };

  String _kindLabel(String kind) => switch (kind) {
        'komga' => 'Komga',
        'kavita' => 'Kavita',
        _ => kind,
      };

  Future<void> _remove(
    BuildContext context,
    WidgetRef ref,
    Source source,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: einkOf(context) ? kEinkBarrierColor : null,
      builder: (ctx) => AlertDialog(
        title: Text('Remove ${source.label}?'),
        content: const Text(
          'This disconnects the source and deletes its stored credentials. '
          'Downloaded files for this source are removed by storage cleanup.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final db = ref.read(appDatabaseProvider);
    if (source.kind == SourceKind.kavita.name) {
      await ref.read(kavitaCredentialStoreProvider).delete(source.id);
    } else {
      await ref.read(komgaCredentialStoreProvider).delete(source.id);
    }
    await db.deleteSource(source.id);
    ref.invalidate(activeSourceIdProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final activeId = ref.watch(activeSourceIdProvider).valueOrNull;
    final sources = ref.watch(sourcesStreamProvider).valueOrNull ?? const [];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: Text('Sources', style: theme.textTheme.titleMedium),
            ),
            if (sources.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
                child: Text(
                  'No sources connected yet.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: sources.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final source = sources[i];
                  final isActive = source.id == activeId;
                  // Local sources have no delete affordance: removing the row
                  // would orphan the imported library. Books are managed per
                  // book on the local detail screen.
                  final isLocal = source.kind == SourceKind.local.name;
                  return AppListRow(
                    icon: _iconFor(source.kind),
                    title: source.label,
                    subtitle: isLocal
                        ? 'On this device'
                        : '${_kindLabel(source.kind)} - ${source.baseUrl ?? source.kind}',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isActive)
                          Icon(AppIcons.check, color: theme.colorScheme.primary),
                        if (!isLocal)
                          IconButton(
                            icon: const Icon(AppIcons.delete),
                            tooltip: 'Remove source',
                            onPressed: () => _remove(context, ref, source),
                          ),
                      ],
                    ),
                    onTap: isActive
                        ? null
                        : () {
                            ref
                                .read(activeSourceIdProvider.notifier)
                                .select(source.id);
                            Navigator.of(context).pop();
                          },
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            if (!sources.any((s) => s.kind == SourceKind.local.name))
              AppListRow(
                icon: AppIcons.sourceLocal,
                title: 'Local files',
                subtitle: 'Import comics from this device',
                onTap: () async {
                  final service = ref.read(importServiceProvider);
                  final id = await service.ensureLocalSource();
                  ref.read(activeSourceIdProvider.notifier).select(id);
                  if (context.mounted) Navigator.of(context).pop();
                },
              ),
            AppListRow(
              icon: AppIcons.add,
              title: 'Add a source',
              onTap: () {
                Navigator.of(context).pop();
                context.push('/onboarding');
              },
            ),
          ],
        ),
      ),
    );
  }
}
