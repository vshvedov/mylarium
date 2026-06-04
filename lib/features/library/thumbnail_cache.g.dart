// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thumbnail_cache.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$coverImageHash() => r'9f2f720182d8cc0b78b0b28cc6974f8458393219';

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

/// Resolves a cover [ImageProvider] for an owner under [sourceId]. Null when
/// there is no api or the fetch fails (caller renders a placeholder).
///
/// Copied from [coverImage].
@ProviderFor(coverImage)
const coverImageProvider = CoverImageFamily();

/// Resolves a cover [ImageProvider] for an owner under [sourceId]. Null when
/// there is no api or the fetch fails (caller renders a placeholder).
///
/// Copied from [coverImage].
class CoverImageFamily extends Family<AsyncValue<ImageProvider?>> {
  /// Resolves a cover [ImageProvider] for an owner under [sourceId]. Null when
  /// there is no api or the fetch fails (caller renders a placeholder).
  ///
  /// Copied from [coverImage].
  const CoverImageFamily();

  /// Resolves a cover [ImageProvider] for an owner under [sourceId]. Null when
  /// there is no api or the fetch fails (caller renders a placeholder).
  ///
  /// Copied from [coverImage].
  CoverImageProvider call(String sourceId, String ownerType, String ownerId) {
    return CoverImageProvider(sourceId, ownerType, ownerId);
  }

  @override
  CoverImageProvider getProviderOverride(
    covariant CoverImageProvider provider,
  ) {
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
  String? get name => r'coverImageProvider';
}

/// Resolves a cover [ImageProvider] for an owner under [sourceId]. Null when
/// there is no api or the fetch fails (caller renders a placeholder).
///
/// Copied from [coverImage].
class CoverImageProvider extends AutoDisposeFutureProvider<ImageProvider?> {
  /// Resolves a cover [ImageProvider] for an owner under [sourceId]. Null when
  /// there is no api or the fetch fails (caller renders a placeholder).
  ///
  /// Copied from [coverImage].
  CoverImageProvider(String sourceId, String ownerType, String ownerId)
    : this._internal(
        (ref) => coverImage(ref as CoverImageRef, sourceId, ownerType, ownerId),
        from: coverImageProvider,
        name: r'coverImageProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$coverImageHash,
        dependencies: CoverImageFamily._dependencies,
        allTransitiveDependencies: CoverImageFamily._allTransitiveDependencies,
        sourceId: sourceId,
        ownerType: ownerType,
        ownerId: ownerId,
      );

  CoverImageProvider._internal(
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
  Override overrideWith(
    FutureOr<ImageProvider?> Function(CoverImageRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CoverImageProvider._internal(
        (ref) => create(ref as CoverImageRef),
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
  AutoDisposeFutureProviderElement<ImageProvider?> createElement() {
    return _CoverImageProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CoverImageProvider &&
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
mixin CoverImageRef on AutoDisposeFutureProviderRef<ImageProvider?> {
  /// The parameter `sourceId` of this provider.
  String get sourceId;

  /// The parameter `ownerType` of this provider.
  String get ownerType;

  /// The parameter `ownerId` of this provider.
  String get ownerId;
}

class _CoverImageProviderElement
    extends AutoDisposeFutureProviderElement<ImageProvider?>
    with CoverImageRef {
  _CoverImageProviderElement(super.provider);

  @override
  String get sourceId => (origin as CoverImageProvider).sourceId;
  @override
  String get ownerType => (origin as CoverImageProvider).ownerType;
  @override
  String get ownerId => (origin as CoverImageProvider).ownerId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
