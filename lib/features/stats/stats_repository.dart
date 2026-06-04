import 'dart:convert';

import '../../core/db/database.dart';
import '../sync/sync_models.dart' show kRemoteDeviceId;
import 'stats_models.dart';

/// Rolls up the append-only `ReadingSessions` log into a [StatsSummary] for a
/// date range. Pure reads; all day boundaries are device-local and ranges are
/// half-open `[start, end)`.
///
/// Sessions synthesized for off-device reads (`deviceId == 'remote'`) count
/// toward pages, streak, heatmap, and breakdowns but are excluded from time
/// metrics (their duration was never measured).
class StatsRepository {
  StatsRepository(this._db);

  final AppDatabase _db;

  Future<StatsSummary> summary(
    DateRange range, {
    Granularity g = Granularity.day,
    DateRange? comparison,
  }) async {
    final sessions = await _db.sessionsInRange(
      range.start.millisecondsSinceEpoch,
      range.end.millisecondsSinceEpoch,
    );

    // Memoized joins (sessions are bounded; one fetch per distinct id).
    final books = <String, Book?>{};
    final metas = <String, SeriesMetaRow?>{};
    final seriesTitles = <String, String>{};

    Future<Book?> bookOf(ReadingSessionRow s) async =>
        books['${s.sourceId}/${s.bookId}'] ??= await _db.getBook(
          s.sourceId,
          s.bookId,
        );
    Future<SeriesMetaRow?> metaOf(ReadingSessionRow s) async =>
        s.seriesId.isEmpty
        ? null
        : metas['${s.sourceId}/${s.seriesId}'] ??= await _db.getSeriesMeta(
            s.sourceId,
            s.seriesId,
          );
    Future<String> seriesKeyOf(ReadingSessionRow s) async {
      if (s.seriesId.isEmpty) return 'Unknown series';
      final cached = seriesTitles['${s.sourceId}/${s.seriesId}'];
      if (cached != null) return cached;
      final row = await _db.getSeries(s.sourceId, s.seriesId);
      final title = row?.title ?? 'Unknown series';
      seriesTitles['${s.sourceId}/${s.seriesId}'] = title;
      return title;
    }

    var totalPages = 0;
    var totalSeconds = 0;
    var measuredSessions = 0;
    final completedBooks = <String>{};
    final heatmap = <DateTime, int>{};
    final days = <DateTime>{};
    final bucketPages = <DateTime, int>{};
    final bucketSeconds = <DateTime, int>{};
    final bySeries = <String, _Acc>{};
    final byGenre = <String, _Acc>{};
    final byPublisher = <String, _Acc>{};
    final byFormat = <String, _Acc>{};

    for (final s in sessions) {
      final isRemote = s.deviceId == kRemoteDeviceId;
      totalPages += s.pagesRead;
      if (!isRemote) {
        totalSeconds += s.activeSeconds;
        measuredSessions += 1;
      }
      if (s.isCompletion) completedBooks.add('${s.sourceId}/${s.bookId}');

      final day = _localDay(s.startedAt);
      days.add(day);
      heatmap.update(day, (v) => v + s.pagesRead, ifAbsent: () => s.pagesRead);

      final bucket = _bucketStart(day, g);
      bucketPages.update(
        bucket,
        (v) => v + s.pagesRead,
        ifAbsent: () => s.pagesRead,
      );
      bucketSeconds.update(
        bucket,
        (v) => v + (isRemote ? 0 : s.activeSeconds),
        ifAbsent: () => isRemote ? 0 : s.activeSeconds,
      );

      final seconds = isRemote ? 0 : s.activeSeconds;
      (bySeries[await seriesKeyOf(s)] ??= _Acc()).add(s.pagesRead, seconds);

      final book = await bookOf(s);
      (byFormat[formatLabel(book?.mediaType)] ??= _Acc()).add(
        s.pagesRead,
        seconds,
      );

      final meta = await metaOf(s);
      (byPublisher[meta?.publisher ?? 'Unknown'] ??= _Acc()).add(
        s.pagesRead,
        seconds,
      );
      for (final genre in _genresOf(meta)) {
        (byGenre[genre] ??= _Acc()).add(s.pagesRead, seconds);
      }
    }

    final overTime = (bucketPages.keys.toList()..sort())
        .map(
          (k) => TimeBucket(
            start: k,
            pages: bucketPages[k]!,
            seconds: bucketSeconds[k] ?? 0,
          ),
        )
        .toList(growable: false);

    return StatsSummary(
      totalPages: totalPages,
      totalSeconds: totalSeconds,
      booksCompleted: completedBooks.length,
      sessionCount: sessions.length,
      streakDays: _streak(days),
      avgPagesPerSession: sessions.isEmpty ? 0 : totalPages / sessions.length,
      avgSecondsPerSession: measuredSessions == 0
          ? 0
          : totalSeconds / measuredSessions,
      pagesOverTime: overTime,
      bySeries: _sorted(bySeries),
      byGenre: _sorted(byGenre),
      byPublisher: _sorted(byPublisher),
      byFormat: _sorted(byFormat),
      heatmap: heatmap,
      comparison: comparison == null ? null : await summary(comparison, g: g),
    );
  }

  List<String> _genresOf(SeriesMetaRow? meta) {
    final raw = meta?.genres;
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) return decoded.whereType<String>().toList();
    } catch (_) {
      // Malformed metadata: ignore rather than crash the stats screen.
    }
    return const [];
  }
}

DateTime _localDay(int epochMs) {
  final dt = DateTime.fromMillisecondsSinceEpoch(epochMs);
  return DateTime(dt.year, dt.month, dt.day);
}

DateTime _bucketStart(DateTime day, Granularity g) {
  switch (g) {
    case Granularity.day:
      return day;
    case Granularity.week:
      // Monday as the week start.
      return day.subtract(Duration(days: day.weekday - DateTime.monday));
    case Granularity.month:
      return DateTime(day.year, day.month);
    case Granularity.year:
      return DateTime(day.year);
  }
}

/// Consecutive local days with at least one session, counting back from the
/// most recent active day until a gap.
int _streak(Set<DateTime> days) {
  if (days.isEmpty) return 0;
  final sorted = days.toList()..sort();
  var ref = sorted.last;
  var count = 0;
  while (days.contains(ref)) {
    count += 1;
    ref = ref.subtract(const Duration(days: 1));
    ref = DateTime(ref.year, ref.month, ref.day);
  }
  return count;
}

List<Breakdown> _sorted(Map<String, _Acc> m) {
  final list = m.entries
      .map(
        (e) => Breakdown(
          key: e.key,
          pages: e.value.pages,
          seconds: e.value.seconds,
          sessions: e.value.sessions,
        ),
      )
      .toList();
  list.sort((a, b) => b.pages.compareTo(a.pages));
  return list;
}

class _Acc {
  int pages = 0;
  int seconds = 0;
  int sessions = 0;
  void add(int p, int s) {
    pages += p;
    seconds += s;
    sessions += 1;
  }
}
