// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_browse_controllers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$keepReadingHash() => r'c0f42a37cb39c1a08362a9ebb3a6bd1fd14e657b';

/// Keep-reading books for the active source: the user's in-progress books first
/// (most recently read), then on-deck (the next book in a series with a
/// completed book) appended and de-duplicated. NOT age-gated (the user's own
/// reading). Komga's `/books/ondeck` alone only surfaces next-after-completed,
/// so a reader mid-book would see an empty rail; the in-progress query fixes it.
///
/// Copied from [keepReading].
@ProviderFor(keepReading)
final keepReadingProvider = AutoDisposeFutureProvider<List<BookDto>>.internal(
  keepReading,
  name: r'keepReadingProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$keepReadingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef KeepReadingRef = AutoDisposeFutureProviderRef<List<BookDto>>;
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

String _$bookReadStateHash() => r'78bc6891265f1b93941d8338d9107b90c8784550';

/// The book's local read state (the authoritative source for the completed
/// badge and percent; survives a Books-cache refresh).
///
/// Copied from [bookReadState].
@ProviderFor(bookReadState)
const bookReadStateProvider = BookReadStateFamily();

/// The book's local read state (the authoritative source for the completed
/// badge and percent; survives a Books-cache refresh).
///
/// Copied from [bookReadState].
class BookReadStateFamily extends Family<AsyncValue<BookStateRow?>> {
  /// The book's local read state (the authoritative source for the completed
  /// badge and percent; survives a Books-cache refresh).
  ///
  /// Copied from [bookReadState].
  const BookReadStateFamily();

  /// The book's local read state (the authoritative source for the completed
  /// badge and percent; survives a Books-cache refresh).
  ///
  /// Copied from [bookReadState].
  BookReadStateProvider call(String sourceId, String bookId) {
    return BookReadStateProvider(sourceId, bookId);
  }

  @override
  BookReadStateProvider getProviderOverride(
    covariant BookReadStateProvider provider,
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
  String? get name => r'bookReadStateProvider';
}

/// The book's local read state (the authoritative source for the completed
/// badge and percent; survives a Books-cache refresh).
///
/// Copied from [bookReadState].
class BookReadStateProvider extends AutoDisposeStreamProvider<BookStateRow?> {
  /// The book's local read state (the authoritative source for the completed
  /// badge and percent; survives a Books-cache refresh).
  ///
  /// Copied from [bookReadState].
  BookReadStateProvider(String sourceId, String bookId)
    : this._internal(
        (ref) => bookReadState(ref as BookReadStateRef, sourceId, bookId),
        from: bookReadStateProvider,
        name: r'bookReadStateProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$bookReadStateHash,
        dependencies: BookReadStateFamily._dependencies,
        allTransitiveDependencies:
            BookReadStateFamily._allTransitiveDependencies,
        sourceId: sourceId,
        bookId: bookId,
      );

  BookReadStateProvider._internal(
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
    Stream<BookStateRow?> Function(BookReadStateRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: BookReadStateProvider._internal(
        (ref) => create(ref as BookReadStateRef),
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
  AutoDisposeStreamProviderElement<BookStateRow?> createElement() {
    return _BookReadStateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BookReadStateProvider &&
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
mixin BookReadStateRef on AutoDisposeStreamProviderRef<BookStateRow?> {
  /// The parameter `sourceId` of this provider.
  String get sourceId;

  /// The parameter `bookId` of this provider.
  String get bookId;
}

class _BookReadStateProviderElement
    extends AutoDisposeStreamProviderElement<BookStateRow?>
    with BookReadStateRef {
  _BookReadStateProviderElement(super.provider);

  @override
  String get sourceId => (origin as BookReadStateProvider).sourceId;
  @override
  String get bookId => (origin as BookReadStateProvider).bookId;
}

String _$seriesReadStatesHash() => r'0a21e8bfe18337b1834dd24fc28585e7d40cd92f';

/// The local read state of every book of a series that has one, for the series
/// grid badges (books without a row fall back to the cached `Books.completed`).
///
/// Copied from [seriesReadStates].
@ProviderFor(seriesReadStates)
const seriesReadStatesProvider = SeriesReadStatesFamily();

/// The local read state of every book of a series that has one, for the series
/// grid badges (books without a row fall back to the cached `Books.completed`).
///
/// Copied from [seriesReadStates].
class SeriesReadStatesFamily extends Family<AsyncValue<List<BookStateRow>>> {
  /// The local read state of every book of a series that has one, for the series
  /// grid badges (books without a row fall back to the cached `Books.completed`).
  ///
  /// Copied from [seriesReadStates].
  const SeriesReadStatesFamily();

  /// The local read state of every book of a series that has one, for the series
  /// grid badges (books without a row fall back to the cached `Books.completed`).
  ///
  /// Copied from [seriesReadStates].
  SeriesReadStatesProvider call(String sourceId, String seriesId) {
    return SeriesReadStatesProvider(sourceId, seriesId);
  }

  @override
  SeriesReadStatesProvider getProviderOverride(
    covariant SeriesReadStatesProvider provider,
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
  String? get name => r'seriesReadStatesProvider';
}

/// The local read state of every book of a series that has one, for the series
/// grid badges (books without a row fall back to the cached `Books.completed`).
///
/// Copied from [seriesReadStates].
class SeriesReadStatesProvider
    extends AutoDisposeStreamProvider<List<BookStateRow>> {
  /// The local read state of every book of a series that has one, for the series
  /// grid badges (books without a row fall back to the cached `Books.completed`).
  ///
  /// Copied from [seriesReadStates].
  SeriesReadStatesProvider(String sourceId, String seriesId)
    : this._internal(
        (ref) =>
            seriesReadStates(ref as SeriesReadStatesRef, sourceId, seriesId),
        from: seriesReadStatesProvider,
        name: r'seriesReadStatesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$seriesReadStatesHash,
        dependencies: SeriesReadStatesFamily._dependencies,
        allTransitiveDependencies:
            SeriesReadStatesFamily._allTransitiveDependencies,
        sourceId: sourceId,
        seriesId: seriesId,
      );

  SeriesReadStatesProvider._internal(
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
    Stream<List<BookStateRow>> Function(SeriesReadStatesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SeriesReadStatesProvider._internal(
        (ref) => create(ref as SeriesReadStatesRef),
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
  AutoDisposeStreamProviderElement<List<BookStateRow>> createElement() {
    return _SeriesReadStatesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SeriesReadStatesProvider &&
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
mixin SeriesReadStatesRef on AutoDisposeStreamProviderRef<List<BookStateRow>> {
  /// The parameter `sourceId` of this provider.
  String get sourceId;

  /// The parameter `seriesId` of this provider.
  String get seriesId;
}

class _SeriesReadStatesProviderElement
    extends AutoDisposeStreamProviderElement<List<BookStateRow>>
    with SeriesReadStatesRef {
  _SeriesReadStatesProviderElement(super.provider);

  @override
  String get sourceId => (origin as SeriesReadStatesProvider).sourceId;
  @override
  String get seriesId => (origin as SeriesReadStatesProvider).seriesId;
}

String _$bookDetailDtoHash() => r'fec150c9ea385d69f39f6f40d624f1e1a4d83b6c';

/// The live Komga book, fetched for the richer detail metadata. Null offline
/// (the screen falls back to the cached row).
///
/// Copied from [bookDetailDto].
@ProviderFor(bookDetailDto)
const bookDetailDtoProvider = BookDetailDtoFamily();

/// The live Komga book, fetched for the richer detail metadata. Null offline
/// (the screen falls back to the cached row).
///
/// Copied from [bookDetailDto].
class BookDetailDtoFamily extends Family<AsyncValue<BookDto?>> {
  /// The live Komga book, fetched for the richer detail metadata. Null offline
  /// (the screen falls back to the cached row).
  ///
  /// Copied from [bookDetailDto].
  const BookDetailDtoFamily();

  /// The live Komga book, fetched for the richer detail metadata. Null offline
  /// (the screen falls back to the cached row).
  ///
  /// Copied from [bookDetailDto].
  BookDetailDtoProvider call(String sourceId, String bookId) {
    return BookDetailDtoProvider(sourceId, bookId);
  }

  @override
  BookDetailDtoProvider getProviderOverride(
    covariant BookDetailDtoProvider provider,
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
  String? get name => r'bookDetailDtoProvider';
}

/// The live Komga book, fetched for the richer detail metadata. Null offline
/// (the screen falls back to the cached row).
///
/// Copied from [bookDetailDto].
class BookDetailDtoProvider extends AutoDisposeFutureProvider<BookDto?> {
  /// The live Komga book, fetched for the richer detail metadata. Null offline
  /// (the screen falls back to the cached row).
  ///
  /// Copied from [bookDetailDto].
  BookDetailDtoProvider(String sourceId, String bookId)
    : this._internal(
        (ref) => bookDetailDto(ref as BookDetailDtoRef, sourceId, bookId),
        from: bookDetailDtoProvider,
        name: r'bookDetailDtoProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$bookDetailDtoHash,
        dependencies: BookDetailDtoFamily._dependencies,
        allTransitiveDependencies:
            BookDetailDtoFamily._allTransitiveDependencies,
        sourceId: sourceId,
        bookId: bookId,
      );

  BookDetailDtoProvider._internal(
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
    FutureOr<BookDto?> Function(BookDetailDtoRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: BookDetailDtoProvider._internal(
        (ref) => create(ref as BookDetailDtoRef),
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
  AutoDisposeFutureProviderElement<BookDto?> createElement() {
    return _BookDetailDtoProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BookDetailDtoProvider &&
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
mixin BookDetailDtoRef on AutoDisposeFutureProviderRef<BookDto?> {
  /// The parameter `sourceId` of this provider.
  String get sourceId;

  /// The parameter `bookId` of this provider.
  String get bookId;
}

class _BookDetailDtoProviderElement
    extends AutoDisposeFutureProviderElement<BookDto?>
    with BookDetailDtoRef {
  _BookDetailDtoProviderElement(super.provider);

  @override
  String get sourceId => (origin as BookDetailDtoProvider).sourceId;
  @override
  String get bookId => (origin as BookDetailDtoProvider).bookId;
}

String _$seriesDetailDtoHash() => r'e3f67db35e441a4b194fbe3b21139cec5d4a75cc';

/// The live Komga series, fetched for the richer detail metadata. Null offline.
///
/// Copied from [seriesDetailDto].
@ProviderFor(seriesDetailDto)
const seriesDetailDtoProvider = SeriesDetailDtoFamily();

/// The live Komga series, fetched for the richer detail metadata. Null offline.
///
/// Copied from [seriesDetailDto].
class SeriesDetailDtoFamily extends Family<AsyncValue<SeriesDto?>> {
  /// The live Komga series, fetched for the richer detail metadata. Null offline.
  ///
  /// Copied from [seriesDetailDto].
  const SeriesDetailDtoFamily();

  /// The live Komga series, fetched for the richer detail metadata. Null offline.
  ///
  /// Copied from [seriesDetailDto].
  SeriesDetailDtoProvider call(String sourceId, String seriesId) {
    return SeriesDetailDtoProvider(sourceId, seriesId);
  }

  @override
  SeriesDetailDtoProvider getProviderOverride(
    covariant SeriesDetailDtoProvider provider,
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
  String? get name => r'seriesDetailDtoProvider';
}

/// The live Komga series, fetched for the richer detail metadata. Null offline.
///
/// Copied from [seriesDetailDto].
class SeriesDetailDtoProvider extends AutoDisposeFutureProvider<SeriesDto?> {
  /// The live Komga series, fetched for the richer detail metadata. Null offline.
  ///
  /// Copied from [seriesDetailDto].
  SeriesDetailDtoProvider(String sourceId, String seriesId)
    : this._internal(
        (ref) => seriesDetailDto(ref as SeriesDetailDtoRef, sourceId, seriesId),
        from: seriesDetailDtoProvider,
        name: r'seriesDetailDtoProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$seriesDetailDtoHash,
        dependencies: SeriesDetailDtoFamily._dependencies,
        allTransitiveDependencies:
            SeriesDetailDtoFamily._allTransitiveDependencies,
        sourceId: sourceId,
        seriesId: seriesId,
      );

  SeriesDetailDtoProvider._internal(
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
    FutureOr<SeriesDto?> Function(SeriesDetailDtoRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SeriesDetailDtoProvider._internal(
        (ref) => create(ref as SeriesDetailDtoRef),
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
  AutoDisposeFutureProviderElement<SeriesDto?> createElement() {
    return _SeriesDetailDtoProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SeriesDetailDtoProvider &&
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
mixin SeriesDetailDtoRef on AutoDisposeFutureProviderRef<SeriesDto?> {
  /// The parameter `sourceId` of this provider.
  String get sourceId;

  /// The parameter `seriesId` of this provider.
  String get seriesId;
}

class _SeriesDetailDtoProviderElement
    extends AutoDisposeFutureProviderElement<SeriesDto?>
    with SeriesDetailDtoRef {
  _SeriesDetailDtoProviderElement(super.provider);

  @override
  String get sourceId => (origin as SeriesDetailDtoProvider).sourceId;
  @override
  String get seriesId => (origin as SeriesDetailDtoProvider).seriesId;
}

String _$bookRatingHash() => r'32b19f7d04bad4176f58de2a93c9247d051a30ec';

/// The local star rating for a book (null when unset).
///
/// Copied from [bookRating].
@ProviderFor(bookRating)
const bookRatingProvider = BookRatingFamily();

/// The local star rating for a book (null when unset).
///
/// Copied from [bookRating].
class BookRatingFamily extends Family<AsyncValue<int?>> {
  /// The local star rating for a book (null when unset).
  ///
  /// Copied from [bookRating].
  const BookRatingFamily();

  /// The local star rating for a book (null when unset).
  ///
  /// Copied from [bookRating].
  BookRatingProvider call(String sourceId, String bookId) {
    return BookRatingProvider(sourceId, bookId);
  }

  @override
  BookRatingProvider getProviderOverride(
    covariant BookRatingProvider provider,
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
  String? get name => r'bookRatingProvider';
}

/// The local star rating for a book (null when unset).
///
/// Copied from [bookRating].
class BookRatingProvider extends AutoDisposeFutureProvider<int?> {
  /// The local star rating for a book (null when unset).
  ///
  /// Copied from [bookRating].
  BookRatingProvider(String sourceId, String bookId)
    : this._internal(
        (ref) => bookRating(ref as BookRatingRef, sourceId, bookId),
        from: bookRatingProvider,
        name: r'bookRatingProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$bookRatingHash,
        dependencies: BookRatingFamily._dependencies,
        allTransitiveDependencies: BookRatingFamily._allTransitiveDependencies,
        sourceId: sourceId,
        bookId: bookId,
      );

  BookRatingProvider._internal(
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
    FutureOr<int?> Function(BookRatingRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: BookRatingProvider._internal(
        (ref) => create(ref as BookRatingRef),
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
    return _BookRatingProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BookRatingProvider &&
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
mixin BookRatingRef on AutoDisposeFutureProviderRef<int?> {
  /// The parameter `sourceId` of this provider.
  String get sourceId;

  /// The parameter `bookId` of this provider.
  String get bookId;
}

class _BookRatingProviderElement extends AutoDisposeFutureProviderElement<int?>
    with BookRatingRef {
  _BookRatingProviderElement(super.provider);

  @override
  String get sourceId => (origin as BookRatingProvider).sourceId;
  @override
  String get bookId => (origin as BookRatingProvider).bookId;
}

String _$seriesRatingHash() => r'fec984f6fed7dd424a6cf256593665a87a1b6909';

/// The local star rating for a series (null when unset).
///
/// Copied from [seriesRating].
@ProviderFor(seriesRating)
const seriesRatingProvider = SeriesRatingFamily();

/// The local star rating for a series (null when unset).
///
/// Copied from [seriesRating].
class SeriesRatingFamily extends Family<AsyncValue<int?>> {
  /// The local star rating for a series (null when unset).
  ///
  /// Copied from [seriesRating].
  const SeriesRatingFamily();

  /// The local star rating for a series (null when unset).
  ///
  /// Copied from [seriesRating].
  SeriesRatingProvider call(String sourceId, String seriesId) {
    return SeriesRatingProvider(sourceId, seriesId);
  }

  @override
  SeriesRatingProvider getProviderOverride(
    covariant SeriesRatingProvider provider,
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
  String? get name => r'seriesRatingProvider';
}

/// The local star rating for a series (null when unset).
///
/// Copied from [seriesRating].
class SeriesRatingProvider extends AutoDisposeFutureProvider<int?> {
  /// The local star rating for a series (null when unset).
  ///
  /// Copied from [seriesRating].
  SeriesRatingProvider(String sourceId, String seriesId)
    : this._internal(
        (ref) => seriesRating(ref as SeriesRatingRef, sourceId, seriesId),
        from: seriesRatingProvider,
        name: r'seriesRatingProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$seriesRatingHash,
        dependencies: SeriesRatingFamily._dependencies,
        allTransitiveDependencies:
            SeriesRatingFamily._allTransitiveDependencies,
        sourceId: sourceId,
        seriesId: seriesId,
      );

  SeriesRatingProvider._internal(
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
    FutureOr<int?> Function(SeriesRatingRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SeriesRatingProvider._internal(
        (ref) => create(ref as SeriesRatingRef),
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
  AutoDisposeFutureProviderElement<int?> createElement() {
    return _SeriesRatingProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SeriesRatingProvider &&
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
mixin SeriesRatingRef on AutoDisposeFutureProviderRef<int?> {
  /// The parameter `sourceId` of this provider.
  String get sourceId;

  /// The parameter `seriesId` of this provider.
  String get seriesId;
}

class _SeriesRatingProviderElement
    extends AutoDisposeFutureProviderElement<int?>
    with SeriesRatingRef {
  _SeriesRatingProviderElement(super.provider);

  @override
  String get sourceId => (origin as SeriesRatingProvider).sourceId;
  @override
  String get seriesId => (origin as SeriesRatingProvider).seriesId;
}

String _$genresHash() => r'571f4d16453a3fd1a1cbb9ed9937de0f6285f2a6';

/// All genres on the active source (filter chips). Empty on any error/offline.
///
/// Copied from [genres].
@ProviderFor(genres)
final genresProvider = AutoDisposeFutureProvider<List<String>>.internal(
  genres,
  name: r'genresProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$genresHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GenresRef = AutoDisposeFutureProviderRef<List<String>>;
String _$tagsHash() => r'58f3888bca51cd8c5445b94d55b46d854f401da2';

/// All tags on the active source (filter chips). Empty on any error/offline.
///
/// Copied from [tags].
@ProviderFor(tags)
final tagsProvider = AutoDisposeFutureProvider<List<String>>.internal(
  tags,
  name: r'tagsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tagsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TagsRef = AutoDisposeFutureProviderRef<List<String>>;
String _$publishersHash() => r'a5fd0bb20933bf87ceea34117cb8582e85615f82';

/// All publishers on the active source (filter chips). Empty on error/offline.
///
/// Copied from [publishers].
@ProviderFor(publishers)
final publishersProvider = AutoDisposeFutureProvider<List<String>>.internal(
  publishers,
  name: r'publishersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$publishersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PublishersRef = AutoDisposeFutureProviderRef<List<String>>;
String _$ageRatingsHash() => r'3de9a70b697dfdb473ae660f2206b286716b6470';

/// Age ratings present on the active source (filter chips). Empty hides the
/// group (there is no fixed Komga age ladder).
///
/// Copied from [ageRatings].
@ProviderFor(ageRatings)
final ageRatingsProvider = AutoDisposeFutureProvider<List<int>>.internal(
  ageRatings,
  name: r'ageRatingsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$ageRatingsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AgeRatingsRef = AutoDisposeFutureProviderRef<List<int>>;
String _$seriesDetailHash() => r'c9797d90c42c1fe1dc0605888766db37189b987f';

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
