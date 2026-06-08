import 'package:flutter/material.dart';

import '../../app/theme/app_icons.dart';
import '../../app/theme/design_tokens.dart';
import 'badges.dart';
import 'stats_models.dart';

/// A shareable "year in review" summary card. Phase 1 renders it on-device only
/// (no network sharing); the layout is share-ready for a future export.
class WrapCard extends StatelessWidget {
  const WrapCard({super.key, required this.year, required this.summary});

  final int year;
  final StatsSummary summary;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final eink = Theme.of(context).extension<DesignTokens>()?.isEink ?? false;
    final text = Theme.of(context).textTheme;
    final topGenre = summary.byGenre.isEmpty ? null : summary.byGenre.first.key;
    final earned = earnedBadges(summary).where((b) => b.earned).toList();

    return Container(
      width: 320,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: eink ? scheme.surface : null,
        border: eink ? Border.all(color: scheme.outlineVariant) : null,
        gradient: eink
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [scheme.primaryContainer, scheme.surfaceContainerHighest],
              ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(AppIcons.trophy, color: scheme.primary, size: 28),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '$year in review',
                  style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _BigStat(value: '${summary.totalPages}', label: 'pages read'),
          const SizedBox(height: 12),
          _BigStat(
            value: '${(summary.totalSeconds / 3600).toStringAsFixed(1)} h',
            label: 'time reading',
          ),
          const SizedBox(height: 12),
          _BigStat(value: '${summary.booksCompleted}', label: 'books finished'),
          if (topGenre != null) ...[
            const SizedBox(height: 12),
            _BigStat(value: topGenre, label: 'top genre'),
          ],
          if (earned.isNotEmpty) ...[
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final b in earned)
                  Chip(
                    avatar: Icon(b.icon, size: 16, color: scheme.primary),
                    label: Text(b.label),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _BigStat extends StatelessWidget {
  const _BigStat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: text.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        Text(label, style: text.bodyMedium),
      ],
    );
  }
}
