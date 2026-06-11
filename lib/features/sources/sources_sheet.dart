import 'dart:async' show unawaited;
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/l10n.dart';
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
import '../sources/local/folder_source_controller.dart';
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
        'safTree' => AppIcons.sourceFolder,
        _ => AppIcons.sourceLocal,
      };

  String _kindLabel(BuildContext context, String kind) => switch (kind) {
        'komga' => 'Komga',
        'kavita' => 'Kavita',
        'safTree' => context.l10n.sourceKindFolderLibrary,
        _ => kind,
      };

  Future<void> _remove(
    BuildContext context,
    WidgetRef ref,
    Source source,
  ) async {
    final isTree = source.kind == SourceKind.safTree.name;
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: einkOf(context) ? kEinkBarrierColor : null,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.sourceRemoveTitle(source.label)),
        content: Text(
          isTree
              ? ctx.l10n.sourceRemoveFolderBody
              : ctx.l10n.sourceRemoveServerBody,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(ctx.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(ctx.l10n.remove),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final db = ref.read(appDatabaseProvider);
    if (isTree) {
      await ref.read(folderSourceServiceProvider).removeFolderSource(source);
      ref.invalidate(activeSourceIdProvider);
      return;
    }
    if (source.kind == SourceKind.kavita.name) {
      await ref.read(kavitaCredentialStoreProvider).delete(source.id);
    } else {
      await ref.read(komgaCredentialStoreProvider).delete(source.id);
    }
    await db.deleteSource(source.id);
    ref.invalidate(activeSourceIdProvider);
  }

  /// Picks a folder via the SAF tree picker, creates the safTree source, makes
  /// it active, and starts the initial scan.
  Future<void> _addFolder(BuildContext context, WidgetRef ref) async {
    final id =
        await ref.read(folderSourceServiceProvider).addFolderSource();
    if (id == null) return; // picker cancelled
    ref.read(activeSourceIdProvider.notifier).select(id);
    unawaited(
      ref.read(folderScanControllerProvider(id).notifier).rescan(),
    );
    if (context.mounted) Navigator.of(context).pop();
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
              child: Text(context.l10n.sourcesTitle,
                  style: theme.textTheme.titleMedium),
            ),
            if (sources.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
                child: Text(
                  context.l10n.sourcesEmpty,
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
                  // The copy-import Local source has no delete affordance:
                  // removing the row would orphan the imported library. Books
                  // are managed per book on the local detail screen. Folder
                  // (safTree) sources ARE removable: they are a read-only view
                  // over external files, so removal loses nothing.
                  final isLocal = source.kind == SourceKind.local.name;
                  final isTree = source.kind == SourceKind.safTree.name;
                  return AppListRow(
                    icon: _iconFor(source.kind),
                    title: source.label,
                    subtitle: isLocal
                        ? context.l10n.sourceSubtitleOnDevice
                        : isTree
                            ? context.l10n.sourceSubtitleFolderInPlace
                            : '${_kindLabel(context, source.kind)} - ${source.baseUrl ?? source.kind}',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isActive)
                          Icon(AppIcons.check, color: theme.colorScheme.primary),
                        if (!isLocal)
                          IconButton(
                            icon: const Icon(AppIcons.delete),
                            tooltip: context.l10n.sourceRemoveTooltip,
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
                title: context.l10n.onboardingLocalTitle,
                subtitle: context.l10n.sourceLocalImportSubtitle,
                onTap: () async {
                  final service = ref.read(importServiceProvider);
                  final id = await service.ensureLocalSource();
                  ref.read(activeSourceIdProvider.notifier).select(id);
                  if (context.mounted) Navigator.of(context).pop();
                },
              ),
            // Folder libraries are Android-only (SAF document trees); iOS
            // folder sources are a future phase (PRD OQ1). A single entry: the
            // SAF picker can navigate to internal storage or an SD card alike,
            // so there is no separate per-card shortcut.
            if (Platform.isAndroid)
              AppListRow(
                icon: AppIcons.sourceFolder,
                title: context.l10n.sourceAddFolder,
                subtitle: context.l10n.sourceAddFolderSubtitle,
                onTap: () => _addFolder(context, ref),
              ),
            AppListRow(
              icon: AppIcons.add,
              title: context.l10n.sourceAddSource,
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
