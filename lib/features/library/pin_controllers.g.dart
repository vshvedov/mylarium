// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pin_controllers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$pinnedItemsHash() => r'1a94720c55b9eaf313a2e8e5b6ac9fc23ba2c300';

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

/// The active source's pinned items, newest first. An item whose owner row is
/// not cached is dropped; an item whose library is locked is hidden. Reads only
/// the local cache, so the rail and its gating work offline.
///
/// [lock] is captured before the `.map` and `appLockProvider` is watched, so
/// locking/unlocking a library re-runs this provider and re-subscribes the
/// stream with the new lock, hiding/revealing pins live. That ordering is
/// load-bearing (a test covers it); do not fold the `lock` read into the `.map`.
///
/// Copied from [pinnedItems].
@ProviderFor(pinnedItems)
const pinnedItemsProvider = PinnedItemsFamily();

/// The active source's pinned items, newest first. An item whose owner row is
/// not cached is dropped; an item whose library is locked is hidden. Reads only
/// the local cache, so the rail and its gating work offline.
///
/// [lock] is captured before the `.map` and `appLockProvider` is watched, so
/// locking/unlocking a library re-runs this provider and re-subscribes the
/// stream with the new lock, hiding/revealing pins live. That ordering is
/// load-bearing (a test covers it); do not fold the `lock` read into the `.map`.
///
/// Copied from [pinnedItems].
class PinnedItemsFamily extends Family<AsyncValue<List<PinnedEntry>>> {
  /// The active source's pinned items, newest first. An item whose owner row is
  /// not cached is dropped; an item whose library is locked is hidden. Reads only
  /// the local cache, so the rail and its gating work offline.
  ///
  /// [lock] is captured before the `.map` and `appLockProvider` is watched, so
  /// locking/unlocking a library re-runs this provider and re-subscribes the
  /// stream with the new lock, hiding/revealing pins live. That ordering is
  /// load-bearing (a test covers it); do not fold the `lock` read into the `.map`.
  ///
  /// Copied from [pinnedItems].
  const PinnedItemsFamily();

  /// The active source's pinned items, newest first. An item whose owner row is
  /// not cached is dropped; an item whose library is locked is hidden. Reads only
  /// the local cache, so the rail and its gating work offline.
  ///
  /// [lock] is captured before the `.map` and `appLockProvider` is watched, so
  /// locking/unlocking a library re-runs this provider and re-subscribes the
  /// stream with the new lock, hiding/revealing pins live. That ordering is
  /// load-bearing (a test covers it); do not fold the `lock` read into the `.map`.
  ///
  /// Copied from [pinnedItems].
  PinnedItemsProvider call(String sourceId) {
    return PinnedItemsProvider(sourceId);
  }

  @override
  PinnedItemsProvider getProviderOverride(
    covariant PinnedItemsProvider provider,
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
  String? get name => r'pinnedItemsProvider';
}

/// The active source's pinned items, newest first. An item whose owner row is
/// not cached is dropped; an item whose library is locked is hidden. Reads only
/// the local cache, so the rail and its gating work offline.
///
/// [lock] is captured before the `.map` and `appLockProvider` is watched, so
/// locking/unlocking a library re-runs this provider and re-subscribes the
/// stream with the new lock, hiding/revealing pins live. That ordering is
/// load-bearing (a test covers it); do not fold the `lock` read into the `.map`.
///
/// Copied from [pinnedItems].
class PinnedItemsProvider extends AutoDisposeStreamProvider<List<PinnedEntry>> {
  /// The active source's pinned items, newest first. An item whose owner row is
  /// not cached is dropped; an item whose library is locked is hidden. Reads only
  /// the local cache, so the rail and its gating work offline.
  ///
  /// [lock] is captured before the `.map` and `appLockProvider` is watched, so
  /// locking/unlocking a library re-runs this provider and re-subscribes the
  /// stream with the new lock, hiding/revealing pins live. That ordering is
  /// load-bearing (a test covers it); do not fold the `lock` read into the `.map`.
  ///
  /// Copied from [pinnedItems].
  PinnedItemsProvider(String sourceId)
    : this._internal(
        (ref) => pinnedItems(ref as PinnedItemsRef, sourceId),
        from: pinnedItemsProvider,
        name: r'pinnedItemsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$pinnedItemsHash,
        dependencies: PinnedItemsFamily._dependencies,
        allTransitiveDependencies: PinnedItemsFamily._allTransitiveDependencies,
        sourceId: sourceId,
      );

