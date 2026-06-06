// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_tier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$deviceTierHash() => r'a06c4083b84a34cc34f0969bda1299dccf99a59f';

/// The resolved device tier for this launch. Computed once from
/// `Platform.numberOfProcessors` and the implicit view's physical size, with a
/// safe fallback to normal when those signals are unavailable (for example on
/// web, where `dart:io Platform` is not used here).
///
/// Copied from [deviceTier].
@ProviderFor(deviceTier)
final deviceTierProvider = Provider<DeviceTier>.internal(
  deviceTier,
  name: r'deviceTierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$deviceTierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DeviceTierRef = ProviderRef<DeviceTier>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
