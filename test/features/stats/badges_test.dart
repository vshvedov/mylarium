import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/features/stats/badges.dart';
import 'package:mylarium/features/stats/stats_models.dart';

StatsSummary summary({int books = 0, int streak = 0, int pages = 0}) =>
    StatsSummary(
      totalPages: pages,
      totalSeconds: 0,
      booksCompleted: books,
      sessionCount: 1,
      streakDays: streak,
      avgPagesPerSession: 0,
      avgSecondsPerSession: 0,
      pagesOverTime: const [],
      bySeries: const [],
      byGenre: const [],
      byPublisher: const [],
      byFormat: const [],
      heatmap: const {},
    );

bool earned(StatsSummary s, String id) =>
    earnedBadges(s).firstWhere((b) => b.id == id).earned;

void main() {
  group('earnedBadges thresholds', () {
    test('nothing earned at zero', () {
      final b = earnedBadges(StatsSummary.empty);
      expect(b.every((x) => !x.earned), isTrue);
      expect(b.length, 8);
    });

    test('book milestones', () {
      expect(earned(summary(books: 1), 'firstBook'), isTrue);
      expect(earned(summary(books: 9), 'tenBooks'), isFalse);
      expect(earned(summary(books: 10), 'tenBooks'), isTrue);
      expect(earned(summary(books: 50), 'fiftyBooks'), isTrue);
      expect(earned(summary(books: 100), 'centuryBooks'), isTrue);
    });

    test('streak milestones', () {
      expect(earned(summary(streak: 6), 'weekStreak'), isFalse);
      expect(earned(summary(streak: 7), 'weekStreak'), isTrue);
      expect(earned(summary(streak: 30), 'monthStreak'), isTrue);
    });

    test('page milestones', () {
      expect(earned(summary(pages: 999), 'thousandPages'), isFalse);
      expect(earned(summary(pages: 1000), 'thousandPages'), isTrue);
      expect(earned(summary(pages: 10000), 'tenKPages'), isTrue);
    });
  });
}
