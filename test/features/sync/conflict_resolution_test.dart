import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/features/sync/sync_models.dart';

ReadProgress p(int page, {bool completed = false, int t = 0}) =>
    ReadProgress(page: page, completed: completed, lastModified: t);

BookProgressState s(
  int page, {
  bool completed = false,
  int t = 0,
  int reread = 0,
  bool rereading = false,
}) => BookProgressState(
  currentPage: page,
  completed: completed,
  lastModified: t,
  timesReread: reread,
  isRereading: rereading,
);

void main() {
  group('resolveProgress (furthest-page-wins, never rewind)', () {
    test('offline further than server keeps the local page', () {
      final r = resolveProgress(p(120, t: 5), p(40, t: 9));
      expect(r.page, 120);
      expect(r.completed, isFalse);
    });

    test('server further than local takes the remote page', () {
      final r = resolveProgress(p(40, t: 9), p(120, t: 5));
      expect(r.page, 120);
    });

    test('equal page keeps the later lastModified and ORs completion', () {
      final r = resolveProgress(p(50, completed: true, t: 3), p(50, t: 8));
      expect(r.page, 50);
      expect(r.completed, isTrue);
      expect(r.lastModified, 8);
    });

    test('completion is sticky and never rewinds the page', () {
      // local completed at a lower page than a not-completed remote: page must
      // not drop, completion must stay true.
      final r = resolveProgress(p(50, completed: true, t: 9), p(200, t: 1));
      expect(r.page, 200);
      expect(r.completed, isTrue);
    });

    test('result page is never below either input', () {
      for (final pair in [
        [p(0), p(0)],
        [p(10, t: 1), p(3, t: 9)],
        [p(7, t: 9), p(7, t: 1)],
      ]) {
        final r = resolveProgress(pair[0], pair[1]);
        expect(r.page >= pair[0].page, isTrue);
        expect(r.page >= pair[1].page, isTrue);
      }
    });
  });

  group('applyProgress reread detection', () {
    test('no prior state adopts the incoming progress as reading', () {
      final o = applyProgress(null, p(5, t: 2));
      expect(o.currentPage, 5);
      expect(o.status, ReadStatus.reading);
      expect(o.startedReread, isFalse);
    });

    test('forward progress on a reading book is monotonic', () {
      final o = applyProgress(s(10, t: 1), p(25, t: 2));
      expect(o.currentPage, 25);
      expect(o.startedReread, isFalse);
      expect(o.timesReread, 0);
    });

    test('completed book with a lower incoming page starts a reread (allowed '
        'rewind)', () {
      final o = applyProgress(s(99, completed: true, t: 5), p(3, t: 9));
      expect(o.startedReread, isTrue);
      expect(o.currentPage, 3, reason: 'reread intentionally lowers the page');
      expect(o.completed, isFalse);
      expect(o.isRereading, isTrue);
      expect(o.timesReread, 1);
      expect(o.status, ReadStatus.rereading);
    });

    test('reread does not re-trigger while already rereading', () {
      final o = applyProgress(
        s(40, completed: false, t: 5, reread: 1, rereading: true),
        p(10, t: 9),
      );
      // Not completed, so no new reread pass; monotonic max keeps 40.
      expect(o.startedReread, isFalse);
      expect(o.timesReread, 1);
      expect(o.currentPage, 40);
    });

    test('completing newly sets the completed flag and clears rereading', () {
      final o = applyProgress(
        s(40, completed: false, t: 5, reread: 1, rereading: true),
        p(120, completed: true, t: 9),
      );
      expect(o.completed, isTrue);
      expect(o.newlyCompleted, isTrue);
      expect(o.isRereading, isFalse);
      expect(o.status, ReadStatus.completed);
    });
  });
}
