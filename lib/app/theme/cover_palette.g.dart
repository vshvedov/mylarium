// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cover_palette.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$coverPaletteHash() => r'47d5f7bf0199eb7dfde785e1b4db9070b1f8ce27';

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

/// The cover palette for an owner, cached for the app lifetime (keepAlive) and
/// keyed per owner id. Null when the owner has no cover.
///
/// Copied from [coverPalette].
@ProviderFor(coverPalette)
const coverPaletteProvider = CoverPaletteFamily();

/// The cover palette for an owner, cached for the app lifetime (keepAlive) and
/// keyed per owner id. Null when the owner has no cover.
///
/// Copied from [coverPalette].
class CoverPaletteFamily extends Family<AsyncValue<CoverPalette?>> {
  /// The cover palette for an owner, cached for the app lifetime (keepAlive) and
  /// keyed per owner id. Null when the owner has no cover.
  ///
  /// Copied from [coverPalette].
  const CoverPaletteFamily();

  /// The cover palette for an owner, cached for the app lifetime (keepAlive) and
  /// keyed per owner id. Null when the owner has no cover.
  ///
  /// Copied from [coverPalette].
  CoverPaletteProvider call(String sourceId, String ownerType, String ownerId) {
    return CoverPaletteProvider(sourceId, ownerType, ownerId);
  }

  @override
  CoverPaletteProvider getProviderOverride(
    covariant CoverPaletteProvider provider,
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
  String? get name => r'coverPaletteProvider';
}

/// The cover palette for an owner, cached for the app lifetime (keepAlive) and
/// keyed per owner id. Null when the owner has no cover.
///
/// Copied from [coverPalette].
class CoverPaletteProvider extends FutureProvider<CoverPalette?> {
  /// The cover palette for an owner, cached for the app lifetime (keepAlive) and
  /// keyed per owner id. Null when the owner has no cover.
  ///
  /// Copied from [coverPalette].
  CoverPaletteProvider(String sourceId, String ownerType, String ownerId)
    : this._internal(
        (ref) =>
            coverPalette(ref as CoverPaletteRef, sourceId, ownerType, ownerId),
        from: coverPaletteProvider,
        name: r'coverPaletteProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$coverPaletteHash,
        dependencies: CoverPaletteFamily._dependencies,
        allTransitiveDependencies:
            CoverPaletteFamily._allTransitiveDependencies,
        sourceId: sourceId,
        ownerType: ownerType,
        ownerId: ownerId,
      );

  CoverPaletteProvider._internal(
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
    FutureOr<CoverPalette?> Function(CoverPaletteRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CoverPaletteProvider._internal(
        (ref) => create(ref as CoverPaletteRef),
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
  FutureProviderElement<CoverPalette?> createElement() {
    return _CoverPaletteProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CoverPaletteProvider &&
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
mixin CoverPaletteRef on FutureProviderRef<CoverPalette?> {
  /// The parameter `sourceId` of this provider.
  String get sourceId;

  /// The parameter `ownerType` of this provider.
  String get ownerType;

  /// The parameter `ownerId` of this provider.
  String get ownerId;
}

class _CoverPaletteProviderElement extends FutureProviderElement<CoverPalette?>
    with CoverPaletteRef {
  _CoverPaletteProviderElement(super.provider);

  @override
  String get sourceId => (origin as CoverPaletteProvider).sourceId;
  @override
  String get ownerType => (origin as CoverPaletteProvider).ownerType;
  @override
  String get ownerId => (origin as CoverPaletteProvider).ownerId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
