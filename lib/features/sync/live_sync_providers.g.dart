// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_sync_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$liveSyncHash() => r'30b2d93e2790488d61e3cf6749426a8ee1d85646';

/// Owns the app's live-event subscription (T1). `state` is the session-expired
/// flag: false while healthy, true once the server session expires, so the UI
/// can show a non-blocking re-auth affordance. The actual reconnect/backoff and
/// event routing live in [LiveSyncController]; this provider binds it to the
/// active source, routes read-progress through the reconciler, invalidates the
/// API-backed home rails on change, and is driven by the app lifecycle (started
/// on foreground, stopped on background) from the root observer.
///
/// Copied from [LiveSync].
@ProviderFor(LiveSync)
final liveSyncProvider = NotifierProvider<LiveSync, bool>.internal(
  LiveSync.new,
  name: r'liveSyncProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$liveSyncHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LiveSync = Notifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
