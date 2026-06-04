import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/design_tokens.dart';
import '../thumbnail_cache.dart';

/// A cover image for a series/book. Resolves through the thumbnail cache and
/// falls back to a tinted placeholder with initials when no image is available.
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
          ? _Placeholder(title: title)
          : Image(image: provider, fit: fit, gaplessPlayback: true),
      orElse: () => _Placeholder(title: title, shimmer: true),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.title, this.shimmer = false});

  final String title;
  final bool shimmer;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tokens = Theme.of(context).extension<DesignTokens>()!;
    final initials = title.trim().isEmpty
        ? '?'
        : title.trim().split(RegExp(r'\s+')).take(2).map((w) => w[0]).join();
    return Container(
      color: scheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Text(
        initials.toUpperCase(),
        style: tokens.coverTitleStyle.copyWith(
          color: scheme.onSurfaceVariant,
          fontSize: 22,
        ),
      ),
    );
  }
}
