import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';

import '../../core/db/database.dart';
import '../../core/network/komga_exception.dart';
import '../../data/komga/komga_api.dart';
import 'sync_models.dart';

/// Max Komga books reconciled per launch (rotation cap). Rows are visited
/// least-recently-reconciled first, so the whole library is covered over
/// successive launches without starving the tail.
const int kReconcileBatch = 50;

/// Reconciles local [BookState] with Komga read-progress on launch. Pulls each
/// tracked Komga book's server progress, merges it (furthest-page-wins, never
/// rewind), and synthesizes a reading session for any off-device advance so the
/// stats reflect reads that happened elsewhere.
class Reconciler {
  Reconciler(
    this._db,
    this._apiFor, {
    required this.deviceId,
    int Function()? now,
  }) : _now = now ?? (() => DateTime.now().millisecondsSinceEpoch);

  final AppDatabase _db;
  final Future<KomgaApi?> Function(String sourceId) _apiFor;
  final String deviceId;
  final int Function() _now;
  final _uuid = const Uuid();

  Future<void> reconcile() async {
    final komgaIds = (await _db.allSources())
        .where((s) => s.kind == 'komga')
        .map((s) => s.id)
        .toSet();
    if (komgaIds.isEmpty) return;

    final rows = await _db.bookStatesForReconcile(
      komgaIds,
      limit: kReconcileBatch,
    );
    final apis = <String, KomgaApi?>{};
    for (final cur in rows) {
      final api = apis[cur.sourceId] ??= await _apiFor(cur.sourceId);
      if (api == null) continue;
      try {
        await _reconcileOne(cur, api);
      } on KomgaException catch (e) {
        if (_isConnectivity(e)) return; // server down; try again next launch
        // A per-book error (deleted / forbidden): advance the rotation clock so
        // this row rotates out, then keep going.
        await _db.upsertBookState(
          BookStateCompanion(
            sourceId: Value(cur.sourceId),
            bookId: Value(cur.bookId),
            reconciledAt: Value(_now()),
            updatedAt: Value(cur.updatedAt),
          ),
        );
      }
    }
  }

  Future<void> _reconcileOne(BookStateRow cur, KomgaApi api) async {
    final dto = await api.getBook(cur.bookId);
    final runNow = _now();

    // Server has no read progress for this book: advance the rotation clock so
    // the row leaves the never-reconciled head; the server freshness baseline
    // stays a server value (null here means the server has nothing).
    if (dto.readPage == null) {
      await _db.upsertBookState(
        BookStateCompanion(
          sourceId: Value(cur.sourceId),
          bookId: Value(cur.bookId),
          reconciledAt: Value(runNow),
          remoteUpdatedAt: Value(dto.readLastModified),
          updatedAt: Value(cur.updatedAt),
        ),
      );
      return;
    }

    final remoteMod = dto.readLastModified;
    // Nothing new since we last reconciled this book.
    if (remoteMod != null &&
        cur.remoteUpdatedAt != null &&
        remoteMod <= cur.remoteUpdatedAt!) {
      return;
    }

    final priorPage = cur.currentPage;
    final remote = ReadProgress(
      page: dto.readPage! - 1, // 1-based Komga -> 0-based internal
      completed: dto.completed,
      lastModified: remoteMod ?? runNow,
    );
    final curState = BookProgressState(
      currentPage: cur.currentPage,
      completed: cur.status == ReadStatus.completed.name,
      lastModified: cur.updatedAt,
      timesReread: cur.timesReread,
      isRereading: cur.isRereading,
    );
    final outcome = applyProgress(curState, remote);

    await _db.upsertBookState(
      BookStateCompanion(
        sourceId: Value(cur.sourceId),
        bookId: Value(cur.bookId),
        status: Value(outcome.status.name),
        currentPage: Value(outcome.currentPage),
        timesReread: Value(outcome.timesReread),
        isRereading: Value(outcome.isRereading),
        startedAt: Value(cur.startedAt ?? runNow),
        finishedAt: outcome.newlyCompleted
            ? Value(runNow)
            : Value(cur.finishedAt),
        updatedAt: Value(runNow),
        reconciledAt: Value(runNow),
        remoteUpdatedAt: Value(remoteMod),
      ),
    );

    // An off-device advance: synthesize a session for the catch-up read. Timed
    // at the server readDate (we cannot know its duration), with activeSeconds
    // 0 and the reserved 'remote' deviceId so stats exclude it from time
    // metrics but still count its pages.
    if (remote.page > priorPage) {
      final ts = dto.readDate ?? remoteMod ?? runNow;
      await _db.insertReadingSession(
        ReadingSessionsCompanion.insert(
          id: _uuid.v4(),
          sourceId: cur.sourceId,
          bookId: cur.bookId,
          seriesId: dto.seriesId,
          startedAt: ts,
          endedAt: ts,
          activeSeconds: 0,
          startPage: priorPage,
          endPage: remote.page,
          pagesRead: remote.page - priorPage,
          isCompletion: Value(remote.completed),
          rereadIndex: Value(outcome.timesReread),
          deviceId: kRemoteDeviceId,
        ),
      );
    }
  }
}

bool _isConnectivity(KomgaException e) =>
    e.kind == KomgaErrorKind.unreachable ||
    e.kind == KomgaErrorKind.tls ||
    e.kind == KomgaErrorKind.unauthorized;