  PinnedItemsProvider._internal(
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
    Stream<List<PinnedEntry>> Function(PinnedItemsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PinnedItemsProvider._internal(
        (ref) => create(ref as PinnedItemsRef),
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
  AutoDisposeStreamProviderElement<List<PinnedEntry>> createElement() {
    return _PinnedItemsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PinnedItemsProvider && other.sourceId == sourceId;
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
mixin PinnedItemsRef on AutoDisposeStreamProviderRef<List<PinnedEntry>> {
  /// The parameter `sourceId` of this provider.
  String get sourceId;
}

class _PinnedItemsProviderElement
    extends AutoDisposeStreamProviderElement<List<PinnedEntry>>
    with PinnedItemsRef {
  _PinnedItemsProviderElement(super.provider);

  @override
  String get sourceId => (origin as PinnedItemsProvider).sourceId;
}

String _$isPinnedHash() => r'b10ae18fc8b98cdd247b1b640b2d6e12383cdba0';

/// Whether a given series/book is pinned (drives the context-menu label and the
/// series-detail pin button).
///
/// Copied from [isPinned].
@ProviderFor(isPinned)
const isPinnedProvider = IsPinnedFamily();

/// Whether a given series/book is pinned (drives the context-menu label and the
/// series-detail pin button).
///
/// Copied from [isPinned].
class IsPinnedFamily extends Family<AsyncValue<bool>> {
  /// Whether a given series/book is pinned (drives the context-menu label and the
  /// series-detail pin button).
  ///
  /// Copied from [isPinned].
  const IsPinnedFamily();

  /// Whether a given series/book is pinned (drives the context-menu label and the
  /// series-detail pin button).
  ///
  /// Copied from [isPinned].
  IsPinnedProvider call(String sourceId, String ownerType, String ownerId) {
    return IsPinnedProvider(sourceId, ownerType, ownerId);
  }

  @override
  IsPinnedProvider getProviderOverride(covariant IsPinnedProvider provider) {
    return call(provider.sourceId, provider.ownerType, provider.ownerId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'isPinnedProvider';
}

/// Whether a given series/book is pinned (drives the context-menu label and the
/// series-detail pin button).
///
/// Copied from [isPinned].
class IsPinnedProvider extends AutoDisposeStreamProvider<bool> {
  /// Whether a given series/book is pinned (drives the context-menu label and the
  /// series-detail pin button).
  ///
  /// Copied from [isPinned].
  IsPinnedProvider(String sourceId, String ownerType, String ownerId)
    : this._internal(
        (ref) => isPinned(ref as IsPinnedRef, sourceId, ownerType, ownerId),
        from: isPinnedProvider,
        name: r'isPinnedProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$isPinnedHash,
        dependencies: IsPinnedFamily._dependencies,
        allTransitiveDependencies: IsPinnedFamily._allTransitiveDependencies,
        sourceId: sourceId,
        ownerType: ownerType,
        ownerId: ownerId,
      );

  IsPinnedProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.sourceId,
    required this.ownerType,
    required this.ownerId,
  }) : super.internal();

  final String sourceId;
  final String ownerType;
  final String ownerId;

  @override
  Override overrideWith(Stream<bool> Function(IsPinnedRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: IsPinnedProvider._internal(
        (ref) => create(ref as IsPinnedRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        sourceId: sourceId,
        ownerType: ownerType,
        ownerId: ownerId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<bool> createElement() {
    return _IsPinnedProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IsPinnedProvider &&
        other.sourceId == sourceId &&
        other.ownerType == ownerType &&
        other.ownerId == ownerId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, sourceId.hashCode);
    hash = _SystemHash.combine(hash, ownerType.hashCode);
    hash = _SystemHash.combine(hash, ownerId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin IsPinnedRef on AutoDisposeStreamProviderRef<bool> {
  /// The parameter `sourceId` of this provider.
  String get sourceId;

  /// The parameter `ownerType` of this provider.
  String get ownerType;

  /// The parameter `ownerId` of this provider.
  String get ownerId;
}

class _IsPinnedProviderElement extends AutoDisposeStreamProviderElement<bool>
    with IsPinnedRef {
  _IsPinnedProviderElement(super.provider);

  @override
  String get sourceId => (origin as IsPinnedProvider).sourceId;
  @override
  String get ownerType => (origin as IsPinnedProvider).ownerType;
  @override
  String get ownerId => (origin as IsPinnedProvider).ownerId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
