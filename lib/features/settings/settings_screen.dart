import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/l10n.dart';
import '../../app/theme/app_icons.dart';
import '../../app/theme/design_tokens.dart';
import '../../app/theme/theme_controller.dart' show appDatabaseProvider;
import '../../app/widgets/app_list_row.dart';
import '../../app/widgets/ephemeral_storage_banner.dart';
import '../home/home_layout.dart';
import '../home/home_layout_controller.dart';
import 'settings_providers.dart';

/// Global / advanced settings. First section: hide and reorder the home rows.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(homeLayoutControllerProvider);
    final controller = ref.read(homeLayoutControllerProvider.notifier);
    final theme = Theme.of(context);
    final version = ref.watch(appVersionLabelProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(AppIcons.back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(context.l10n.settingsTitle),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Persistent place to confirm whether the app is running without
              // on-disk storage; self-hides when storage is healthy.
              const EphemeralStorageBanner(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: Text(context.l10n.settingsLibraryAccess,
                    style: theme.textTheme.titleMedium),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: AppListRow(
                  icon: AppIcons.lock,
                  title: context.l10n.settingsLibraryLocks,
                  subtitle: context.l10n.settingsLibraryLocksSubtitle,
                  onTap: () => context.push('/settings/library-lock'),
                ),
              ),
              const Divider(height: 24, indent: 20, endIndent: 20),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
                child: Text(context.l10n.settingsReading,
                    style: theme.textTheme.titleMedium),
              ),
              SwitchListTile(
                secondary: const Icon(AppIcons.nextChapter),
                title: Text(context.l10n.settingsAutoAdvance),
                subtitle: Text(context.l10n.settingsAutoAdvanceSubtitle),
                value:
                    ref.watch(autoAdvanceEnabledProvider).valueOrNull ?? false,
                onChanged: (v) =>
                    ref.read(appDatabaseProvider).updateAutoAdvance(v),
              ),
              const Divider(height: 24, indent: 20, endIndent: 20),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
                child: Text(context.l10n.settingsHomeRows,
                    style: theme.textTheme.titleMedium),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Text(
                  context.l10n.settingsHomeRowsHint,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(
                child: ReorderableListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                  buildDefaultDragHandles: false,
                  itemCount: items.length,
                  onReorderItem: controller.reorder,
                  itemBuilder: (context, i) {
                    final item = items[i];
                    return _RailRow(
                      key: ValueKey(item.kind),
                      index: i,
                      item: item,
                      onVisibleChanged: (v) =>
                          controller.setVisible(item.kind, v),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: controller.resetToDefault,
                    icon: const Icon(AppIcons.refresh, size: 18),
                    label: Text(context.l10n.settingsResetToDefault),
                  ),
                ),
              ),
              const Divider(height: 24, indent: 20, endIndent: 20),
              SafeArea(
                top: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                      child: AppListRow(
                        icon: AppIcons.info,
                        title: context.l10n.settingsDiagnostics,
                        subtitle: context.l10n.settingsDiagnosticsSubtitle,
                        onTap: () => context.push('/settings/diagnostics'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                      child: Text(
                        version == null ? 'Mylarium' : 'Mylarium $version',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RailRow extends StatelessWidget {
  const _RailRow({
    super.key,
    required this.index,
    required this.item,
    required this.onVisibleChanged,
  });

  final int index;
  final HomeRailItem item;
  final ValueChanged<bool> onVisibleChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tokens = Theme.of(context).extension<DesignTokens>()!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(tokens.coverRadius + 4),
          border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Icon(item.kind.icon, size: 22, color: scheme.onSurfaceVariant),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item.kind.title(context),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: item.visible
                          ? scheme.onSurface
                          : scheme.onSurfaceVariant,
                    ),
              ),
            ),
            Switch(value: item.visible, onChanged: onVisibleChanged),
            const SizedBox(width: 4),
            ReorderableDragStartListener(
              index: index,
              child: Icon(AppIcons.dragHandle, color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
