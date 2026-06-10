import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/l10n.dart';
import '../../app/theme/app_icons.dart';
import '../../app/theme/design_tokens.dart';
import '../../app/widgets/app_loading.dart';
import 'capture_models.dart';
import 'gallery_controller.dart';

/// The personal gallery: every saved page capture, newest first. Tapping a tile
/// returns to the exact chapter and page (in preview mode, so revisiting a saved
/// moment never moves reading progress backward); long-press deletes.
class GalleryScreen extends ConsumerWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(capturesProvider);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.galleryTitle)),
      body: async.when(
        loading: () => const AppLoadingIndicator(),
        error: (_, _) => Center(child: Text(context.l10n.galleryLoadError)),
        data: (captures) => captures.isEmpty
            ? const _EmptyGallery()
            : GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate:
                    const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 160,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  // Taller than the thumbnail alone to leave room for the
                  // chapter-name caption beneath it.
                  childAspectRatio: 0.66,
                ),
                itemCount: captures.length,
                itemBuilder: (_, i) => _CaptureTile(capture: captures[i]),
              ),
      ),
    );
  }
}

class _CaptureTile extends ConsumerWidget {
  const _CaptureTile({required this.capture});

  final Capture capture;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final chapter = capture.bookTitle ?? context.l10n.galleryUntitled;
    return Semantics(
      label: chapter,
      button: true,
      child: Material(
        color: scheme.surfaceContainerHighest,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          // Tapping opens the snippet itself; "Go to page" lives in the viewer.
          onTap: () => context.push('/capture/${capture.id}'),
          onLongPress: () => _confirmDelete(context, ref),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Image.file(
                  File(capture.absolutePath),
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  errorBuilder: (_, _, _) => Center(
                    child: Icon(
                      AppIcons.brokenImage,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                child: Text(
                  chapter,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      barrierColor: einkOf(context) ? kEinkBarrierColor : null,
      builder: (_) => AlertDialog(
        title: Text(context.l10n.galleryDeleteTitle),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(capturesRepositoryProvider).delete(capture.id);
  }
}

class _EmptyGallery extends StatelessWidget {
  const _EmptyGallery();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.gallery, size: 44, color: scheme.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(context.l10n.galleryEmpty),
        ],
      ),
    );
  }
}
