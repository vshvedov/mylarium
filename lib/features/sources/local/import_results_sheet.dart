import 'package:flutter/material.dart';

import '../../../app/theme/app_icons.dart';
import '../../../data/local/import_service.dart';

/// Shows the per-file outcome of an import batch. The list itself is a plain
/// widget ([ImportResultsList]) so it can be tested and embedded; the static
/// [show] wraps it in a modal bottom sheet.
///
/// Note: [AppBottomSheet.show] requires a [DesignTokens] extension in the
/// theme, making it unsuitable here (tests and call sites use plain
/// [MaterialApp] without that extension). [showModalBottomSheet] is used
/// directly instead.
class ImportResultsSheet {
  const ImportResultsSheet._();

  static Future<void> show(BuildContext context, ImportResult result) =>
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (_) => SafeArea(
          child: SingleChildScrollView(
            child: ImportResultsList(result: result),
          ),
        ),
      );
}

/// The scrollable body of the import-results sheet. Rendered standalone in
/// tests and wrapped in a sheet by [ImportResultsSheet.show].
class ImportResultsList extends StatelessWidget {
  const ImportResultsList({super.key, required this.result});

  final ImportResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imported =
        result.files.where((f) => f.outcome == ImportOutcome.imported);
    final skipped =
        result.files.where((f) => f.outcome != ImportOutcome.imported);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
          child: Text(
            '${imported.length} imported',
            style: theme.textTheme.titleMedium,
          ),
        ),
        for (final f in imported)
          ListTile(
            dense: true,
            leading: const Icon(AppIcons.localBook),
            title: Text(f.name, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        if (skipped.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: Text('Skipped', style: theme.textTheme.titleMedium),
          ),
          for (final f in skipped)
            ListTile(
              dense: true,
              leading: Icon(AppIcons.warning,
                  color: theme.colorScheme.error),
              title:
                  Text(f.name, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: f.reason == null ? null : Text(f.reason!),
            ),
        ],
        const SizedBox(height: 12),
      ],
    );
  }
}
