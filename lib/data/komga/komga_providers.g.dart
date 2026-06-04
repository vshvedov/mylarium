// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'komga_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$secureStoreHash() => r'4152faa8e5b4f3e77b4fbdc5fc1bb48f80b1a2d0';

/// Platform secret store. Overridable in tests with a fake.
///
/// Copied from [secureStore].
@ProviderFor(secureStore)
final secureStoreProvider = Provider<SecureStore>.internal(
  secureStore,
  name: r'secureStoreProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$secureStoreHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SecureStoreRef = ProviderRef<SecureStore>;
String _$komgaCredentialStoreHash() =>
    r'0c97304d9cac715c42c13889aadb30eadc316822';

/// Komga credential store layered over [secureStore].
///
/// Copied from [komgaCredentialStore].
@ProviderFor(komgaCredentialStore)
final komgaCredentialStoreProvider = Provider<KomgaCredentialStore>.internal(
  komgaCredentialStore,
  name: r'komgaCredentialStoreProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$komgaCredentialStoreHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef KomgaCredentialStoreRef = ProviderRef<KomgaCredentialStore>;
String _$komgaApiFactoryHash() => r'3e650475ec9202945a797f89e800186710006d74';

/// See also [komgaApiFactory].
@ProviderFor(komgaApiFactory)
final komgaApiFactoryProvider = AutoDisposeProvider<KomgaApiFactory>.internal(
  komgaApiFactory,
  name: r'komgaApiFactoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$komgaApiFactoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef KomgaApiFactoryRef = AutoDisposeProviderRef<KomgaApiFactory>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
