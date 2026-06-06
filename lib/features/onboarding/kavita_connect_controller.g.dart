// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kavita_connect_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$kavitaConnectControllerHash() =>
    r'a0d775a444b22a96623862d58e436a097501329f';

/// Drives the Kavita connect screen. State is the latest [ConnectionResult]
/// (null before the first attempt); [AsyncLoading] while a connection is in
/// flight. Mirrors [OnboardingController] but for the Kavita API-key flow.
///
/// Copied from [KavitaConnectController].
@ProviderFor(KavitaConnectController)
final kavitaConnectControllerProvider =
    AutoDisposeNotifierProvider<
      KavitaConnectController,
      AsyncValue<ConnectionResult?>
    >.internal(
      KavitaConnectController.new,
      name: r'kavitaConnectControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$kavitaConnectControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$KavitaConnectController =
    AutoDisposeNotifier<AsyncValue<ConnectionResult?>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
