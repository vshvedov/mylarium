// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_browse_controllers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$onDeckHash() => r'0c5df2f436ff63dd572224e5e9672939587cf8c0';

/// On-Deck / Keep-Reading books for the active source. NOT age-gated: this is
/// the user's own in-progress reading.
///
/// Copied from [onDeck].
@ProviderFor(onDeck)
final onDeckProvider = AutoDisposeFutureProvider<List<BookDto>>.internal(
  onDeck,
  name: r'onDeckProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$onDeckHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OnDeckRef = AutoDisposeFutureProviderRef<List<BookDto>>;
String _$recentlyAddedSeriesHash() =>
    r'8047f2bfa7df4ceb29d1c9890109dfb48a409be5';

/// Recently added series. Age-gated by each series' own ageRating + its
/// library's prefs (no series cache needed, so no leak on a fresh install).
///
/// Copied from [recentlyAddedSeries].
@ProviderFor(recentlyAddedSeries)
final recentlyAddedSeriesProvider =
    AutoDisposeFutureProvider<List<SeriesDto>>.internal(
      recentlyAddedSeries,
      name: r'recentlyAddedSeriesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$recentlyAddedSeriesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecentlyAddedSeriesRef = AutoDisposeFutureProviderRef<List<SeriesDto>>;
String _$recentlyUpdatedSeriesHash() =>
    r'd2b5072d78c44086a6dd303ff01dd75a956c5d74';

/// Recently updated series. Age-gated like [recentlyAddedSeries].
///
/// Copied from [recentlyUpdatedSeries].
@ProviderFor(recentlyUpdatedSeries)
final recentlyUpdatedSeriesProvider =
    AutoDisposeFutureProvider<List<SeriesDto>>.internal(
      recentlyUpdatedSeries,
      name: r'recentlyUpdatedSeriesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$recentlyUpdatedSeriesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecentlyUpdatedSeriesRef =
    AutoDisposeFutureProviderRef<List<SeriesDto>>;
String _$collectionsHash() => r'dbb2113e61fd88c65bc6e0abef96f923f4100e91';

/// See also [collections].
@ProviderFor(collections)
final collectionsProvider =
    AutoDisposeFutureProvider<List<CollectionDto>>.internal(
      collections,
      name: r'collectionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$collectionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CollectionsRef = AutoDisposeFutureProviderRef<List<CollectionDto>>;
String _$readListsHash() => r'2f5a84d436d34c5a595378aab6ccd1c3f447a3da';

/// See also [readLists].
@ProviderFor(readLists)
final readListsProvider = AutoDisposeFutureProvider<List<ReadListDto>>.internal(
  readLists,
  name: r'readListsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$readListsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ReadListsRef = AutoDisposeFutureProviderRef<List<ReadListDto>>;
String _$collectionSeriesHash() => r'3d72a68b8a5afa5a450efe9d6a86d5b77be402d0';

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

/// Series in a collection, age-gated like the rails (by each series' own
/// ageRating + its library prefs).
///
/// Copied from [collectionSeries].
@ProviderFor(collectionSeries)
const collectionSeriesProvider = CollectionSeriesFamily();

/// Series in a collection, age-gated like the rails (by each series' own
/// ageRating + its library prefs).
///
/// Copied from [collectionSeries].
class CollectionSeriesFamily extends Family<AsyncValue<List<SeriesDto>>> {
  /// Series in a collection, age-gated like the rails (by each series' own
  /// ageRating + its library prefs).
  ///
  /// Copied from [collectionSeries].
  const CollectionSeriesFamily();

  /// Series in a collection, age-gated like the rails (by each series' own
  /// ageRating + its library prefs).
  ///
  /// Copied from [collectionSeries].
  CollectionSeriesProvider call(String collectionId) {
    return CollectionSeriesProvider(collectionId);
  }

  @override
  CollectionSeriesProvider getProviderOverride(
    covariant CollectionSeriesProvider provider,
  ) {
    return call(provider.collectionId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'collectionSeriesProvider';
}

/// Series in a collection, age-gated like the rails (by each series' own
/// ageRating + its library prefs).
///
/// Copied from [collectionSeries].
class CollectionSeriesProvider
    extends AutoDisposeFutureProvider<List<SeriesDto>> {
  /// Series in a collection, age-gated like the rails (by each series' own
  /// ageRating + its library prefs).
  ///
  /// Copied from [collectionSeries].
  CollectionSeriesProvider(String collectionId)
    : this._internal(
        (ref) => collectionSeries(ref as CollectionSeriesRef, collectionId),
        from: collectionSeriesProvider,
        name: r'collectionSeriesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$collectionSeriesHash,
        dependencies: CollectionSeriesFamily._dependencies,
        allTransitiveDependencies:
            CollectionSeriesFamily._allTransitiveDependencies,
        collectionId: collectionId,
      );

  CollectionSeriesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.collectionId,
  }) : super.internal();

  final String collectionId;

  @override
  Override overrideWith(
    FutureOr<List<SeriesDto>> Function(CollectionSeriesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CollectionSeriesProvider._internal(
        (ref) => create(ref as CollectionSeriesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        collectionId: collectionId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<SeriesDto>> createElement() {
    return _CollectionSeriesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CollectionSeriesProvider &&
        other.collectionId == collectionId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, collectionId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CollectionSeriesRef on AutoDisposeFutureProviderRef<List<SeriesDto>> {
  /// The parameter `collectionId` of this provider.
  String get collectionId;
}

class _CollectionSeriesProviderElement
    extends AutoDisposeFutureProviderElement<List<SeriesDto>>
    with CollectionSeriesRef {
  _CollectionSeriesProviderElement(super.provider);

  @override
  String get collectionId => (origin as CollectionSeriesProvider).collectionId;
}

String _$readListBooksHash() => r'26456e5b2ea4e6a793f06f2252920239c7c47704';

/// Books in a read list (not age-gated; a curated reading order).
///
/// Copied from [readListBooks].
@ProviderFor(readListBooks)
const readListBooksProvider = ReadListBooksFamily();

/// Books in a read list (not age-gated; a curated reading order).
///
/// Copied from [readListBooks].
class ReadListBooksFamily extends Family<AsyncValue<List<BookDto>>> {
  /// Books in a read list (not age-gated; a curated reading order).
  ///
  /// Copied from [readListBooks].
  const ReadListBooksFamily();

  /// Books in a read list (not age-gated; a curated reading order).
  ///
  /// Copied from [readListBooks].
  ReadListBooksProvider call(String readListId) {
    return ReadListBooksProvider(readListId);
  }

  @override
  ReadListBooksProvider getProviderOverride(
    covariant ReadListBooksProvider provider,
  ) {
    return call(provider.readListId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'readListBooksProvider';
}

/// Books in a read list (not age-gated; a curated reading order).
///
/// Copied from [readListBooks].
class ReadListBooksProvider extends AutoDisposeFutureProvider<List<BookDto>> {
  /// Books in a read list (not age-gated; a curated reading order).
  ///
  /// Copied from [readListBooks].
  ReadListBooksProvider(String readListId)
    : this._internal(
        (ref) => readListBooks(ref as ReadListBooksRef, readListId),
        from: readListBooksProvider,
        name: r'readListBooksProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$readListBooksHash,
        dependencies: ReadListBooksFamily._dependencies,
        allTransitiveDependencies:
            ReadListBooksFamily._allTransitiveDependencies,
        readListId: readListId,
      );

  ReadListBooksProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.readListId,
  }) : super.internal();

  final String readListId;

  @override
  Override overrideWith(
    FutureOr<List<BookDto>> Function(ReadListBooksRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ReadListBooksProvider._internal(
        (ref) => create(ref as ReadListBooksRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        readListId: readListId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<BookDto>> createElement() {
    return _ReadListBooksProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ReadListBooksProvider && other.readListId == readListId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, readListId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ReadListBooksRef on AutoDisposeFutureProviderRef<List<BookDto>> {
  /// The parameter `readListId` of this provider.
  String get readListId;
}

class _ReadListBooksProviderElement
    extends AutoDisposeFutureProviderElement<List<BookDto>>
    with ReadListBooksRef {
  _ReadListBooksProviderElement(super.provider);

  @override
  String get readListId => (origin as ReadListBooksProvider).readListId;
}

String _$librariesHash() => r'7b0ea1124dfdda79391603f4c6a79cd13aa623b1';

/// Libraries for the active source (drives the lock-settings screen and library
/// grid entry). Refreshes from the server on first watch, then streams the
/// cache.
///
/// Copied from [libraries].
@ProviderFor(libraries)
final librariesProvider = AutoDisposeStreamProvider<List<Library>>.internal(
  libraries,
  name: r'librariesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$librariesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LibrariesRef = AutoDisposeStreamProviderRef<List<Library>>;
String _$seriesBooksHash() => r'a580c2d86698e42c42172dbb6c8ec7ad11a37abe';

/// A series' books, streamed from the cache. Kicks an online refresh first.
///
/// Copied from [seriesBooks].
@ProviderFor(seriesBooks)
const seriesBooksProvider = SeriesBooksFamily();

/// A series' books, streamed from the cache. Kicks an online refresh first.
///
/// Copied from [seriesBooks].
class SeriesBooksFamily extends Family<AsyncValue<List<Book>>> {
  /// A series' books, streamed from the cache. Kicks an online refresh first.
  ///
  /// Copied from [seriesBooks].
  const SeriesBooksFamily();

  /// A series' books, streamed from the cache. Kicks an online refresh first.
  ///
  /// Copied from [seriesBooks].
  SeriesBooksProvider call(String sourceId, String seriesId) {
    return SeriesBooksProvider(sourceId, seriesId);
  }

  @override
  SeriesBooksProvider getProviderOverride(
    covariant SeriesBooksProvider provider,
  ) {
    return call(provider.sourceId, provider.seriesId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'seriesBooksProvider';
}

/// A series' books, streamed from the cache. Kicks an online refresh first.
///
/// Copied from [seriesBooks].
class SeriesBooksProvider extends AutoDisposeStreamProvider<List<Book>> {
  /// A series' books, streamed from the cache. Kicks an online refresh first.
  ///
  /// Copied from [seriesBooks].
  SeriesBooksProvider(String sourceId, String seriesId)
    : this._internal(
        (ref) => seriesBooks(ref as SeriesBooksRef, sourceId, seriesId),
        from: seriesBooksProvider,
        name: r'seriesBooksProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$seriesBooksHash,
        dependencies: SeriesBooksFamily._dependencies,
        allTransitiveDependencies: SeriesBooksFamily._allTransitiveDependencies,
        sourceId: sourceId,
        seriesId: seriesId,
      );

  SeriesBooksProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.sourceId,
    required this.seriesId,
  }) : super.internal();

  final String sourceId;
  final String seriesId;

  @override
  Override overrideWith(
    Stream<List<Book>> Function(SeriesBooksRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SeriesBooksProvider._internal(
        (ref) => create(ref as SeriesBooksRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        sourceId: sourceId,
        seriesId: seriesId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Book>> createElement() {
    return _SeriesBooksProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SeriesBooksProvider &&
        other.sourceId == sourceId &&
        other.seriesId == seriesId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, sourceId.hashCode);
    hash = _SystemHash.combine(hash, seriesId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SeriesBooksRef on AutoDisposeStreamProviderRef<List<Book>> {
  /// The parameter `sourceId` of this provider.
  String get sourceId;

  /// The parameter `seriesId` of this provider.
  String get seriesId;
}

class _SeriesBooksProviderElement
    extends AutoDisposeStreamProviderElement<List<Book>>
    with SeriesBooksRef {
  _SeriesBooksProviderElement(super.provider);

  @override
  String get sourceId => (origin as SeriesBooksProvider).sourceId;
  @override
  String get seriesId => (origin as SeriesBooksProvider).seriesId;
}

String _$seriesDetailHash() => r'4dcac94b2b225b2578b112fa2dcee9c5b5262f6f';

/// A single cached series row (for the series-detail header).
///
/// Copied from [seriesDetail].
@ProviderFor(seriesDetail)
const seriesDetailProvider = SeriesDetailFamily();

/// A single cached series row (for the series-detail header).
///
/// Copied from [seriesDetail].
class SeriesDetailFamily extends Family<AsyncValue<SeriesRow?>> {
  /// A single cached series row (for the series-detail header).
  ///
  /// Copied from [seriesDetail].
  const SeriesDetailFamily();

  /// A single cached series row (for the series-detail header).
  ///
  /// Copied from [seriesDetail].
  SeriesDetailProvider call(String sourceId, String seriesId) {
    return SeriesDetailProvider(sourceId, seriesId);
  }

  @override
  SeriesDetailProvider getProviderOverride(
    covariant SeriesDetailProvider provider,
  ) {
    return call(provider.sourceId, provider.seriesId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'seriesDetailProvider';
}

/// A single cached series row (for the series-detail header).
///
/// Copied from [seriesDetail].
class SeriesDetailProvider extends AutoDisposeFutureProvider<SeriesRow?> {
  /// A single cached series row (for the series-detail header).
  ///
  /// Copied from [seriesDetail].
  SeriesDetailProvider(String sourceId, String seriesId)
    : this._internal(
        (ref) => seriesDetail(ref as SeriesDetailRef, sourceId, seriesId),
        from: seriesDetailProvider,
        name: r'seriesDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$seriesDetailHash,
        dependencies: SeriesDetailFamily._dependencies,
        allTransitiveDependencies:
            SeriesDetailFamily._allTransitiveDependencies,
        sourceId: sourceId,
        seriesId: seriesId,
      );

  SeriesDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.sourceId,
    required this.seriesId,
  }) : super.internal();

  final String sourceId;
  final String seriesId;

  @override
  Override overrideWith(
    FutureOr<SeriesRow?> Function(SeriesDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SeriesDetailProvider._internal(
        (ref) => create(ref as SeriesDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        sourceId: sourceId,
        seriesId: seriesId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<SeriesRow?> createElement() {
    return _SeriesDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SeriesDetailProvider &&
        other.sourceId == sourceId &&
        other.seriesId == seriesId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, sourceId.hashCode);
    hash = _SystemHash.combine(hash, seriesId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SeriesDetailRef on AutoDisposeFutureProviderRef<SeriesRow?> {
  /// The parameter `sourceId` of this provider.
  String get sourceId;

  /// The parameter `seriesId` of this provider.
  String get seriesId;
}

class _SeriesDetailProviderElement
    extends AutoDisposeFutureProviderElement<SeriesRow?>
    with SeriesDetailRef {
  _SeriesDetailProviderElement(super.provider);

  @override
  String get sourceId => (origin as SeriesDetailProvider).sourceId;
  @override
  String get seriesId => (origin as SeriesDetailProvider).seriesId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
