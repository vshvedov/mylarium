import 'package:flutter/widgets.dart';

import '../../app/l10n.dart';
import '../../app/theme/app_icons.dart';
import 'stats_models.dart';

/// A milestone badge. [earned] is computed from a [StatsSummary] by
/// [earnedBadges]; the strip renders earned ones prominently and locked ones
/// dimmed.
class Badge {
  const Badge({
    required this.id,
    required this.label,
    required this.icon,
    required this.earned,
  });

  final String id;

  /// English label, retained for non-UI use; the UI uses [localizedLabel].
  final String label;
  final IconData icon;
  final bool earned;

  /// Localized milestone label, keyed by [id]; falls back to [label].
  String localizedLabel(BuildContext context) {
    final l10n = context.l10n;
    return switch (id) {
      'firstBook' => l10n.badgeFirstBook,
      'tenBooks' => l10n.badgeTenBooks,
      'fiftyBooks' => l10n.badgeFiftyBooks,
      'centuryBooks' => l10n.badgeHundredBooks,
      'weekStreak' => l10n.badgeWeekStreak,
      'monthStreak' => l10n.badgeMonthStreak,
      'thousandPages' => l10n.badgeThousandPages,
      'tenKPages' => l10n.badgeTenThousandPages,
      _ => label,
    };
  }
}

/// Evaluates the fixed milestone set against [s]. Pure: each badge's [earned]
/// flag is a threshold on a summary metric. Order is stable (used for layout).
List<Badge> earnedBadges(StatsSummary s) => [
  Badge(
    id: 'firstBook',
    label: 'First book',
    icon: AppIcons.trophy,
    earned: s.booksCompleted >= 1,
  ),
  Badge(
    id: 'tenBooks',
    label: '10 books',
    icon: AppIcons.trophy,
    earned: s.booksCompleted >= 10,
  ),
  Badge(
    id: 'fiftyBooks',
    label: '50 books',
    icon: AppIcons.trophy,
    earned: s.booksCompleted >= 50,
  ),
  Badge(
    id: 'centuryBooks',
    label: '100 books',
    icon: AppIcons.badge,
    earned: s.booksCompleted >= 100,
  ),
  Badge(
    id: 'weekStreak',
    label: '7 day streak',
    icon: AppIcons.flame,
    earned: s.streakDays >= 7,
  ),
  Badge(
    id: 'monthStreak',
    label: '30 day streak',
    icon: AppIcons.flame,
    earned: s.streakDays >= 30,
  ),
  Badge(
    id: 'thousandPages',
    label: '1,000 pages',
    icon: AppIcons.pages,
    earned: s.totalPages >= 1000,
  ),
  Badge(
    id: 'tenKPages',
    label: '10,000 pages',
    icon: AppIcons.pages,
    earned: s.totalPages >= 10000,
  ),
];
