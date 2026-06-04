/// Pure value types for the reading-stats roll-up. No Flutter/Drift imports so
/// the aggregation logic can be unit-tested directly.
library;

/// Bucket granularity for the pages-over-time series.
enum Granularity { day, week, month, year }

/// A half-open local-time window `[start, end)`. All stats day boundaries are
/// device-local; a session is attributed to the local calendar day of its
/// start.
class DateRange {
  const DateRange(this.start, this.end);

  final DateTime start;
  final DateTime end;

  bool contains(DateTime t) => !t.isBefore(start) && t.isBefore(end);
}

/// One bucket of the pages-over-time series.
class TimeBucket {
  const TimeBucket({
    required this.start,
    required this.pages,
    required this.seconds,
  });

  final DateTime start;
  final int pages;
  final int seconds;
}

/// A single row of a categorical breakdown (by series, genre, publisher,
/// format). [key] is the display label; "Unknown" / "Unknown series" buckets
/// missing metadata.
class Breakdown {
  const Breakdown({
    required this.key,
    required this.pages,
    required this.seconds,
    required this.sessions,
  });

  final String key;
  final int pages;
  final int seconds;
  final int sessions;
}

/// The aggregated stats for one [DateRange]. Time metrics exclude synthesized
/// off-device sessions (zero measured time); page/streak/heatmap metrics
/// include them. [byGenre] is a tag-overlap breakdown and may sum to more than
/// [totalPages] by design.
class StatsSummary {
  const StatsSummary({
    required this.totalPages,
    required this.totalSeconds,
    required this.booksCompleted,
    required this.sessionCount,
    required this.streakDays,
    required this.avgPagesPerSession,
    required this.avgSecondsPerSession,
    required this.pagesOverTime,
    required this.bySeries,
    required this.byGenre,
    required this.byPublisher,
    required this.byFormat,
    required this.heatmap,
    this.comparison,
  });

  final int totalPages;
  final int totalSeconds;
  final int booksCompleted;
  final int sessionCount;
  final int streakDays;
  final double avgPagesPerSession;
  final double avgSecondsPerSession;
  final List<TimeBucket> pagesOverTime;
  final List<Breakdown> bySeries;
  final List<Breakdown> byGenre;
  final List<Breakdown> byPublisher;
  final List<Breakdown> byFormat;

  /// Local-midnight day -> pages read that day.
  final Map<DateTime, int> heatmap;

  /// The comparable previous period (previous month / year), or null for
  /// all-time.
  final StatsSummary? comparison;

  static const empty = StatsSummary(
    totalPages: 0,
    totalSeconds: 0,
    booksCompleted: 0,
    sessionCount: 0,
    streakDays: 0,
    avgPagesPerSession: 0,
    avgSecondsPerSession: 0,
    pagesOverTime: [],
    bySeries: [],
    byGenre: [],
    byPublisher: [],
    byFormat: [],
    heatmap: {},
  );

  bool get isEmpty => sessionCount == 0;
}

/// Maps a Komga/local media type string to a friendly format bucket. Extension
/// filters are UX-only; this is best-effort from the stored mediaType.
String formatLabel(String? mediaType) {
  switch (mediaType?.toLowerCase()) {
    case 'application/vnd.comicbook+zip':
    case 'application/zip':
    case 'application/x-cbz':
      return 'CBZ';
    case 'application/vnd.comicbook-rar':
    case 'application/x-rar-compressed':
    case 'application/vnd.rar':
    case 'application/x-cbr':
      return 'CBR';
    case 'application/pdf':
      return 'PDF';
    case 'application/epub+zip':
      return 'EPUB';
    default:
      return 'Other';
  }
}
