// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

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
