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
    final Widget child;
    if (async.hasValue) {
      final provider = async.value;
      child = provider == null
          ? const _Placeholder(key: ValueKey('coverEmpty'))
          : Image(
              key: ValueKey(provider),
              image: provider,
              fit: fit,
              gaplessPlayback: true,
              semanticLabel: title,
            );
    } else {
      // Still loading (or errored without a value): bare tint.
      child = const _Placeholder(shimmer: true, key: ValueKey('coverLoading'));
    }
    return AnimatedSwitcher(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 200),
      // Force children to fill the box. The default switcher layout uses a
      // loose Stack, under which an unsized Image (fit: cover) shrinks to its
      // intrinsic aspect and centres, leaving a gap when the box aspect differs
      // from the cover's. That gap is invisible on flat tiles (box aspect ~=
      // cover aspect) but shows the deck card through the top/bottom of a
      // narrower stacked-series cover. StackFit.expand ties the image to the
      // box so the ClipRRect rounds the real image edges, matching flat tiles.
      layoutBuilder: (currentChild, previousChildren) => Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          ...previousChildren,
          ?currentChild,
        ],
      ),
      child: child,
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({super.key, this.shimmer = false});

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
