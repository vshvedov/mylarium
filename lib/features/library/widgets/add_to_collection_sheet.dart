import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_icons.dart';
import '../../../app/widgets/app_loading.dart';
import '../../../app/widgets/app_text_field.dart';
import '../../../core/network/content_exception.dart';
import '../../../data/source/source_providers.dart';
import '../library_browse_controllers.dart';

/// Prompts for a name in a simple dialog (new collection / read list). Returns
/// the trimmed non-empty name, or null on cancel / empty.
Future<String?> promptName(BuildContext context, {required String title}) {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: AppTextField(
        controller: controller,
        autofocus: true,
        hint: 'Name',
        textInputAction: TextInputAction.done,
        onSubmitted: (_) =>
            Navigator.pop(context, controller.text.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, controller.text.trim()),
          child: const Text('Create'),
        ),
      ],
    ),
  ).then((name) => (name == null || name.isEmpty) ? null : name);
}

/// A bottom sheet to add/remove a series (collections) or book (read lists) to
/// the source's collections or read lists, with a "New..." row. Membership and
/// toggles are optimistic; a failure reverts and shows a snackbar.
abstract final class AddToCollectionSheet {
  /// [mode] is `collection` (itemId is a seriesId) or `readlist` (itemId is a
  /// bookId).
  static Future<void> show(
    BuildContext context,
    WidgetRef ref, {
    required String mode,
    required String sourceId,
    required String itemId,
  }) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => _SheetBody(mode: mode, itemId: itemId),
      );
}

class _SheetBody extends ConsumerStatefulWidget {
  const _SheetBody({required this.mode, required this.itemId});

  final String mode;
  final String itemId;

  @override
  ConsumerState<_SheetBody> createState() => _SheetBodyState();
}

class _SheetBodyState extends ConsumerState<_SheetBody> {
  bool get _isCollection => widget.mode == 'collection';

  // Optimistic membership overrides keyed by collection/read-list id.
  final Map<String, bool> _override = {};

  @override
  Widget build(BuildContext context) {
    final title = _isCollection ? 'Add to collection' : 'Add to read list';
    final entries = _isCollection
        ? ref.watch(collectionsProvider).maybeWhen(
              data: (cs) => [
                for (final c in cs) (c.id, c.name, c.seriesIds.contains(widget.itemId)),
              ],
              orElse: () => null,
            )
        : ref.watch(readListsProvider).maybeWhen(
              data: (rs) => [
                for (final r in rs) (r.id, r.name, r.bookIds.contains(widget.itemId)),
              ],
              orElse: () => null,
            );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text(title,
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            ListTile(
              leading: const Icon(AppIcons.add),
              title: Text(_isCollection ? 'New collection' : 'New read list'),
              onTap: _create,
            ),
            const Divider(height: 1),
            if (entries == null)
              const Padding(
                padding: EdgeInsets.all(24),
                child: AppLoadingIndicator(),
              )
            else if (entries.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(_isCollection
                      ? 'No collections yet.'
                      : 'No read lists yet.'),
                ),
              )
            else
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final (id, name, serverMember) in entries)
                      CheckboxListTile(
                        value: _override[id] ?? serverMember,
                        title: Text(name),
                        onChanged: (v) => _toggle(id, v ?? false),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _create() async {
    final name = await promptName(
      context,
      title: _isCollection ? 'New collection' : 'New read list',
    );
    if (name == null || !mounted) return;
    try {
      if (_isCollection) {
        final repo = await ref.read(collectionRepositoryProvider.future);
        await repo?.create(name, seriesIds: [widget.itemId]);
        ref.invalidate(collectionsProvider);
      } else {
        final repo = await ref.read(readListRepositoryProvider.future);
        await repo?.create(name, bookIds: [widget.itemId]);
        ref.invalidate(readListsProvider);
      }
    } on ContentException {
      _snack('Could not create $name.');
    }
  }

  Future<void> _toggle(String id, bool add) async {
    setState(() => _override[id] = add);
    try {
      if (_isCollection) {
        final repo = await ref.read(collectionRepositoryProvider.future);
        if (repo == null) {
          throw const ContentException(ContentErrorKind.unreachable, 'No source.');
        }
        if (add) {
          await repo.addSeries(id, widget.itemId);
        } else {
          await repo.removeSeries(id, widget.itemId);
        }
        ref.invalidate(collectionsProvider);
      } else {
        final repo = await ref.read(readListRepositoryProvider.future);
        if (repo == null) {
          throw const ContentException(ContentErrorKind.unreachable, 'No source.');
        }
        if (add) {
          await repo.addBook(id, widget.itemId);
        } else {
          await repo.removeBook(id, widget.itemId);
        }
        ref.invalidate(readListsProvider);
      }
    } on ContentException {
      if (mounted) setState(() => _override.remove(id));
      _snack(add ? 'Could not add.' : 'Could not remove.');
    }
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
