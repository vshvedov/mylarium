// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reader_navigation.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$bookNeighborsHash() => r'945d6f17213a77e35122101fe4c6cff5233b27ff';

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

/// Resolves the prev/next book within a series, ordered exactly like the series
/// detail list (numberSort, then number). Best-effort online refresh first (so a
/// partially-cached series fills in) using a SOURCE-SCOPED api (a book may live on
/// a non-active server); offline it resolves from the cache alone. Returns empty
/// neighbors when the book is not found in the cached order.
///
/// Copied from [bookNeighbors].
@ProviderFor(bookNeighbors)
const bookNeighborsProvider = BookNeighborsFamily();

/// Resolves the prev/next book within a series, ordered exactly like the series
/// detail list (numberSort, then number). Best-effort online refresh first (so a
/// partially-cached series fills in) using a SOURCE-SCOPED api (a book may live on
/// a non-active server); offline it resolves from the cache alone. Returns empty
/// neighbors when the book is not found in the cached order.
///
/// Copied from [bookNeighbors].
class BookNeighborsFamily extends Family<AsyncValue<BookNeighbors>> {
  /// Resolves the prev/next book within a series, ordered exactly like the series
  /// detail list (numberSort, then number). Best-effort online refresh first (so a
  /// partially-cached series fills in) using a SOURCE-SCOPED api (a book may live on
  /// a non-active server); offline it resolves from the cache alone. Returns empty
  /// neighbors when the book is not found in the cached order.
  ///
  /// Copied from [bookNeighbors].
  const BookNeighborsFamily();

  /// Resolves the prev/next book within a series, ordered exactly like the series
  /// detail list (numberSort, then number). Best-effort online refresh first (so a
  /// partially-cached series fills in) using a SOURCE-SCOPED api (a book may live on
  /// a non-active server); offline it resolves from the cache alone. Returns empty
  /// neighbors when the book is not found in the cached order.
  ///
  /// Copied from [bookNeighbors].
  BookNeighborsProvider call(String sourceId, String seriesId, String bookId) {
    return BookNeighborsProvider(sourceId, seriesId, bookId);
  }

  @override
  BookNeighborsProvider getProviderOverride(
    covariant BookNeighborsProvider provider,
  ) {
    return call(provider.sourceId, provider.seriesId, provider.bookId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'bookNeighborsProvider';
}

/// Resolves the prev/next book within a series, ordered exactly like the series
/// detail list (numberSort, then number). Best-effort online refresh first (so a
/// partially-cached series fills in) using a SOURCE-SCOPED api (a book may live on
/// a non-active server); offline it resolves from the cache alone. Returns empty
/// neighbors when the book is not found in the cached order.
///
/// Copied from [bookNeighbors].
class BookNeighborsProvider extends AutoDisposeFutureProvider<BookNeighbors> {
  /// Resolves the prev/next book within a series, ordered exactly like the series
  /// detail list (numberSort, then number). Best-effort online refresh first (so a
  /// partially-cached series fills in) using a SOURCE-SCOPED api (a book may live on
  /// a non-active server); offline it resolves from the cache alone. Returns empty
  /// neighbors when the book is not found in the cached order.
  ///
  /// Copied from [bookNeighbors].
  BookNeighborsProvider(String sourceId, String seriesId, String bookId)
    : this._internal(
        (ref) =>
            bookNeighbors(ref as BookNeighborsRef, sourceId, seriesId, bookId),
        from: bookNeighborsProvider,
        name: r'bookNeighborsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$bookNeighborsHash,
        dependencies: BookNeighborsFamily._dependencies,
        allTransitiveDependencies:
            BookNeighborsFamily._allTransitiveDependencies,
        sourceId: sourceId,
        seriesId: seriesId,
        bookId: bookId,
      );

  BookNeighborsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.sourceId,
    required this.seriesId,
    required this.bookId,
  }) : super.internal();

  final String sourceId;
  final String seriesId;
  final String bookId;

  @override
  Override overrideWith(
    FutureOr<BookNeighbors> Function(BookNeighborsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: BookNeighborsProvider._internal(
        (ref) => create(ref as BookNeighborsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        sourceId: sourceId,
        seriesId: seriesId,
        bookId: bookId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<BookNeighbors> createElement() {
    return _BookNeighborsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BookNeighborsProvider &&
        other.sourceId == sourceId &&
        other.seriesId == seriesId &&
        other.bookId == bookId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, sourceId.hashCode);
    hash = _SystemHash.combine(hash, seriesId.hashCode);
    hash = _SystemHash.combine(hash, bookId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin BookNeighborsRef on AutoDisposeFutureProviderRef<BookNeighbors> {
  /// The parameter `sourceId` of this provider.
  String get sourceId;

  /// The parameter `seriesId` of this provider.
  String get seriesId;

  /// The parameter `bookId` of this provider.
  String get bookId;
}

class _BookNeighborsProviderElement
    extends AutoDisposeFutureProviderElement<BookNeighbors>
    with BookNeighborsRef {
  _BookNeighborsProviderElement(super.provider);

  @override
  String get sourceId => (origin as BookNeighborsProvider).sourceId;
  @override
  String get seriesId => (origin as BookNeighborsProvider).seriesId;
  @override
  String get bookId => (origin as BookNeighborsProvider).bookId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
