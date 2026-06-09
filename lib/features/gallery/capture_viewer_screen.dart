import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_icons.dart';
import '../../app/theme/design_tokens.dart';
import '../../app/widgets/app_loading.dart';
import 'capture_models.dart';
import 'gallery_controller.dart';

/// Full-screen viewer for a single captured snippet: the saved image itself
/// (pan/zoom), with a "Go to page" action that jumps to the exact chapter+page
/// it was taken from. The jump is offered only when that chapter can still be
/// opened (see [captureChapterAvailableProvider]); a capture whose chapter was
/// deleted is still viewable, just without the jump.
class CaptureViewerScreen extends ConsumerWidget {
  const CaptureViewerScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<DesignTokens>()!;
    final async = ref.watch(captureByIdProvider(id));
    final capture = async.valueOrNull;
    return Scaffold(
      backgroundColor: tokens.readerBackground,
      appBar: AppBar(
        backgroundColor: tokens.readerBackground,
        title: capture == null ? null : Text(_caption(capture)),
        actions: [
          if (capture != null)
            IconButton(
              icon: const Icon(AppIcons.delete),
              tooltip: 'Delete capture',
              onPressed: () => _confirmDelete(context, ref),
            ),
        ],
      ),
      body: async.when(
        loading: () => const AppLoadingIndicator(),
        error: (_, _) =>
            const Center(child: Text('This capture is no longer available.')),
        data: (capture) => capture == null
            ? const Center(child: Text('This capture is no longer available.'))
            : _Viewer(capture: capture),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      barrierColor: einkOf(context) ? kEinkBarrierColor : null,
      builder: (_) => AlertDialog(
        title: const Text('Delete capture?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await ref.read(capturesRepositoryProvider).delete(id);
    if (context.mounted) context.pop();
  }
}

String _caption(Capture c) {
  final series = c.seriesTitle ?? 'Unknown series';
  return '$series · ${c.bookTitle ?? 'Untitled'} · p.${c.pageNumber + 1}';
}

class _Viewer extends StatelessWidget {
  const _Viewer({required this.capture});

  final Capture capture;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Expanded(
          child: InteractiveViewer(
            minScale: 1,
            maxScale: 6,
            child: Center(
              child: Image.file(
                File(capture.absolutePath),
                fit: BoxFit.contain,
                gaplessPlayback: true,
                errorBuilder: (_, _, _) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(AppIcons.brokenImage,
                        size: 44, color: scheme.onSurfaceVariant),
                    const SizedBox(height: 12),
                    const Text('This snippet image is missing.'),
                  ],
                ),
              ),
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: _GoToPageButton(capture: capture),
          ),
        ),
      ],
    );
  }
}

/// The "Go to page" action, shown only when the source chapter can still be
/// opened. Renders nothing while the availability check is loading or when the
/// chapter is gone.
class _GoToPageButton extends ConsumerWidget {
  const _GoToPageButton({required this.capture});

  final Capture capture;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final available = ref
            .watch(captureChapterAvailableProvider(
                capture.sourceId, capture.bookId))
            .valueOrNull ??
        false;
    if (!available) return const SizedBox.shrink();
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        icon: const Icon(AppIcons.read),
        label: const Text('Go to page'),
        // Preview mode: revisiting the captured page never moves reading
        // progress backward.
        onPressed: () => context.push(
          '/reader/${capture.sourceId}/${capture.bookId}'
          '?page=${capture.pageNumber}&preview=true',
        ),
      ),
    );
  }
}
