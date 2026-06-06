import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/theme/theme_controller.dart';
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/core/security/app_lock.dart';

class _FakeAuthenticator implements Authenticator {
  _FakeAuthenticator(this.result);
  bool result;
  int calls = 0;

  @override
  Future<bool> authenticate(String reason) async {
    calls++;
    return result;
  }
}

void main() {
  late AppDatabase db;
  late _FakeAuthenticator auth;
  late ProviderContainer container;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.upsertSource(const SourcesCompanion(
      id: Value('s1'),
      kind: Value('komga'),
      label: Value('Test'),
    ));
    auth = _FakeAuthenticator(true);
    container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
      authenticatorProvider.overrideWithValue(auth),
    ]);
  });
  tearDown(() {
    container.dispose();
    db.close();
  });

  test('lock hides without auth; unlock requires auth and persists', () async {
    final notifier = container.read(appLockProvider.notifier);

    // No prefs yet: nothing locked.
    var state = await container.read(appLockProvider.future);
    expect(state.isLocked('lib1'), isFalse);

    // Locking needs no auth.
    await notifier.lock('lib1');
    expect(auth.calls, 0);
    state = await container.read(appLockProvider.future);
    expect(state.isLocked('lib1'), isTrue);
    expect(state.hiddenLibraryIds, {'lib1'});

    // Failed auth keeps it locked.
    auth.result = false;
    expect(await notifier.unlock('lib1'), isFalse);
    state = await container.read(appLockProvider.future);
    expect(state.isLocked('lib1'), isTrue);

    // Successful auth unlocks it persistently (the lock flag is cleared).
    auth.result = true;
    expect(await notifier.unlock('lib1'), isTrue);
    expect(auth.calls, 2);
    state = await container.read(appLockProvider.future);
    expect(state.isLocked('lib1'), isFalse);
    expect(state.isUnlocked('lib1'), isTrue);

    // Persisted: a fresh state (re-read prefs) still sees it unlocked.
    final pref = await db.getLibraryPref('s1', 'lib1');
    expect(pref!.locked, isFalse);
  });

  test('a null/unknown library id is never locked', () async {
    final state = await container.read(appLockProvider.future);
    expect(state.isLocked(null), isFalse);
    expect(state.isLocked('nope'), isFalse);
  });
}
