// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pin_controllers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$pinnedItemsHash() => r'e460ba0a831b1175004ebf5c472d341ba613b9dc';

/// The active source's pinned items, newest first, AGE-GATED exactly like the
/// other home rails: a restricted series (or a book whose series is restricted)
/// is hidden unless its library is currently restricted-visible, and an item
/// whose gating series is not cached is hidden outright (never leaks an
/// unclassified restricted entry). Reads only the local cache, so the rail and
/// its gating work offline.
///
/// [lock] is captured before the `.map` and `appLockProvider` is watched, so
/// unlocking a library re-runs this provider and re-subscribes the stream with
/// the new lock, revealing previously-hidden pins live. That ordering is
/// load-bearing (a test covers it); do not fold the `lock` read into the `.map`.
///
/// Copied from [pinnedItems].
@ProviderFor(pinnedItems)
final pinnedItemsProvider =
    AutoDisposeStreamProvider<List<PinnedEntry>>.internal(
      pinnedItems,
      name: r'pinnedItemsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$pinnedItemsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PinnedItemsRef = AutoDisposeStreamProviderRef<List<PinnedEntry>>;
String _$isPinnedHash() => r'b10ae18fc8b98cdd247b1b640b2d6e12383cdba0';

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
