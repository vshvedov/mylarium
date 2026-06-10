import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/theme/theme_controller.dart'
    show appDatabaseProvider;
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/features/sources/sync_status_providers.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> addRow(
    String sourceId,
    String bookId, {
    String state = 'pending',
    int attempts = 0,
  }) =>
      db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
            sourceId: sourceId,
            bookId: bookId,
            page: 5,
            queuedAt: 1000,
            state: Value(state),
            attempts: Value(attempts),
          ));

  test('syncQueueStatus counts pending and failed rows per source', () async {
    await addRow('src', 'b1');
    await addRow('src', 'b2');
    await addRow('src', 'b3', state: 'failed');
    await addRow('other', 'b1', state: 'failed');

    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    final status = await container.read(syncQueueStatusProvider('src').future);
    expect(status.pending, 2);
    expect(status.failed, 1);
    expect(status.total, 3);

    final other = await container.read(syncQueueStatusProvider('other').future);
    expect(other.pending, 0);
    expect(other.failed, 1);
  });

  test('retryFailedSync flips failed rows back to pending for that source',
      () async {
    await addRow('src', 'b1', state: 'failed', attempts: 20);
    await addRow('src', 'b2', attempts: 2);
    await addRow('other', 'b3', state: 'failed');

    final flipped = await retryFailedSync(db, 'src');
    expect(flipped, 1, reason: 'only the failed row of this source is touched');

    final rows = await db.select(db.syncQueue).get();
    final b1 = rows.singleWhere((r) => r.bookId == 'b1');
    expect(b1.state, 'pending');
    expect(b1.attempts, 0, reason: 'fresh transient budget after a retry');

    final b2 = rows.singleWhere((r) => r.bookId == 'b2');
    expect(b2.state, 'pending');
    expect(b2.attempts, 2, reason: 'an already-pending row is untouched');

    final b3 = rows.singleWhere((r) => r.bookId == 'b3');
    expect(b3.state, 'failed', reason: 'other sources are untouched');
  });
}
