import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/theme/theme_controller.dart'
    show appDatabaseProvider;
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/data/source/source_providers.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.getOrCreateSettings();
  });
  tearDown(() => db.close());

  ProviderContainer container() => ProviderContainer(overrides: [
        appDatabaseProvider.overrideWithValue(db),
      ]);

  Future<void> addSource(String id, String kind, String label) =>
      db.upsertSource(SourcesCompanion(
        id: Value(id),
        kind: Value(kind),
        label: Value(label),
      ));

  test('build restores the persisted last-active source', () async {
    // 'a-local' sorts before 'b-komga'; without persistence the lexical pick
    // would land on the local source (the original regression).
    await addSource('a-local', 'local', 'Local files');
    await addSource('b-komga', 'komga', 'Komga');
    await db.updateLastActiveSourceId('b-komga');

    final c = container();
    addTearDown(c.dispose);
    expect(await c.read(activeSourceIdProvider.future), 'b-komga');
  });

  test('build falls back to the lowest-sorted id when nothing was persisted',
      () async {
    await addSource('b-komga', 'komga', 'Komga');
    await addSource('a-local', 'local', 'Local files');

    final c = container();
    addTearDown(c.dispose);
    expect(await c.read(activeSourceIdProvider.future), 'a-local');
  });

  test('build falls back when the remembered source was deleted', () async {
    await addSource('a-local', 'local', 'Local files');
    await db.updateLastActiveSourceId('deleted-source');

    final c = container();
    addTearDown(c.dispose);
    expect(await c.read(activeSourceIdProvider.future), 'a-local');
  });

  test('select switches immediately and persists across a restart', () async {
    await addSource('a-local', 'local', 'Local files');
    await addSource('b-komga', 'komga', 'Komga');

    final first = container();
    addTearDown(first.dispose);
    expect(await first.read(activeSourceIdProvider.future), 'a-local');

    first.read(activeSourceIdProvider.notifier).select('b-komga');
    expect(await first.read(activeSourceIdProvider.future), 'b-komga');

    // The persistence write is fire-and-forget; wait for it to land.
    await pumpEventQueue();
    expect((await db.getOrCreateSettings()).lastActiveSourceId, 'b-komga');

    // A fresh container on the same database (an app restart) restores it.
    final second = container();
    addTearDown(second.dispose);
    expect(await second.read(activeSourceIdProvider.future), 'b-komga');
  });
}
