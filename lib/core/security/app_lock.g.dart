// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_lock.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authenticatorHash() => r'1c6c9e50809644d2f0cf98a2f92270dee79707f3';

/// See also [authenticator].
@ProviderFor(authenticator)
final authenticatorProvider = Provider<Authenticator>.internal(
  authenticator,
  name: r'authenticatorProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authenticatorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthenticatorRef = ProviderRef<Authenticator>;
String _$appLockHash() => r'3e17257a8b5ab3fcc5de8fbfb0f469505ca89ef0';

/// Tracks the per-library lock flag (persisted) for the active source. Locking
/// hides a library's content everywhere; unlocking requires biometric/PIN and
/// reveals it until it is locked again.
///
/// Copied from [AppLock].
@ProviderFor(AppLock)
final appLockProvider = AsyncNotifierProvider<AppLock, AppLockState>.internal(
  AppLock.new,
  name: r'appLockProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appLockHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AppLock = AsyncNotifier<AppLockState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
