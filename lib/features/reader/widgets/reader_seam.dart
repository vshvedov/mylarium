import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/theme/app_icons.dart';
import '../../../app/theme/design_tokens.dart';
import '../../../app/widgets/app_button.dart';
import '../reader_navigation.dart';

/// End-of-book "seam": shown over the last page when the reader reaches the end
/// of a chapter. Offers the next book in the series or notes the series is
/// finished, and is dismissible without leaving.
///
/// With [autoAdvance] on and a next book available (T2), it counts down and
/// loads the next book automatically after [autoAdvanceDelay], with a Cancel
/// that stops the countdown and falls back to the manual "Next" button. The
/// countdown delay is plumbed (not animated state) so it is direction-agnostic
/// (RTL is the next book's concern) and honors reduce-motion by not animating
/// the progress indicator.
class ReaderSeam extends StatefulWidget {
  const ReaderSeam({
    super.key,
    required this.title,
    required this.neighbors,
    required this.onOpenBook,
    required this.onDismiss,
    this.autoAdvance = false,
    this.autoAdvanceDelay = const Duration(seconds: 5),
  });

  /// The current book's display title.
  final String title;
  final BookNeighbors neighbors;
  final void Function(String bookId) onOpenBook;
  final VoidCallback onDismiss;

  /// When true and [BookNeighbors.hasNext], the seam auto-loads the next book
  /// after [autoAdvanceDelay] unless cancelled.
  final bool autoAdvance;
  final Duration autoAdvanceDelay;

  @override
  State<ReaderSeam> createState() => _ReaderSeamState();
}

class _ReaderSeamState extends State<ReaderSeam> {
  Timer? _timer;
  bool _counting = false;

  bool get _willAutoAdvance =>
      widget.autoAdvance && widget.neighbors.hasNext;

  @override
  void initState() {
    super.initState();
    if (_willAutoAdvance) {
      _counting = true;
      _timer = Timer(widget.autoAdvanceDelay, () {
        if (mounted) widget.onOpenBook(widget.neighbors.nextId!);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _cancelCountdown() {
    _timer?.cancel();
    _timer = null;
    if (_counting) setState(() => _counting = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final eink = theme.extension<DesignTokens>()?.isEink ?? false;
    return Material(
      color: eink ? scheme.surface : Colors.black.withValues(alpha: 0.72),
      child: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(AppIcons.close),
                color: scheme.onSurface,
                tooltip: 'Dismiss',
                onPressed: () {
                  _cancelCountdown();
                  widget.onDismiss();
                },
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Finished',
                      style: theme.textTheme.labelLarge
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge
                          ?.copyWith(color: scheme.onSurface),
                    ),
                    const SizedBox(height: 24),
                    ..._actions(theme, scheme),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _actions(ThemeData theme, ColorScheme scheme) {
    if (!widget.neighbors.hasNext) {
      return [
        Text(
          'Last in this series',
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ];
    }
    final nextLabel = widget.neighbors.nextTitle ?? '';
    void openNext() => widget.onOpenBook(widget.neighbors.nextId!);
    if (_counting) {
      return [
        Text(
          'Up next: $nextLabel',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurface),
        ),
        const SizedBox(height: 16),
        AppButton(
          icon: AppIcons.nextChapter,
          label: 'Read now',
          onPressed: openNext,
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _cancelCountdown,
          child: const Text('Cancel auto-advance'),
        ),
      ];
    }
    return [
      AppButton(
        icon: AppIcons.nextChapter,
        label: 'Next: $nextLabel',
        onPressed: openNext,
      ),
    ];
  }
}
