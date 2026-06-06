// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reachability.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sourceReachableHash() => r'74d43f63e133de5d112d7b24bd40d814052f190a';

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

/// Reachability of a specific source's server. Probes that server directly (not
/// internet connectivity), so a LAN server is reported online even with no WAN.
/// Resolves to false when there is no client for the source. Refresh by
/// invalidating this provider (the app-bar indicator does so on tap).
///
/// Copied from [sourceReachable].
@ProviderFor(sourceReachable)
const sourceReachableProvider = SourceReachableFamily();

/// Reachability of a specific source's server. Probes that server directly (not
/// internet connectivity), so a LAN server is reported online even with no WAN.
/// Resolves to false when there is no client for the source. Refresh by
/// invalidating this provider (the app-bar indicator does so on tap).
///
/// Copied from [sourceReachable].
class SourceReachableFamily extends Family<AsyncValue<bool>> {
  /// Reachability of a specific source's server. Probes that server directly (not
  /// internet connectivity), so a LAN server is reported online even with no WAN.
  /// Resolves to false when there is no client for the source. Refresh by
  /// invalidating this provider (the app-bar indicator does so on tap).
  ///
  /// Copied from [sourceReachable].
  const SourceReachableFamily();

  /// Reachability of a specific source's server. Probes that server directly (not
  /// internet connectivity), so a LAN server is reported online even with no WAN.
  /// Resolves to false when there is no client for the source. Refresh by
  /// invalidating this provider (the app-bar indicator does so on tap).
  ///
  /// Copied from [sourceReachable].
  SourceReachableProvider call(String sourceId) {
    return SourceReachableProvider(sourceId);
  }

  @override
  SourceReachableProvider getProviderOverride(
    covariant SourceReachableProvider provider,
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
  String? get name => r'sourceReachableProvider';
}

/// Reachability of a specific source's server. Probes that server directly (not
/// internet connectivity), so a LAN server is reported online even with no WAN.
/// Resolves to false when there is no client for the source. Refresh by
/// invalidating this provider (the app-bar indicator does so on tap).
///
/// Copied from [sourceReachable].
class SourceReachableProvider extends AutoDisposeFutureProvider<bool> {
  /// Reachability of a specific source's server. Probes that server directly (not
  /// internet connectivity), so a LAN server is reported online even with no WAN.
  /// Resolves to false when there is no client for the source. Refresh by
  /// invalidating this provider (the app-bar indicator does so on tap).
  ///
  /// Copied from [sourceReachable].
  SourceReachableProvider(String sourceId)
    : this._internal(
        (ref) => sourceReachable(ref as SourceReachableRef, sourceId),
        from: sourceReachableProvider,
        name: r'sourceReachableProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$sourceReachableHash,
        dependencies: SourceReachableFamily._dependencies,
        allTransitiveDependencies:
            SourceReachableFamily._allTransitiveDependencies,
        sourceId: sourceId,
      );

  SourceReachableProvider._internal(
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
    FutureOr<bool> Function(SourceReachableRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SourceReachableProvider._internal(
        (ref) => create(ref as SourceReachableRef),
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
    return _SourceReachableProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SourceReachableProvider && other.sourceId == sourceId;
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
mixin SourceReachableRef on AutoDisposeFutureProviderRef<bool> {
  /// The parameter `sourceId` of this provider.
  String get sourceId;
}

class _SourceReachableProviderElement
    extends AutoDisposeFutureProviderElement<bool>
    with SourceReachableRef {
  _SourceReachableProviderElement(super.provider);

  @override
  String get sourceId => (origin as SourceReachableProvider).sourceId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
