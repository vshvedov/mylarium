import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/import_service.dart';
import 'import_controller.dart';

/// "Import from URL" dialog (T5): paste an https link to a comic archive and
/// import it into the Local files source. The dialog drives
/// [ImportController.importUrl] (the shared import state machine) and shows
/// inline progress while the run is active; the finished [ImportResult] is
/// returned to the caller, which presents the shared results sheet.
class UrlImportDialog extends ConsumerStatefulWidget {
  const UrlImportDialog({super.key});

  /// Shows the dialog. Resolves with the finished batch result, or null when
  /// the user cancelled before starting an import.
  static Future<ImportResult?> show(BuildContext context) =>
      showDialog<ImportResult>(
        context: context,
        // The import keeps the dialog up while running; blocking barrier
        // dismissal means a finished run's result is never silently dropped.
        barrierDismissible: false,
        builder: (_) => const UrlImportDialog(),
      );

  @override
  ConsumerState<UrlImportDialog> createState() => _UrlImportDialogState();
}

class _UrlImportDialogState extends ConsumerState<UrlImportDialog> {
  final _urlController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final url = Uri.tryParse(_urlController.text.trim());
    if (url == null || !url.hasScheme || url.host.isEmpty) {
      setState(() => _error = 'Enter a valid URL');
      return;
    }
    setState(() => _error = null);
    final result =
        await ref.read(importControllerProvider.notifier).importUrl(url);
    if (!mounted) return;
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final busy = ref.watch(importControllerProvider) is ImportRunActive;
    return AlertDialog(
      title: const Text('Import from URL'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _urlController,
            autofocus: true,
            enabled: !busy,
            keyboardType: TextInputType.url,
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(
              hintText: 'https://...',
              errorText: _error,
            ),
            onSubmitted: busy ? null : (_) => _submit(),
          ),
          if (busy) ...[
            const SizedBox(height: 16),
            const LinearProgressIndicator(),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: busy ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: busy ? null : _submit,
          child: Text(busy ? 'Importing...' : 'Import'),
        ),
      ],
    );
  }
}
