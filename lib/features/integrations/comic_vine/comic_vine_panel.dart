import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_icons.dart';
import '../../../data/comicvine/comic_vine_api.dart' show ComicVineApiError;
import '../../library/widgets/detail_header.dart' show HeroAction, HeroActionStyle;
import 'comic_vine_details_view.dart';
import 'comic_vine_providers.dart';

/// The Comic Vine section on a detail screen. No key -> a dashed "connect"
/// placeholder (privacy-first: off by default). With a key, it resolves the
/// matched volume (series) or issue (book) and renders loading / structured
/// details / no-match / error, and the offline placeholder when there is no
/// network and no cache.
class ComicVineDetailsPanel extends ConsumerWidget {
  const ComicVineDetailsPanel({
    super.key,
    required this.ownerKind,
    required this.sourceId,
    required this.ownerId,
  });

  /// `'series'` or `'book'`.
  final String ownerKind;
  final String sourceId;
  final String ownerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keyAsync = ref.watch(comicVineApiKeyProvider);
    if (keyAsync.isLoading) return const ComicVineLoadingView();
    if (keyAsync.valueOrNull == null) return const _ConnectPlaceholder();
    return ownerKind == 'series'
        ? _VolumeSection(sourceId: sourceId, seriesId: ownerId)
        : _IssueSection(sourceId: sourceId, bookId: ownerId);
  }
}

String _errorMessage(Object error) {
  if (error is ComicVineApiError) {
    if (error.isInvalidKey) {
      return 'Comic Vine rejected the API key. Check it in settings.';
    }
    if (error.isRateLimited) {
      return 'Comic Vine rate limit reached. Try again later.';
    }
  }
  return 'Could not load Comic Vine details.';
}

class _VolumeSection extends ConsumerWidget {
  const _VolumeSection({required this.sourceId, required this.seriesId});

  final String sourceId;
  final String seriesId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = comicVineVolumeProvider((sourceId, seriesId));
    return ref
        .watch(provider)
        .when(
          loading: () => const ComicVineLoadingView(),
          // No match and offline-without-cache render nothing (no placeholder).
          data: (d) => d == null
              ? const SizedBox.shrink()
              : ComicVineVolumeView(data: d),
          error: (e, _) => e is ComicVineOffline
              ? const SizedBox.shrink()
              : ComicVineErrorView(
                  message: _errorMessage(e),
                  onRetry: () => ref.invalidate(provider),
                ),
        );
  }
}

class _IssueSection extends ConsumerWidget {
  const _IssueSection({required this.sourceId, required this.bookId});

  final String sourceId;
  final String bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = comicVineIssueProvider((sourceId, bookId));
    return ref
        .watch(provider)
        .when(
          loading: () => const ComicVineLoadingView(),
          data: (d) => d == null
              ? const SizedBox.shrink()
              : ComicVineIssueView(data: d),
          error: (e, _) => e is ComicVineOffline
              ? const SizedBox.shrink()
              : ComicVineErrorView(
                  message: _errorMessage(e),
                  onRetry: () => ref.invalidate(provider),
                ),
        );
  }
}

class _ConnectPlaceholder extends StatelessWidget {
  const _ConnectPlaceholder();

  @override
  Widget build(BuildContext context) => _DashedPanel(
    icon: AppIcons.sources,
    accent: true,
    title: 'Comic Vine details',
    body: 'Connect Comic Vine to pull in descriptions, characters, creators '
        'and more for this title.',
    action: HeroAction(
      label: 'Add API key',
      icon: AppIcons.add,
      style: HeroActionStyle.ghost,
      compact: true,
      onPressed: () => context.push('/settings/comic-vine'),
    ),
  );
}

/// Shared dashed-border panel for the Comic Vine empty states.
class _DashedPanel extends StatelessWidget {
  const _DashedPanel({
    required this.icon,
    required this.accent,
    required this.title,
    required this.body,
    this.action,
  });

  final IconData icon;
  final bool accent;
  final String title;
  final String body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final iconColor = accent ? scheme.primary : scheme.onSurfaceVariant;
    final iconBg = accent
        ? scheme.primary.withValues(alpha: 0.12)
        : scheme.onSurface.withValues(alpha: 0.08);
    return CustomPaint(
      painter: _DashedRRectPainter(
        color: scheme.onSurface.withValues(alpha: 0.22),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              body,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            if (action != null) ...[const SizedBox(height: 18), action!],
          ],
        ),
      ),
    );
  }
}

/// Paints a dashed rounded-rectangle border that fills the painted area.
class _DashedRRectPainter extends CustomPainter {
  _DashedRRectPainter({required this.color});

  final Color color;
  static const double radius = 16;
  static const double dash = 6;
  static const double gap = 5;
  static const double stroke = 1.4;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dash;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRRectPainter old) => old.color != color;
}
