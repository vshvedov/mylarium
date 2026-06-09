// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appDatabaseHash() => r'cd89999af5b121916081f287b7704a6b0efc252b';

/// Injected in main() via overrideWithValue; throws until overridden so a
/// missing override fails loudly instead of silently.
///
/// Copied from [appDatabase].
@ProviderFor(appDatabase)
final appDatabaseProvider = Provider<AppDatabase>.internal(
  appDatabase,
  name: r'appDatabaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appDatabaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppDatabaseRef = ProviderRef<AppDatabase>;
String _$initialSettingsHash() => r'403eed1f91023f7468178bf8d8121be0ae1a7409';

/// The settings row read once at boot and injected; the controllers seed from
/// it. Written values flow back through the controller setters.
///
/// Copied from [initialSettings].
@ProviderFor(initialSettings)
final initialSettingsProvider = Provider<AppSetting>.internal(
  initialSettings,
  name: r'initialSettingsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$initialSettingsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef InitialSettingsRef = ProviderRef<AppSetting>;
String _$ephemeralStorageHash() => r'a4c74d8358564f5d19d0d749999a02fdb83375e3';

/// True when the on-disk database could not be opened at boot and main() fell
/// back to an in-memory database. In that state nothing the user connects or
/// reads survives a restart, which previously looked like an endless
/// re-onboarding loop (see the schemaVersion-downgrade bug). Surfaced
/// non-blocking (a banner / settings row) so a genuinely broken-storage device
/// is distinguishable from a fresh first run, with no telemetry. Defaults to
/// false (healthy); main() overrides it with the real outcome.
///
/// Copied from [ephemeralStorage].
@ProviderFor(ephemeralStorage)
final ephemeralStorageProvider = Provider<bool>.internal(
  ephemeralStorage,
  name: r'ephemeralStorageProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$ephemeralStorageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EphemeralStorageRef = ProviderRef<bool>;
String _$themeControllerHash() => r'c43afb5ccd2c8d60f2e4fbaeeb141854b7f343ed';

/// See also [ThemeController].
@ProviderFor(ThemeController)
final themeControllerProvider =
    AutoDisposeNotifierProvider<ThemeController, AppThemeMode>.internal(
      ThemeController.new,
      name: r'themeControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$themeControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ThemeController = AutoDisposeNotifier<AppThemeMode>;
String _$reduceMotionHash() => r'720a632e7b2d5c4899bfaa066fc0cd1580f23dd9';

/// See also [ReduceMotion].
@ProviderFor(ReduceMotion)
final reduceMotionProvider =
    AutoDisposeNotifierProvider<ReduceMotion, bool>.internal(
      ReduceMotion.new,
      name: r'reduceMotionProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$reduceMotionHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ReduceMotion = AutoDisposeNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
