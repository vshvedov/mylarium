// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appVersionLabelHash() => r'1a82fa8c2dfae4510c133d26fc4e26017a9ec2e8';

/// Human-readable app version, e.g. "1.0.7 (8)". Read from the installed
/// bundle (Info.plist / AndroidManifest), so it reflects the actual build.
///
/// Copied from [appVersionLabel].
@ProviderFor(appVersionLabel)
final appVersionLabelProvider = AutoDisposeFutureProvider<String>.internal(
  appVersionLabel,
  name: r'appVersionLabelProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appVersionLabelHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppVersionLabelRef = AutoDisposeFutureProviderRef<String>;
String _$autoAdvanceEnabledHash() =>
    r'8dce78018dde06b5b564ab037f9a0f6b593910eb';

/// Whether reaching the last page auto-loads the next book in the series (T2).
/// Global, reactive: the reader reads it to decide whether to count down at the
/// end-of-book seam, and the settings screen toggles it.
///
/// Copied from [autoAdvanceEnabled].
@ProviderFor(autoAdvanceEnabled)
final autoAdvanceEnabledProvider = AutoDisposeStreamProvider<bool>.internal(
  autoAdvanceEnabled,
  name: r'autoAdvanceEnabledProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$autoAdvanceEnabledHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AutoAdvanceEnabledRef = AutoDisposeStreamProviderRef<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
