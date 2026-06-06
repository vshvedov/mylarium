// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$deviceIdHash() => r'bca90a5b93d6ac7411075a99c80625a28a1ebb21';

/// The stable per-install device id, generated once on first settings read.
/// Stamped on local reading sessions (forward-compat for phase-2 dedup).
///
/// Copied from [deviceId].
@ProviderFor(deviceId)
final deviceIdProvider = FutureProvider<String>.internal(
  deviceId,
  name: r'deviceIdProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$deviceIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DeviceIdRef = FutureProviderRef<String>;
String _$syncEngineHash() => r'a271cdac5b4f91b13f9c9ede360b39fab5b799d4';

/// The app-wide sync engine. keepAlive so the write-back queue and reconcile
/// outlive any reader screen. The content client is resolved lazily per call
/// (through [contentApiForProvider]), so mid-session re-auth or source deletion
/// is honored at flush/reconcile time.
///
/// Copied from [syncEngine].
@ProviderFor(syncEngine)
final syncEngineProvider = FutureProvider<SyncEngine>.internal(
  syncEngine,
  name: r'syncEngineProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$syncEngineHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SyncEngineRef = FutureProviderRef<SyncEngine>;
String _$statsRepositoryHash() => r'0e4f8899e330e9063c7d6c8a51dcfab69ac4fd31';

/// Reads-only roll-up over the reading-sessions log for the stats screen.
///
/// Copied from [statsRepository].
@ProviderFor(statsRepository)
final statsRepositoryProvider = AutoDisposeProvider<StatsRepository>.internal(
  statsRepository,
  name: r'statsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$statsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StatsRepositoryRef = AutoDisposeProviderRef<StatsRepository>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
