// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kavita_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$kavitaCredentialStoreHash() =>
    r'0bb616498b2008be95b9b5759b6e82a69decc174';

/// Kavita credential store layered over the shared secure store.
///
/// Copied from [kavitaCredentialStore].
@ProviderFor(kavitaCredentialStore)
final kavitaCredentialStoreProvider = Provider<KavitaCredentialStore>.internal(
  kavitaCredentialStore,
  name: r'kavitaCredentialStoreProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$kavitaCredentialStoreHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef KavitaCredentialStoreRef = ProviderRef<KavitaCredentialStore>;
String _$kavitaApiFactoryHash() => r'ddbd42a0ce1053b478a5f4a7c127898614c31cd2';

/// See also [kavitaApiFactory].
@ProviderFor(kavitaApiFactory)
final kavitaApiFactoryProvider = AutoDisposeProvider<KavitaApiFactory>.internal(
  kavitaApiFactory,
  name: r'kavitaApiFactoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$kavitaApiFactoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef KavitaApiFactoryRef = AutoDisposeProviderRef<KavitaApiFactory>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
