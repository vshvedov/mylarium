import 'package:flutter/material.dart';
import '../../../app/theme/app_icons.dart';

/// Shown in place of a page that failed to load. The rest of the book stays
/// readable (graceful degradation; the page is retried on the next decode when
/// its provider is evicted).
class PageError extends StatelessWidget {
  const PageError({super.key});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(AppIcons.brokenImage,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 8),
            Text('Could not load this page',
                style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
      );
}
