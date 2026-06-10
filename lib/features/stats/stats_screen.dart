import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n.dart';
import '../../app/theme/app_icons.dart';
import '../../app/theme/design_tokens.dart';
import '../../app/widgets/app_card.dart';
import '../../app/widgets/app_loading.dart';
import '../../app/widgets/app_segmented_toggle.dart';
import 'badges.dart';
import 'stats_controller.dart';
import 'stats_models.dart';
import 'widgets/bar_chart.dart';
import 'widgets/heatmap.dart';
import 'wrap_card.dart';

/// The reading-stats screen: a period switcher over month / year / all-time,
/// totals with period-over-period deltas, a pages-over-time chart, source-wide
/// breakdowns, a streak and daily heatmap, milestone badges, and a year-in-
/// review wrap card.
class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  StatsPeriod _period = StatsPeriod.month;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(statsSummaryProvider(_period));
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.statsTitle),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.share),
            tooltip: context.l10n.statsYearInReview,
            onPressed: () => _openWrap(context),
          ),
        ],
      ),
      body: async.when(
        loading: () => const AppLoadingIndicator(),
        error: (_, _) =>
            Center(child: Text(context.l10n.statsLoadError)),
        data: (s) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppSegmentedToggle<StatsPeriod>(
              segments: [
                for (final p in StatsPeriod.values)
                  AppSegment(p, p.localizedLabel(context)),
              ],
              selected: _period,
              onChanged: (v) => setState(() => _period = v),
            ),
            const SizedBox(height: 16),
            if (s.isEmpty) const _EmptyStats() else ..._content(context, s),
          ],
        ),
      ),
    );
  }

  List<Widget> _content(BuildContext context, StatsSummary s) {
    return [
      _KpiGrid(summary: s),
      const SizedBox(height: 20),
      _Section(
        title: context.l10n.statsPagesOverTime,
        icon: AppIcons.trend,
        child: BarChart(
          data: [
            for (final b in s.pagesOverTime)
              BarDatum(_bucketLabel(b.start), b.pages),
          ],
        ),
      ),
      _Section(
        title: context.l10n.statsDailyActivity,
        icon: AppIcons.heatmap,
        trailing: context.l10n.statsDayStreak(s.streakDays),
        child: Heatmap(pagesByDay: s.heatmap),
      ),
      _Section(
        title: context.l10n.statsBySeries,
        icon: AppIcons.libraries,
        child: _BreakdownList(rows: s.bySeries),
      ),
      _Section(
        title: context.l10n.statsByGenre,
        icon: AppIcons.browse,
        footnote: context.l10n.statsByGenreFootnote,
        child: _BreakdownList(rows: s.byGenre),
      ),
      _Section(
        title: context.l10n.statsByPublisher,
        icon: AppIcons.sources,
        child: _BreakdownList(rows: s.byPublisher),
      ),
      _Section(
        title: context.l10n.statsByFormat,
        icon: AppIcons.read,
        child: _BreakdownList(rows: s.byFormat),
      ),
      _Section(
        title: context.l10n.statsMilestones,
        icon: AppIcons.badge,
        child: _BadgeStrip(summary: s),
      ),
      const SizedBox(height: 8),
      Text(
        context.l10n.statsTotalReadingTime(
          formatReadingDuration(Duration(seconds: s.totalSeconds)),
          s.sessionCount,
        ),
        style: Theme.of(context).textTheme.bodySmall,
      ),
    ];
  }

  void _openWrap(BuildContext context) {
    final year = DateTime.now().year;
    final async = ref.read(statsSummaryProvider(StatsPeriod.year));
    final summary = async.valueOrNull ?? StatsSummary.empty;
    showDialog<void>(
      context: context,
      barrierColor: einkOf(context) ? kEinkBarrierColor : null,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: WrapCard(year: year, summary: summary),
      ),
    );
  }
}

