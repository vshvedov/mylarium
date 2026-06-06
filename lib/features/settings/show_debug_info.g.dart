// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'show_debug_info.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$showDebugInfoHash() => r'f74de5ac71ea9de6fcc953d25dab607fc2a82e60';

/// The "Show debug info" preference (persisted in the diagnostics store, not the
/// content database). When on, the reader and settings surface diagnostics such
/// as the probed GPU max texture size.
///
/// Copied from [ShowDebugInfo].
@ProviderFor(ShowDebugInfo)
final showDebugInfoProvider = NotifierProvider<ShowDebugInfo, bool>.internal(
  ShowDebugInfo.new,
  name: r'showDebugInfoProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$showDebugInfoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ShowDebugInfo = Notifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
