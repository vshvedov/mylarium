// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'folder_source_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$removableVolumesHash() => r'84d95653c23f93662821b33c0c0f436581e0ae3e';

/// Mounted removable volumes (SD cards), for the dedicated "use SD card"
/// shortcut. Android-only by nature; empty elsewhere. Probed once per app run
/// (mount changes are picked up on the next launch or sheet reopen via
/// [ref.invalidate]).
///
/// Copied from [removableVolumes].
@ProviderFor(removableVolumes)
final removableVolumesProvider =
    AutoDisposeFutureProvider<List<RemovableVolume>>.internal(
      removableVolumes,
      name: r'removableVolumesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$removableVolumesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RemovableVolumesRef =
    AutoDisposeFutureProviderRef<List<RemovableVolume>>;
String _$treeFsHash() => r'8dc5ad71a6958bb286025d71dcb94c5f21bf12d5';

/// The production tree filesystem (Android SAF).
///
/// Copied from [treeFs].
@ProviderFor(treeFs)
final treeFsProvider = AutoDisposeProvider<TreeFs>.internal(
  treeFs,
  name: r'treeFsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$treeFsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TreeFsRef = AutoDisposeProviderRef<TreeFs>;
String _$treeScannerHash() => r'188e255db9cf8ba392f82287bb416796c1900c46';

/// See also [treeScanner].
@ProviderFor(treeScanner)
final treeScannerProvider = AutoDisposeProvider<TreeScanner>.internal(
  treeScanner,
  name: r'treeScannerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$treeScannerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TreeScannerRef = AutoDisposeProviderRef<TreeScanner>;
String _$treeSourceOnlineHash() => r'9b2046742cc0949154b1827e12262723665655c0';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Whether a folder source's tree root is currently reachable (card mounted,
/// permission intact). Drives the non-blocking offline banner; manual refresh
/// via [ref.invalidate] (first cut: no live mount watching).
///
/// Copied from [treeSourceOnline].
@ProviderFor(treeSourceOnline)
const treeSourceOnlineProvider = TreeSourceOnlineFamily();

/// Whether a folder source's tree root is currently reachable (card mounted,
/// permission intact). Drives the non-blocking offline banner; manual refresh
/// via [ref.invalidate] (first cut: no live mount watching).
///
/// Copied from [treeSourceOnline].
class TreeSourceOnlineFamily extends Family<AsyncValue<bool>> {
  /// Whether a folder source's tree root is currently reachable (card mounted,
  /// permission intact). Drives the non-blocking offline banner; manual refresh
  /// via [ref.invalidate] (first cut: no live mount watching).
  ///
  /// Copied from [treeSourceOnline].
  const TreeSourceOnlineFamily();

  /// Whether a folder source's tree root is currently reachable (card mounted,
  /// permission intact). Drives the non-blocking offline banner; manual refresh
  /// via [ref.invalidate] (first cut: no live mount watching).
  ///
  /// Copied from [treeSourceOnline].
  TreeSourceOnlineProvider call(String sourceId) {
    return TreeSourceOnlineProvider(sourceId);
  }

  @override
  TreeSourceOnlineProvider getProviderOverride(
    covariant TreeSourceOnlineProvider provider,
  ) {
    return call(provider.sourceId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'treeSourceOnlineProvider';
}

/// Whether a folder source's tree root is currently reachable (card mounted,
/// permission intact). Drives the non-blocking offline banner; manual refresh
/// via [ref.invalidate] (first cut: no live mount watching).
///
/// Copied from [treeSourceOnline].
class TreeSourceOnlineProvider extends AutoDisposeFutureProvider<bool> {
  /// Whether a folder source's tree root is currently reachable (card mounted,
  /// permission intact). Drives the non-blocking offline banner; manual refresh
  /// via [ref.invalidate] (first cut: no live mount watching).
  ///
  /// Copied from [treeSourceOnline].
  TreeSourceOnlineProvider(String sourceId)
    : this._internal(
        (ref) => treeSourceOnline(ref as TreeSourceOnlineRef, sourceId),
        from: treeSourceOnlineProvider,
        name: r'treeSourceOnlineProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$treeSourceOnlineHash,
        dependencies: TreeSourceOnlineFamily._dependencies,
        allTransitiveDependencies:
            TreeSourceOnlineFamily._allTransitiveDependencies,
        sourceId: sourceId,
      );

  TreeSourceOnlineProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.sourceId,
  }) : super.internal();

  final String sourceId;

  @override
  Override overrideWith(
    FutureOr<bool> Function(TreeSourceOnlineRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TreeSourceOnlineProvider._internal(
        (ref) => create(ref as TreeSourceOnlineRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        sourceId: sourceId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<bool> createElement() {
    return _TreeSourceOnlineProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TreeSourceOnlineProvider && other.sourceId == sourceId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, sourceId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TreeSourceOnlineRef on AutoDisposeFutureProviderRef<bool> {
  /// The parameter `sourceId` of this provider.
  String get sourceId;
}

class _TreeSourceOnlineProviderElement
    extends AutoDisposeFutureProviderElement<bool>
    with TreeSourceOnlineRef {
  _TreeSourceOnlineProviderElement(super.provider);

  @override
  String get sourceId => (origin as TreeSourceOnlineProvider).sourceId;
}

String _$folderSourceServiceHash() =>
    r'1e87e6f922dbf782e1ad47e379221afc73537adf';

/// See also [folderSourceService].
@ProviderFor(folderSourceService)
final folderSourceServiceProvider =
    AutoDisposeProvider<FolderSourceService>.internal(
      folderSourceService,
      name: r'folderSourceServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$folderSourceServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FolderSourceServiceRef = AutoDisposeProviderRef<FolderSourceService>;
String _$folderScanControllerHash() =>
    r'e44f34f9db2ccc133fd9200395dd041430c1ea42';

abstract class _$FolderScanController
    extends BuildlessNotifier<FolderScanState> {
  late final String sourceId;

  FolderScanState build(String sourceId);
}

/// Drives scanning/rescanning one folder source. keepAlive so a scan survives
/// navigating away from the home surface; per-source family.
///
/// Copied from [FolderScanController].
@ProviderFor(FolderScanController)
const folderScanControllerProvider = FolderScanControllerFamily();

/// Drives scanning/rescanning one folder source. keepAlive so a scan survives
/// navigating away from the home surface; per-source family.
///
/// Copied from [FolderScanController].
class FolderScanControllerFamily extends Family<FolderScanState> {
  /// Drives scanning/rescanning one folder source. keepAlive so a scan survives
  /// navigating away from the home surface; per-source family.
  ///
  /// Copied from [FolderScanController].
  const FolderScanControllerFamily();

  /// Drives scanning/rescanning one folder source. keepAlive so a scan survives
  /// navigating away from the home surface; per-source family.
  ///
  /// Copied from [FolderScanController].
  FolderScanControllerProvider call(String sourceId) {
    return FolderScanControllerProvider(sourceId);
  }

  @override
  FolderScanControllerProvider getProviderOverride(
    covariant FolderScanControllerProvider provider,
  ) {
    return call(provider.sourceId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'folderScanControllerProvider';
}

/// Drives scanning/rescanning one folder source. keepAlive so a scan survives
/// navigating away from the home surface; per-source family.
///
/// Copied from [FolderScanController].
class FolderScanControllerProvider
    extends NotifierProviderImpl<FolderScanController, FolderScanState> {
  /// Drives scanning/rescanning one folder source. keepAlive so a scan survives
  /// navigating away from the home surface; per-source family.
  ///
  /// Copied from [FolderScanController].
  FolderScanControllerProvider(String sourceId)
    : this._internal(
        () => FolderScanController()..sourceId = sourceId,
        from: folderScanControllerProvider,
        name: r'folderScanControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$folderScanControllerHash,
        dependencies: FolderScanControllerFamily._dependencies,
        allTransitiveDependencies:
            FolderScanControllerFamily._allTransitiveDependencies,
        sourceId: sourceId,
      );

  FolderScanControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.sourceId,
  }) : super.internal();

  final String sourceId;

  @override
  FolderScanState runNotifierBuild(covariant FolderScanController notifier) {
    return notifier.build(sourceId);
  }

  @override
  Override overrideWith(FolderScanController Function() create) {
    return ProviderOverride(
      origin: this,
      override: FolderScanControllerProvider._internal(
        () => create()..sourceId = sourceId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        sourceId: sourceId,
      ),
    );
  }

  @override
  NotifierProviderElement<FolderScanController, FolderScanState>
  createElement() {
    return _FolderScanControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FolderScanControllerProvider && other.sourceId == sourceId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, sourceId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FolderScanControllerRef on NotifierProviderRef<FolderScanState> {
  /// The parameter `sourceId` of this provider.
  String get sourceId;
}

class _FolderScanControllerProviderElement
    extends NotifierProviderElement<FolderScanController, FolderScanState>
    with FolderScanControllerRef {
  _FolderScanControllerProviderElement(super.provider);

  @override
  String get sourceId => (origin as FolderScanControllerProvider).sourceId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
