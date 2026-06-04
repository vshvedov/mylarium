import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/features/sync/sync_models.dart';

ReadingSessionSpan? buildOf(ReadingSessionRecorder r) =>
    r.build(sourceId: 'src', bookId: 'b', seriesId: 's');

void main() {
  group('ReadingSessionRecorder active time', () {
    test('single page event reports nothing (no time, no pages)', () {
      final r = ReadingSessionRecorder()..onPage(0, 1000);
      expect(buildOf(r), isNull);
    });

    test('sums inter-page gaps as active seconds', () {
      final r = ReadingSessionRecorder()
        ..onPage(0, 0)
        ..onPage(1, 3000)
        ..onPage(2, 5000);
      final d = buildOf(r)!;
      expect(d.activeSeconds, 5); // 3s + 2s
      expect(d.pagesRead, 2);
      expect(d.startPage, 0);
      expect(d.endPage, 2);
    });

    test('idle gaps above the cap are clamped', () {
      final r = ReadingSessionRecorder()
        ..onPage(0, 0)
        ..onPage(1, 30 * 60 * 1000); // 30 min idle -> capped at 5 min
      final d = buildOf(r)!;
      expect(d.activeSeconds, kIdleCapMs ~/ 1000);
    });

    test('backward paging never lowers pagesRead', () {
      final r = ReadingSessionRecorder()
        ..onPage(0, 0)
        ..onPage(10, 2000)
        ..onPage(4, 4000);
      final d = buildOf(r)!;
      expect(d.pagesRead, 10); // maxPage 10 - startPage 0
      expect(d.endPage, 4);
    });

    test('pause then resume does not double count the paused gap', () {
      final r = ReadingSessionRecorder()
        ..onPage(0, 0)
        ..onPage(1, 2000) // +2s active
        ..pause(3000) // +1s active, then frozen
        ..resume(100000) // long background gap, not counted
        ..onPage(2, 101000); // +1s active
      final d = buildOf(r)!;
      expect(d.activeSeconds, 4); // 2 + 1 + 1
    });

    test('pause flushes the in-flight gap once', () {
      final r = ReadingSessionRecorder()
        ..onPage(0, 0)
        ..onPage(1, 1000)
        ..pause(2000);
      final d = buildOf(r)!;
      expect(d.activeSeconds, 2);
    });

    test(
      'reset clears state so a fresh segment emits nothing until events',
      () {
        final r = ReadingSessionRecorder()
          ..onPage(0, 0)
          ..onPage(1, 1000);
        expect(buildOf(r), isNotNull);
        r.reset();
        expect(r.hasEvents, isFalse);
        expect(buildOf(r), isNull);
      },
    );

    test('a turn with pages but zero measured time still emits', () {
      final r = ReadingSessionRecorder()
        ..onPage(0, 0)
        ..onPage(5, 0); // same instant, real page advance
      final d = buildOf(r)!;
      expect(d.activeSeconds, 0);
      expect(d.pagesRead, 5);
    });
  });
}