String _bucketLabel(DateTime d) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  // Heuristic label: day-of-month for fine buckets, month for monthly, year for
  // yearly. Good enough for an axis tick.
  if (d.day != 1) return '${d.day}';
  if (d.month != 1) return months[d.month - 1];
  return '${d.year}';
}

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({required this.summary});
  final StatsSummary summary;

  @override
  Widget build(BuildContext context) {
    final c = summary.comparison;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: [
        _Kpi(
          icon: AppIcons.pages,
          label: context.l10n.kpiPages,
          value: '${summary.totalPages}',
          delta: c == null ? null : summary.totalPages - c.totalPages,
        ),
        _Kpi(
          icon: AppIcons.clock,
          // Short label: the unit lives in the value ('24 min' / '1.5 h') and
          // the KPI tile is narrow on phones.
          label: context.l10n.kpiTime,
          value: formatReadingDuration(
            Duration(seconds: summary.totalSeconds),
          ),
          delta: null,
        ),
        _Kpi(
          icon: AppIcons.read,
          label: context.l10n.kpiBooks,
          value: '${summary.booksCompleted}',
          delta: c == null ? null : summary.booksCompleted - c.booksCompleted,
        ),
        _Kpi(
          icon: AppIcons.streak,
          label: context.l10n.kpiStreak,
          value: '${summary.streakDays}d',
          delta: null,
        ),
      ],
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({
    required this.icon,
    required this.label,
    required this.value,
    required this.delta,
  });

  final IconData icon;
  final String label;
  final String value;
  final int? delta;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return AppCard(
      child: Row(
        children: [
          Icon(icon, color: scheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Single line, scaled down when narrow: a unit-bearing value
                // like '25 min' must never wrap and overflow the fixed-aspect
                // KPI tile on phone widths.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    maxLines: 1,
                    style:
                        text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodySmall,
                      ),
                    ),
                    if (delta != null && delta != 0) ...[
                      const SizedBox(width: 6),
                      Text(
                        '${delta! > 0 ? '+' : ''}$delta',
                        style: text.bodySmall?.copyWith(
                          color: delta! > 0 ? Colors.green : scheme.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
    this.footnote,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final String? trailing;
  final String? footnote;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: text.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (trailing != null) Text(trailing!, style: text.labelLarge),
            ],
          ),
          if (footnote != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                footnote!,
                style: text.bodySmall?.copyWith(
                  color: Theme.of(context).hintColor,
                ),
              ),
            ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

/// Maps a breakdown bucket key to a localized label. Most keys are real data
/// (a series, publisher, genre, or format name) and pass through unchanged;
/// only the special English placeholder buckets produced by the stats layer
/// ("Unknown series", "Unknown", "Other") are translated.
String _breakdownLabel(BuildContext context, String key) => switch (key) {
      'Unknown series' => context.l10n.statsUnknownSeries,
      'Unknown' => context.l10n.statsUnknown,
      'Other' => context.l10n.statsOther,
      _ => key,
    };

class _BreakdownList extends StatelessWidget {
  const _BreakdownList({required this.rows});
  final List<Breakdown> rows;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return Text(context.l10n.statsNoData,
          style: Theme.of(context).textTheme.bodySmall);
    }
    final shown = rows.take(6).toList();
    final top = shown.first.pages == 0 ? 1 : shown.first.pages;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        for (final r in shown)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    _breakdownLabel(context, r.key),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (r.pages / top).clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor: scheme.surfaceContainerHighest,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${r.pages}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _BadgeStrip extends StatelessWidget {
  const _BadgeStrip({required this.summary});
  final StatsSummary summary;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final badges = earnedBadges(summary);
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final b in badges)
          Opacity(
            opacity: b.earned ? 1 : 0.35,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: b.earned
                      ? scheme.primaryContainer
                      : scheme.surfaceContainerHighest,
                  child: Icon(
                    b.icon,
                    color: b.earned
                        ? scheme.onPrimaryContainer
                        : scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: 64,
                  child: Text(
                    b.localizedLabel(context),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _EmptyStats extends StatelessWidget {
  const _EmptyStats();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(40),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(AppIcons.stats, size: 44),
          const SizedBox(height: 12),
          Text(
            context.l10n.statsEmptyTitle,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.statsEmptyBody,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    ),
  );
}
