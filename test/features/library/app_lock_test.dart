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

  test('isLocked reflects LibraryPrefs; unlock requires auth and clears lock',
      () async {
    final notifier = container.read(appLockProvider.notifier);

    // No prefs yet: nothing locked.
    var state = await container.read(appLockProvider.future);
    expect(state.isLocked('lib1'), isFalse);

    // Lock lib1.
    await notifier.setLocked('lib1', true);
    state = await container.read(appLockProvider.future);
    expect(state.isLocked('lib1'), isTrue);
    expect(state.restrictedVisible('lib1'), isFalse);

    // Failed auth keeps it locked.
    auth.result = false;
    expect(await notifier.unlock('lib1'), isFalse);
    state = await container.read(appLockProvider.future);
    expect(state.isLocked('lib1'), isTrue);

    // Successful auth unlocks for the session.
    auth.result = true;
    expect(await notifier.unlock('lib1'), isTrue);
    expect(auth.calls, 2);
    state = container.read(appLockProvider).requireValue;
    expect(state.isLocked('lib1'), isFalse);
    expect(state.isUnlocked('lib1'), isTrue);
  });

  test('restrictedVisible requires unlocked AND showRestricted', () async {
    final notifier = container.read(appLockProvider.notifier);
    await notifier.setLocked('lib1', true);
    await notifier.setShowRestricted('lib1', true);

    // Locked -> restricted not visible even though showRestricted is on.
    var state = await container.read(appLockProvider.future);
    expect(state.restrictedVisible('lib1'), isFalse);

    // Unlock -> now visible.
    await notifier.unlock('lib1');
    state = container.read(appLockProvider).requireValue;
    expect(state.restrictedVisible('lib1'), isTrue);
  });
}
