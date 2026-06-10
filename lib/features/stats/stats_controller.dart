import 'package:flutter/widgets.dart' show BuildContext;
import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/l10n.dart';
import '../sync/sync_providers.dart';
import 'stats_models.dart';

part 'stats_controller.g.dart';

/// The period the stats screen is showing.
enum StatsPeriod { month, year, allTime }

extension StatsPeriodLabel on StatsPeriod {
  /// English label, retained for non-UI use; the UI uses [localizedLabel].
  String get label => switch (this) {
    StatsPeriod.month => 'Month',
    StatsPeriod.year => 'Year',
    StatsPeriod.allTime => 'All time',
  };

  /// Localized period label for the stats period switcher.
  String localizedLabel(BuildContext context) => switch (this) {
        StatsPeriod.month => context.l10n.statsPeriodMonth,
        StatsPeriod.year => context.l10n.statsPeriodYear,
        StatsPeriod.allTime => context.l10n.statsPeriodAllTime,
      };
}

/// Computes the [StatsSummary] for [period], picking the local-time range, the
/// comparable previous period, and the bucket granularity.
@riverpod
Future<StatsSummary> statsSummary(Ref ref, StatsPeriod period) async {
  final repo = ref.watch(statsRepositoryProvider);
  final now = DateTime.now();
  final (
    DateRange range,
    DateRange? comparison,
    Granularity g,
  ) = switch (period) {
    StatsPeriod.month => (
      DateRange(
        DateTime(now.year, now.month),
        DateTime(now.year, now.month + 1),
      ),
      DateRange(
        DateTime(now.year, now.month - 1),
        DateTime(now.year, now.month),
      ),
      Granularity.day,
    ),
    StatsPeriod.year => (
      DateRange(DateTime(now.year), DateTime(now.year + 1)),
      DateRange(DateTime(now.year - 1), DateTime(now.year)),
      Granularity.month,
    ),
    StatsPeriod.allTime => (
      DateRange(DateTime(2000), DateTime(now.year + 1)),
      null,
      Granularity.year,
    ),
  };
  return repo.summary(range, g: g, comparison: comparison);
}
