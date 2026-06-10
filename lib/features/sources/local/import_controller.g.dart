// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$importControllerHash() => r'6f08e9828515ed8efc00e77cf3923efd4a43a1f9';

/// Drives a pick-then-import run. The picker's extension filter is UX-only
/// (magic-byte sniffing decides for real, per the imports rule); per-file
/// progress comes from importing one file at a time.
///
/// Copied from [ImportController].
@ProviderFor(ImportController)
final importControllerProvider =
    AutoDisposeNotifierProvider<ImportController, ImportRunState>.internal(
      ImportController.new,
      name: r'importControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$importControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ImportController = AutoDisposeNotifier<ImportRunState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
