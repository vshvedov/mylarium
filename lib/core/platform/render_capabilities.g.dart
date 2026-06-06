// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'render_capabilities.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$renderCapabilitiesHash() =>
    r'a6cfd2ef302282a850266317961fa104e802a7f5';

/// The device's GPU max texture size. Bootstrapped to the safe fallback, then
/// refined from the per-device cache (fast) or a one-time native probe (cached
/// so later launches skip it). The reader watches this so the focused page
/// re-decodes sharper once the real value is known.
///
/// Copied from [RenderCapabilities].
@ProviderFor(RenderCapabilities)
final renderCapabilitiesProvider =
    NotifierProvider<RenderCapabilities, int>.internal(
      RenderCapabilities.new,
      name: r'renderCapabilitiesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$renderCapabilitiesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$RenderCapabilities = Notifier<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
