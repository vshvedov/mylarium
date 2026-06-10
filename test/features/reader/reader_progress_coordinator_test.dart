import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/features/reader/reader_progress_coordinator.dart';
import 'package:mylarium/features/sync/sync_engine.dart';
import 'package:mylarium/features/sync/sync_models.dart';

/// Records [recordProgress] / [recordSession] calls instead of writing. The
/// in-memory database is only constructor ballast (every overridden method
/// returns before touching it).
class FakeSyncEngine extends SyncEngine {
  FakeSyncEngine(AppDatabase db)
      : super(db, (_) async => null, deviceId: 'test-device');

  final progressCalls =
      <({String sourceId, String bookId, int page, bool completed})>[];
  final sessions = <({ReadingSessionSpan span, bool isCompletion})>[];

  @override
  Future<void> recordProgress(
    String sourceId,
    String bookId,
    int page,
    bool completed,
  ) async {
    progressCalls.add(
      (sourceId: sourceId, bookId: bookId, page: page, completed: completed),
    );
  }

  @override
  Future<void> recordSession(
    ReadingSessionSpan span, {
    required bool isCompletion,
  }) async {
    sessions.add((span: span, isCompletion: isCompletion));
  }
}

void main() {
  late AppDatabase db;
  late FakeSyncEngine engine;

  /// Manual clock fed to the coordinator; tests bump it explicitly so session
  /// spans are deterministic (independent of the fake-async timer clock).
  var now = 0;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    engine = FakeSyncEngine(db);
    now = 0;
  });
  tearDown(() async {
    await db.close();
  });

  ReaderProgressCoordinator coordinator({
    bool preview = false,
    bool Function(int page)? isLastPage,
  }) =>
      ReaderProgressCoordinator(
        syncEngine: Future.value(engine),
        sourceId: 'src',
        bookId: 'b1',
        seriesId: 'sr1',
        preview: preview,
        isLastPage: isLastPage ?? (page) => page >= 9,
        nowMs: () => now,
      );

  group('progress debounce', () {
    testWidgets('rapid page turns collapse into one write', (tester) async {
      final c = coordinator();
      c.onPage(1);
      await tester.pump(const Duration(milliseconds: 500));
      c.onPage(2);
      await tester.pump(const Duration(milliseconds: 500));
      c.onPage(3);
      // Each turn restarted the 2s debounce: nothing has been written yet.
      expect(engine.progressCalls, isEmpty);

      await tester.pump(const Duration(seconds: 2));
      expect(engine.progressCalls, hasLength(1));
      expect(engine.progressCalls.single.page, 3);
      expect(engine.progressCalls.single.completed, isFalse);
      expect(engine.progressCalls.single.sourceId, 'src');
      expect(engine.progressCalls.single.bookId, 'b1');
      c.dispose();
    });

    testWidgets('the last page flushes immediately as completed',
        (tester) async {
      final c = coordinator();
      c.onPage(9);
      // No debounce wait: the completion write is already in flight.
      await tester.pump();
      expect(engine.progressCalls, hasLength(1));
      expect(engine.progressCalls.single.page, 9);
      expect(engine.progressCalls.single.completed, isTrue);
      c.dispose();
    });
  });

  group('session checkpoint', () {
    testWidgets('emits the in-flight session and restarts recording',
        (tester) async {
      final c = coordinator(isLastPage: (page) => page >= 99);
      c.resume(0);
      now += 5000;
      c.onPage(2);

      // The periodic 60s checkpoint fires: the session so far is appended and
      // the recorder restarts at the current page. The only progress write is
      // the page-turn debounce (a checkpoint never pushes progress).
      await tester.pump(const Duration(seconds: 60));
      expect(engine.sessions, hasLength(1));
      expect(engine.sessions.single.span.startPage, 0);
      expect(engine.sessions.single.span.endPage, 2);
      expect(engine.sessions.single.span.pagesRead, 2);
      expect(engine.sessions.single.span.activeSeconds, 5);
      expect(engine.sessions.single.isCompletion, isFalse);
      expect(engine.progressCalls, hasLength(1));

      // Recording restarted at page 2: the next segment spans 2 -> 5 only
      // (no double count of the checkpointed pages).
      now += 3000;
      c.onPage(5);
      c.flush(page: 5);
      await tester.pump();
      expect(engine.sessions, hasLength(2));
      expect(engine.sessions.last.span.startPage, 2);
      expect(engine.sessions.last.span.endPage, 5);
      expect(engine.sessions.last.span.pagesRead, 3);
      c.dispose();
    });

    testWidgets('an idle checkpoint emits nothing (recorder has no events)',
        (tester) async {
      final c = coordinator();
      // No resume/onPage: the recorder is empty, so the checkpoint's
      // finalize is a no-op rather than a zero-length session row.
      await tester.pump(const Duration(seconds: 60));
      expect(engine.sessions, isEmpty);
      c.dispose();
    });
  });

  group('preview mode', () {
    testWidgets('writes no progress and records no sessions', (tester) async {
      final c = coordinator(preview: true);
      c.resume(0);
      now += 5000;
      c.onPage(2);
      c.onPage(9); // last page: would flush a completion when not previewing
      await tester.pump(const Duration(seconds: 2));
      // No checkpoint timer runs in preview, but exercise the path anyway.
      c.checkpoint();
      c.pause();
      c.flush(page: 9);
      await tester.pump();
      expect(engine.progressCalls, isEmpty);
      expect(engine.sessions, isEmpty);
      c.dispose();
    });
  });

  group('lifecycle', () {
    testWidgets('pause pushes the current position and appends the session',
        (tester) async {
      final c = coordinator();
      c.resume(3);
      now += 4000;
      c.onPage(4);
      c.pause();
      await tester.pump();
      // The pending debounce was cancelled; pause wrote the position itself.
      expect(engine.progressCalls, hasLength(1));
      expect(engine.progressCalls.single.page, 4);
      expect(engine.progressCalls.single.completed, isFalse);
      expect(engine.sessions, hasLength(1));
      expect(engine.sessions.single.span.startPage, 3);
      expect(engine.sessions.single.span.endPage, 4);

      // Resume starts a fresh segment; a later flush emits only that segment.
      c.resume(4);
      now += 2000;
      c.onPage(9);
      c.flush(page: 9);
      await tester.pump();
      expect(engine.sessions, hasLength(2));
      expect(engine.sessions.last.span.startPage, 4);
      expect(engine.sessions.last.span.endPage, 9);
      expect(engine.sessions.last.isCompletion, isTrue);
      c.dispose();
    });

    testWidgets('flush marks completion when ending on the last page',
        (tester) async {
      final c = coordinator();
      c.resume(8);
      c.flush(page: 9);
      await tester.pump();
      expect(engine.progressCalls, hasLength(1));
      expect(engine.progressCalls.single.page, 9);
      expect(engine.progressCalls.single.completed, isTrue);
      c.dispose();
    });
  });
}
