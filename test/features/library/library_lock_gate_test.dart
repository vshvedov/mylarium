import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/theme/app_theme.dart';
import 'package:mylarium/app/theme/theme_controller.dart';
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/core/security/app_lock.dart';
import 'package:mylarium/core/storage/secure_store.dart';
import 'package:mylarium/data/komga/komga_providers.dart';
import 'package:mylarium/features/library/libraries_screen.dart';

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

class _InMemorySecureStore extends SecureStore {
  final Map<String, String> _v = {};
  @override
  Future<void> write(String key, String value) async => _v[key] = value;
  @override
  Future<String?> read(String key) async => _v[key];
  @override
  Future<void> delete(String key) async => _v.remove(key);
}

void main() {
  testWidgets('a locked library shows the unlock gate and clears on success',
      (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.upsertSource(const SourcesCompanion(
        id: Value('s1'), kind: Value('komga'), label: Value('T')));
    await db.upsertLibrary(const LibrariesCompanion(
        sourceId: Value('s1'), id: Value('lib1'), name: Value('Locked Lib')));
    await db.upsertLibraryPref(const LibraryPrefsCompanion(
        sourceId: Value('s1'), libraryId: Value('lib1'), locked: Value(true)));

    final auth = _FakeAuthenticator(true);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        authenticatorProvider.overrideWithValue(auth),
        secureStoreProvider.overrideWithValue(_InMemorySecureStore()),
      ],
      child: MaterialApp(
        theme: lightTheme,
        home: const LibraryGridScreen(sourceId: 's1', libraryId: 'lib1'),
      ),
    ));
    await tester.pump();
    await tester.pump();

    // The lock gate is shown (not the grid).
    expect(find.widgetWithText(FilledButton, 'Unlock'), findsOneWidget);

    // Unlocking authenticates and clears the gate.
    await tester.tap(find.widgetWithText(FilledButton, 'Unlock'));
    await tester.pump();
    await tester.pump();
    expect(auth.calls, 1);
    expect(find.widgetWithText(FilledButton, 'Unlock'), findsNothing);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });

  testWidgets('a failed unlock keeps the gate', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.upsertSource(const SourcesCompanion(
        id: Value('s1'), kind: Value('komga'), label: Value('T')));
    await db.upsertLibrary(const LibrariesCompanion(
        sourceId: Value('s1'), id: Value('lib1'), name: Value('Locked Lib')));
    await db.upsertLibraryPref(const LibraryPrefsCompanion(
        sourceId: Value('s1'), libraryId: Value('lib1'), locked: Value(true)));

    final auth = _FakeAuthenticator(false);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        authenticatorProvider.overrideWithValue(auth),
        secureStoreProvider.overrideWithValue(_InMemorySecureStore()),
      ],
      child: MaterialApp(
        theme: lightTheme,
        home: const LibraryGridScreen(sourceId: 's1', libraryId: 'lib1'),
      ),
    ));
    await tester.pump();
    await tester.pump();

    await tester.tap(find.widgetWithText(FilledButton, 'Unlock'));
    await tester.pump();
    await tester.pump();
    expect(auth.calls, 1);
    // Still locked.
    expect(find.widgetWithText(FilledButton, 'Unlock'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
}
