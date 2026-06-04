import 'package:drift/drift.dart' show Value;
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:local_auth/local_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/theme/theme_controller.dart' show appDatabaseProvider;
import '../../data/source/source_providers.dart';
import '../db/database.dart';

part 'app_lock.g.dart';

/// Seam over the platform biometric/PIN prompt so [AppLock] is testable. The
/// real implementation falls back to the device passcode/PIN when biometrics
/// are unavailable (`biometricOnly: false`), satisfying the PRD's "PIN/biometric"
/// requirement.
abstract class Authenticator {
  Future<bool> authenticate(String reason);
}

class LocalAuthenticator implements Authenticator {
  const LocalAuthenticator();

  @override
  Future<bool> authenticate(String reason) async {
    final auth = LocalAuthentication();
    try {
      return await auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
    } on PlatformException {
      // No hardware, not enrolled, lockout, or user cancel -> treat as failure.
      return false;
    }
  }
}

@Riverpod(keepAlive: true)
Authenticator authenticator(Ref ref) => const LocalAuthenticator();

/// Immutable lock state for the active source's libraries. [unlocked] is the set
/// of libraries unlocked this session (in-memory; cleared on restart).
class AppLockState {
  const AppLockState({
    required this.locked,
    required this.showRestricted,
    required this.unlocked,
  });

  /// libraryId -> locked.
  final Map<String, bool> locked;

  /// libraryId -> show-restricted.
  final Map<String, bool> showRestricted;

  /// libraryIds unlocked this session.
  final Set<String> unlocked;

  static const empty =
      AppLockState(locked: {}, showRestricted: {}, unlocked: {});

  bool isLocked(String libraryId) =>
      (locked[libraryId] ?? false) && !unlocked.contains(libraryId);

  bool isUnlocked(String libraryId) =>
      !(locked[libraryId] ?? false) || unlocked.contains(libraryId);

  /// Restricted series are visible only while the library is unlocked AND
  /// show-restricted is enabled for it.
  bool restrictedVisible(String libraryId) =>
      isUnlocked(libraryId) && (showRestricted[libraryId] ?? false);

  AppLockState copyWith({Set<String>? unlocked}) => AppLockState(
        locked: locked,
        showRestricted: showRestricted,
        unlocked: unlocked ?? this.unlocked,
      );
}

/// Tracks per-library lock/show-restricted config (persisted) plus the set of
/// libraries unlocked this session (in-memory). Operates on the active source.
@Riverpod(keepAlive: true)
class AppLock extends _$AppLock {
  final Set<String> _unlocked = {};

  @override
  Future<AppLockState> build() async {
    final sourceId = await ref.watch(activeSourceIdProvider.future);
    if (sourceId == null) return AppLockState.empty;
    final prefs = await ref.watch(appDatabaseProvider).allLibraryPrefs(sourceId);
    return AppLockState(
      locked: {for (final p in prefs) p.libraryId: p.locked},
      showRestricted: {for (final p in prefs) p.libraryId: p.showRestricted},
      unlocked: _unlocked.toSet(),
    );
  }

  /// Prompts for biometric/PIN; on success marks [libraryId] unlocked for this
  /// session and returns true. Any failure/cancel returns false.
  Future<bool> unlock(String libraryId) async {
    final ok = await ref
        .read(authenticatorProvider)
        .authenticate('Unlock this library');
    if (!ok) return false;
    _unlocked.add(libraryId);
    final current = state.valueOrNull ?? AppLockState.empty;
    state = AsyncData(current.copyWith(unlocked: _unlocked.toSet()));
    return true;
  }

  Future<void> setLocked(String libraryId, bool locked) async {
    final sourceId = await ref.read(activeSourceIdProvider.future);
    if (sourceId == null) return;
    final existing =
        await ref.read(appDatabaseProvider).getLibraryPref(sourceId, libraryId);
    await ref.read(appDatabaseProvider).upsertLibraryPref(LibraryPrefsCompanion(
          sourceId: Value(sourceId),
          libraryId: Value(libraryId),
          locked: Value(locked),
          showRestricted: Value(existing?.showRestricted ?? false),
        ));
    if (!locked) _unlocked.remove(libraryId);
    ref.invalidateSelf();
  }

  Future<void> setShowRestricted(String libraryId, bool show) async {
    final sourceId = await ref.read(activeSourceIdProvider.future);
    if (sourceId == null) return;
    final existing =
        await ref.read(appDatabaseProvider).getLibraryPref(sourceId, libraryId);
    await ref.read(appDatabaseProvider).upsertLibraryPref(LibraryPrefsCompanion(
          sourceId: Value(sourceId),
          libraryId: Value(libraryId),
          locked: Value(existing?.locked ?? false),
          showRestricted: Value(show),
        ));
    ref.invalidateSelf();
  }
}
