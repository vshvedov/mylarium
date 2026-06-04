// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_quality.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$imageQualityControllerHash() =>
    r'e5f832cb1a36f4fc642965b888e306a6db3f44ce';

/// Holds the global image-quality preference, seeded from the boot settings and
/// written back to `app_settings`. The reader watches this to size its decodes.
///
/// Copied from [ImageQualityController].
@ProviderFor(ImageQualityController)
final imageQualityControllerProvider =
    AutoDisposeNotifierProvider<ImageQualityController, ImageQuality>.internal(
      ImageQualityController.new,
      name: r'imageQualityControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$imageQualityControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ImageQualityController = AutoDisposeNotifier<ImageQuality>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
