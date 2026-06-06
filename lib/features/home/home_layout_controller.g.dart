// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_layout_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$visibleHomeRailsHash() => r'997a77a6acf04ab944d4eafdd6979787b62123f4';

/// The rows that are currently visible, in order (drives the home rails).
///
/// Copied from [visibleHomeRails].
@ProviderFor(visibleHomeRails)
final visibleHomeRailsProvider =
    AutoDisposeProvider<List<HomeRailKind>>.internal(
      visibleHomeRails,
      name: r'visibleHomeRailsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$visibleHomeRailsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef VisibleHomeRailsRef = AutoDisposeProviderRef<List<HomeRailKind>>;
String _$homeLayoutControllerHash() =>
    r'05d9995a5b4e35fac8e777ff7d6872c750f20eed';

/// The persisted home-screen row layout (order + per-row visibility). Seeded from
/// the boot settings row and written through to the DB on every edit, so changes
/// are immediate (the home watches this) and survive restarts. Mirrors
/// [ThemeController]: read initial -> hold state -> setters persist + update.
///
/// Copied from [HomeLayoutController].
@ProviderFor(HomeLayoutController)
final homeLayoutControllerProvider =
    AutoDisposeNotifierProvider<
      HomeLayoutController,
      List<HomeRailItem>
    >.internal(
      HomeLayoutController.new,
      name: r'homeLayoutControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$homeLayoutControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$HomeLayoutController = AutoDisposeNotifier<List<HomeRailItem>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
