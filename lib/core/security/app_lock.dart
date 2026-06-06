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

/// Immutable lock state for the active source's libraries. A locked library's
/// entire content is hidden everywhere until it is unlocked (PIN/biometric).
/// Unlocking persists (it clears the lock flag) until the library is locked
/// again, so the state is simply the per-library [locked] map.
class AppLockState {
  const AppLockState({required this.locked});

  /// libraryId -> locked.
  final Map<String, bool> locked;

  static const empty = AppLockState(locked: {});

  /// Whether the library's content must be hidden. A null/unknown libraryId is
  /// treated as not locked.
  bool isLocked(String? libraryId) =>
      libraryId != null && (locked[libraryId] ?? false);

  bool isUnlocked(String? libraryId) => !isLocked(libraryId);

  /// The set of currently-hidden (locked) library ids, for SQL exclusion.
  Set<String> get hiddenLibraryIds =>
      {for (final e in locked.entries) if (e.value) e.key};
}

/// Tracks the per-library lock flag (persisted) for the active source. Locking
/// hides a library's content everywhere; unlocking requires biometric/PIN and
/// reveals it until it is locked again.
@Riverpod(keepAlive: true)
class AppLock extends _$AppLock {
  @override
  Future<AppLockState> build() async {
    final sourceId = await ref.watch(activeSourceIdProvider.future);
    if (sourceId == null) return AppLockState.empty;
    final prefs = await ref.watch(appDatabaseProvider).allLibraryPrefs(sourceId);
    return AppLockState(locked: {for (final p in prefs) p.libraryId: p.locked});
  }

  /// Locks [libraryId] (hides its content everywhere). No auth required: hiding
  /// your own content is unprivileged.
  Future<void> lock(String libraryId) => _setLocked(libraryId, true);

  /// Prompts for biometric/PIN; on success unlocks [libraryId] (persistently,
  /// until it is locked again) and returns true. Any failure/cancel returns
  /// false and leaves it locked. [libraryName] is shown in the prompt reason.
  Future<bool> unlock(String libraryId, {String? libraryName}) async {
    final reason = libraryName != null && libraryName.isNotEmpty
        ? 'Unlock "$libraryName"'
        : 'Unlock this library';
    final ok = await ref.read(authenticatorProvider).authenticate(reason);
    if (!ok) return false;
    await _setLocked(libraryId, false);
    return true;
  }

  Future<void> _setLocked(String libraryId, bool locked) async {
    final sourceId = await ref.read(activeSourceIdProvider.future);
    if (sourceId == null) return;
    // Only the lock flag is written; the legacy show-restricted column is left
    // untouched (omitted from the companion, so a conflict-update preserves it).
    await ref.read(appDatabaseProvider).upsertLibraryPref(LibraryPrefsCompanion(
          sourceId: Value(sourceId),
          libraryId: Value(libraryId),
          locked: Value(locked),
        ));
    ref.invalidateSelf();
  }
}
