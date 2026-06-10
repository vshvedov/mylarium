// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_status_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$syncQueueStatusHash() => r'6f06cb92ab9d79f3c0a0c4f736da5d8d41f10763';

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

/// Watches the sync queue for [sourceId] and rolls it up into a
/// [SyncQueueStatus]. The table is tiny (at most one row per book), so the
/// whole filtered set is watched and counted in Dart.
///
/// Copied from [syncQueueStatus].
@ProviderFor(syncQueueStatus)
const syncQueueStatusProvider = SyncQueueStatusFamily();

/// Watches the sync queue for [sourceId] and rolls it up into a
/// [SyncQueueStatus]. The table is tiny (at most one row per book), so the
/// whole filtered set is watched and counted in Dart.
///
/// Copied from [syncQueueStatus].
class SyncQueueStatusFamily extends Family<AsyncValue<SyncQueueStatus>> {
  /// Watches the sync queue for [sourceId] and rolls it up into a
  /// [SyncQueueStatus]. The table is tiny (at most one row per book), so the
  /// whole filtered set is watched and counted in Dart.
  ///
  /// Copied from [syncQueueStatus].
  const SyncQueueStatusFamily();

  /// Watches the sync queue for [sourceId] and rolls it up into a
  /// [SyncQueueStatus]. The table is tiny (at most one row per book), so the
  /// whole filtered set is watched and counted in Dart.
  ///
  /// Copied from [syncQueueStatus].
  SyncQueueStatusProvider call(String sourceId) {
    return SyncQueueStatusProvider(sourceId);
  }

  @override
  SyncQueueStatusProvider getProviderOverride(
    covariant SyncQueueStatusProvider provider,
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
  String? get name => r'syncQueueStatusProvider';
}

/// Watches the sync queue for [sourceId] and rolls it up into a
/// [SyncQueueStatus]. The table is tiny (at most one row per book), so the
/// whole filtered set is watched and counted in Dart.
///
/// Copied from [syncQueueStatus].
class SyncQueueStatusProvider
    extends AutoDisposeStreamProvider<SyncQueueStatus> {
  /// Watches the sync queue for [sourceId] and rolls it up into a
  /// [SyncQueueStatus]. The table is tiny (at most one row per book), so the
  /// whole filtered set is watched and counted in Dart.
  ///
  /// Copied from [syncQueueStatus].
  SyncQueueStatusProvider(String sourceId)
    : this._internal(
        (ref) => syncQueueStatus(ref as SyncQueueStatusRef, sourceId),
        from: syncQueueStatusProvider,
        name: r'syncQueueStatusProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$syncQueueStatusHash,
        dependencies: SyncQueueStatusFamily._dependencies,
        allTransitiveDependencies:
            SyncQueueStatusFamily._allTransitiveDependencies,
        sourceId: sourceId,
      );

  SyncQueueStatusProvider._internal(
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
    Stream<SyncQueueStatus> Function(SyncQueueStatusRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SyncQueueStatusProvider._internal(
        (ref) => create(ref as SyncQueueStatusRef),
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
  AutoDisposeStreamProviderElement<SyncQueueStatus> createElement() {
    return _SyncQueueStatusProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SyncQueueStatusProvider && other.sourceId == sourceId;
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
mixin SyncQueueStatusRef on AutoDisposeStreamProviderRef<SyncQueueStatus> {
  /// The parameter `sourceId` of this provider.
  String get sourceId;
}

class _SyncQueueStatusProviderElement
    extends AutoDisposeStreamProviderElement<SyncQueueStatus>
    with SyncQueueStatusRef {
  _SyncQueueStatusProviderElement(super.provider);

  @override
  String get sourceId => (origin as SyncQueueStatusProvider).sourceId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
