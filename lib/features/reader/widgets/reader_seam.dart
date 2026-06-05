import 'package:flutter/material.dart';

import '../../../app/theme/app_icons.dart';
import '../../../app/widgets/app_button.dart';
import '../reader_navigation.dart';

/// End-of-book "seam": shown over the last page when the reader reaches the end of
/// a chapter (T4). Offers the next book in the series (the confirm-style
/// auto-advance) or notes the series is finished. Dismissible without leaving.
class ReaderSeam extends StatelessWidget {
  const ReaderSeam({
    super.key,
    required this.title,
    required this.neighbors,
    required this.onOpenBook,
    required this.onDismiss,
  });

  /// The current book's display title.
  final String title;
  final BookNeighbors neighbors;
  final void Function(String bookId) onOpenBook;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: Colors.black.withValues(alpha: 0.72),
      child: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(AppIcons.close),
                color: scheme.onSurface,
                tooltip: 'Dismiss',
                onPressed: onDismiss,
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
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge
                          ?.copyWith(color: scheme.onSurface),
                    ),
                    const SizedBox(height: 24),
                    if (neighbors.hasNext)
                      AppButton(
                        icon: AppIcons.nextChapter,
                        label: 'Next: ${neighbors.nextTitle ?? ''}',
                        onPressed: () => onOpenBook(neighbors.nextId!),
                      )
                    else
                      Text(
                        'Last in this series',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
