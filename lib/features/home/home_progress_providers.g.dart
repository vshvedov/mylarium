// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_progress_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cachedBookPagesCountHash() =>
    r'fa53a300886f7387b8d3f75adac230fd7358d19b';

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

/// The cached page count for a server book (from the Books row the home rails
/// and detail screens cache), or null when the book is not cached yet or
/// reports no pages. Backs the keep-reading rail's "p. X of Y" caption; a null
/// simply omits the bar + caption.
///
/// Copied from [cachedBookPagesCount].
@ProviderFor(cachedBookPagesCount)
const cachedBookPagesCountProvider = CachedBookPagesCountFamily();

/// The cached page count for a server book (from the Books row the home rails
/// and detail screens cache), or null when the book is not cached yet or
/// reports no pages. Backs the keep-reading rail's "p. X of Y" caption; a null
/// simply omits the bar + caption.
///
/// Copied from [cachedBookPagesCount].
class CachedBookPagesCountFamily extends Family<AsyncValue<int?>> {
  /// The cached page count for a server book (from the Books row the home rails
  /// and detail screens cache), or null when the book is not cached yet or
  /// reports no pages. Backs the keep-reading rail's "p. X of Y" caption; a null
  /// simply omits the bar + caption.
  ///
  /// Copied from [cachedBookPagesCount].
  const CachedBookPagesCountFamily();

  /// The cached page count for a server book (from the Books row the home rails
  /// and detail screens cache), or null when the book is not cached yet or
  /// reports no pages. Backs the keep-reading rail's "p. X of Y" caption; a null
  /// simply omits the bar + caption.
  ///
  /// Copied from [cachedBookPagesCount].
  CachedBookPagesCountProvider call(String sourceId, String bookId) {
    return CachedBookPagesCountProvider(sourceId, bookId);
  }

  @override
  CachedBookPagesCountProvider getProviderOverride(
    covariant CachedBookPagesCountProvider provider,
  ) {
    return call(provider.sourceId, provider.bookId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'cachedBookPagesCountProvider';
}

/// The cached page count for a server book (from the Books row the home rails
/// and detail screens cache), or null when the book is not cached yet or
/// reports no pages. Backs the keep-reading rail's "p. X of Y" caption; a null
/// simply omits the bar + caption.
///
/// Copied from [cachedBookPagesCount].
class CachedBookPagesCountProvider extends AutoDisposeFutureProvider<int?> {
  /// The cached page count for a server book (from the Books row the home rails
  /// and detail screens cache), or null when the book is not cached yet or
  /// reports no pages. Backs the keep-reading rail's "p. X of Y" caption; a null
  /// simply omits the bar + caption.
  ///
  /// Copied from [cachedBookPagesCount].
  CachedBookPagesCountProvider(String sourceId, String bookId)
    : this._internal(
        (ref) => cachedBookPagesCount(
          ref as CachedBookPagesCountRef,
          sourceId,
          bookId,
        ),
        from: cachedBookPagesCountProvider,
        name: r'cachedBookPagesCountProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$cachedBookPagesCountHash,
        dependencies: CachedBookPagesCountFamily._dependencies,
        allTransitiveDependencies:
            CachedBookPagesCountFamily._allTransitiveDependencies,
        sourceId: sourceId,
        bookId: bookId,
      );

  CachedBookPagesCountProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.sourceId,
    required this.bookId,
  }) : super.internal();

  final String sourceId;
  final String bookId;

  @override
  Override overrideWith(
    FutureOr<int?> Function(CachedBookPagesCountRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CachedBookPagesCountProvider._internal(
        (ref) => create(ref as CachedBookPagesCountRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        sourceId: sourceId,
        bookId: bookId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<int?> createElement() {
    return _CachedBookPagesCountProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CachedBookPagesCountProvider &&
        other.sourceId == sourceId &&
        other.bookId == bookId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, sourceId.hashCode);
    hash = _SystemHash.combine(hash, bookId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CachedBookPagesCountRef on AutoDisposeFutureProviderRef<int?> {
  /// The parameter `sourceId` of this provider.
  String get sourceId;

  /// The parameter `bookId` of this provider.
  String get bookId;
}

class _CachedBookPagesCountProviderElement
    extends AutoDisposeFutureProviderElement<int?>
    with CachedBookPagesCountRef {
  _CachedBookPagesCountProviderElement(super.provider);

  @override
  String get sourceId => (origin as CachedBookPagesCountProvider).sourceId;
  @override
  String get bookId => (origin as CachedBookPagesCountProvider).bookId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
