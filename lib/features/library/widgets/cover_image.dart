import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_icons.dart';
import '../thumbnail_cache.dart';

/// A cover image for a series/book. Resolves through the thumbnail cache and
/// falls back to a clean tinted placeholder (cover icon + title) when no image
/// is available; a bare tint while loading.
class CoverImage extends ConsumerWidget {
  const CoverImage({
    super.key,
    required this.sourceId,
    required this.ownerType,
    required this.ownerId,
    required this.title,
    this.fit = BoxFit.cover,
  });

  final String sourceId;
  final String ownerType;
  final String ownerId;
  final String title;
  final BoxFit fit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(
      coverImageProvider(sourceId, ownerType, ownerId),
    );
    return async.maybeWhen(
      data: (provider) => provider == null
          ? const _Placeholder()
          : Image(
              image: provider,
              fit: fit,
              gaplessPlayback: true,
              semanticLabel: title,
            ),
      orElse: () => const _Placeholder(shimmer: true),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({this.shimmer = false});

  /// True while the cover is still loading (bare tint, no icon).
  final bool shimmer;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (shimmer) {
      return ColoredBox(color: scheme.surfaceContainerHighest);
    }
    // Just a muted cover icon: the title is already shown beneath cover tiles,
    // so repeating it here would be redundant (and clutters small tiles).
    return Container(
      color: scheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(AppIcons.coverPlaceholder,
          size: 28, color: scheme.onSurfaceVariant.withValues(alpha: 0.6)),
    );
  }
}
