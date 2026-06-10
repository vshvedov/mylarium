import 'package:flutter/material.dart';

import '../../../app/l10n.dart';
import '../../../app/theme/app_icons.dart';
import '../../../app/widgets/app_bottom_sheet.dart';
import '../../../data/local/import_service.dart';
import 'import_reason_text.dart';

/// Shows the per-file outcome of an import batch. The list itself is a plain
/// widget ([ImportResultsList]) so it can be tested and embedded; the static
/// [show] wraps it in a modal bottom sheet using the app's standard sheet
/// chrome.
class ImportResultsSheet {
  const ImportResultsSheet._();

  static Future<void> show(BuildContext context, ImportResult result) =>
      AppBottomSheet.show<void>(
        context,
        builder: (_) => SafeArea(
          top: false,
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
            context.l10n.importImportedCount(imported.length),
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
            child: Text(context.l10n.importSkipped,
                style: theme.textTheme.titleMedium),
          ),
          for (final f in skipped)
            ListTile(
              dense: true,
              leading: Icon(AppIcons.warning,
                  color: theme.colorScheme.error),
              title:
                  Text(f.name, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: f.reason == null
                  ? null
                  : Text(localizedImportReason(context, f.reason!)),
            ),
        ],
        const SizedBox(height: 12),
      ],
    );
  }
}
