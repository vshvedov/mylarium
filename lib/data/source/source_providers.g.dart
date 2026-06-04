// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'source_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sourcesStreamHash() => r'b5b8eccf6a8e004066710c1bdc08eebc72a8a366';

/// All connected sources, reactive. Drives source-aware UI and invalidation:
/// deleting a source rebuilds [komgaApiFor].
///
/// Copied from [sourcesStream].
@ProviderFor(sourcesStream)
final sourcesStreamProvider = AutoDisposeStreamProvider<List<Source>>.internal(
  sourcesStream,
  name: r'sourcesStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sourcesStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SourcesStreamRef = AutoDisposeStreamProviderRef<List<Source>>;
String _$komgaApiForHash() => r'f1e97d5c51b1bbbc4213c275c7285ea058e38ff9';

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

/// Builds an authenticated [KomgaApi] for [sourceId], or null when the source
/// row is missing, is not a Komga source, has no baseUrl, or has no stored
/// credential (graceful degradation). Watches [sourcesStream] so a deleted
/// source invalidates the cached client.
///
/// Copied from [komgaApiFor].
@ProviderFor(komgaApiFor)
const komgaApiForProvider = KomgaApiForFamily();

/// Builds an authenticated [KomgaApi] for [sourceId], or null when the source
/// row is missing, is not a Komga source, has no baseUrl, or has no stored
/// credential (graceful degradation). Watches [sourcesStream] so a deleted
/// source invalidates the cached client.
///
/// Copied from [komgaApiFor].
class KomgaApiForFamily extends Family<AsyncValue<KomgaApi?>> {
  /// Builds an authenticated [KomgaApi] for [sourceId], or null when the source
  /// row is missing, is not a Komga source, has no baseUrl, or has no stored
  /// credential (graceful degradation). Watches [sourcesStream] so a deleted
  /// source invalidates the cached client.
  ///
  /// Copied from [komgaApiFor].
  const KomgaApiForFamily();

  /// Builds an authenticated [KomgaApi] for [sourceId], or null when the source
  /// row is missing, is not a Komga source, has no baseUrl, or has no stored
  /// credential (graceful degradation). Watches [sourcesStream] so a deleted
  /// source invalidates the cached client.
  ///
  /// Copied from [komgaApiFor].
  KomgaApiForProvider call(String sourceId) {
    return KomgaApiForProvider(sourceId);
  }

  @override
  KomgaApiForProvider getProviderOverride(
    covariant KomgaApiForProvider provider,
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
  String? get name => r'komgaApiForProvider';
}

/// Builds an authenticated [KomgaApi] for [sourceId], or null when the source
/// row is missing, is not a Komga source, has no baseUrl, or has no stored
/// credential (graceful degradation). Watches [sourcesStream] so a deleted
/// source invalidates the cached client.
///
/// Copied from [komgaApiFor].
class KomgaApiForProvider extends AutoDisposeFutureProvider<KomgaApi?> {
  /// Builds an authenticated [KomgaApi] for [sourceId], or null when the source
  /// row is missing, is not a Komga source, has no baseUrl, or has no stored
  /// credential (graceful degradation). Watches [sourcesStream] so a deleted
  /// source invalidates the cached client.
  ///
  /// Copied from [komgaApiFor].
  KomgaApiForProvider(String sourceId)
    : this._internal(
        (ref) => komgaApiFor(ref as KomgaApiForRef, sourceId),
        from: komgaApiForProvider,
        name: r'komgaApiForProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$komgaApiForHash,
        dependencies: KomgaApiForFamily._dependencies,
        allTransitiveDependencies: KomgaApiForFamily._allTransitiveDependencies,
        sourceId: sourceId,
      );

  KomgaApiForProvider._internal(
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
    FutureOr<KomgaApi?> Function(KomgaApiForRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: KomgaApiForProvider._internal(
        (ref) => create(ref as KomgaApiForRef),
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
  AutoDisposeFutureProviderElement<KomgaApi?> createElement() {
    return _KomgaApiForProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is KomgaApiForProvider && other.sourceId == sourceId;
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
mixin KomgaApiForRef on AutoDisposeFutureProviderRef<KomgaApi?> {
  /// The parameter `sourceId` of this provider.
  String get sourceId;
}

class _KomgaApiForProviderElement
    extends AutoDisposeFutureProviderElement<KomgaApi?>
    with KomgaApiForRef {
  _KomgaApiForProviderElement(super.provider);

  @override
  String get sourceId => (origin as KomgaApiForProvider).sourceId;
}

String _$activeKomgaApiHash() => r'6bcb6439c8f0a183a26a71f65e6abc944fefce43';

/// The [KomgaApi] for the active source, or null when there is no active source.
///
/// Copied from [activeKomgaApi].
@ProviderFor(activeKomgaApi)
final activeKomgaApiProvider = AutoDisposeFutureProvider<KomgaApi?>.internal(
  activeKomgaApi,
  name: r'activeKomgaApiProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeKomgaApiHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveKomgaApiRef = AutoDisposeFutureProviderRef<KomgaApi?>;
String _$seriesRepositoryHash() => r'c20f456598318b2991d79578b946eebc872bb09a';

/// See also [seriesRepository].
@ProviderFor(seriesRepository)
final seriesRepositoryProvider =
    AutoDisposeFutureProvider<SeriesRepository?>.internal(
      seriesRepository,
      name: r'seriesRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$seriesRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SeriesRepositoryRef = AutoDisposeFutureProviderRef<SeriesRepository?>;
String _$bookRepositoryHash() => r'fd1dbfed2c48cacf34510612640e5dd6de5f0939';

/// See also [bookRepository].
@ProviderFor(bookRepository)
final bookRepositoryProvider =
    AutoDisposeFutureProvider<BookRepository?>.internal(
      bookRepository,
      name: r'bookRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$bookRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BookRepositoryRef = AutoDisposeFutureProviderRef<BookRepository?>;
String _$libraryRepositoryHash() => r'79714b0d4271313b300a2e731f98202be26ee50c';

/// See also [libraryRepository].
@ProviderFor(libraryRepository)
final libraryRepositoryProvider =
    AutoDisposeFutureProvider<LibraryRepository?>.internal(
      libraryRepository,
      name: r'libraryRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$libraryRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LibraryRepositoryRef = AutoDisposeFutureProviderRef<LibraryRepository?>;
String _$searchRepositoryHash() => r'f379fccf0bae136ad296f07fc60b90c9d86a481b';

/// See also [searchRepository].
@ProviderFor(searchRepository)
final searchRepositoryProvider =
    AutoDisposeFutureProvider<SearchRepository?>.internal(
      searchRepository,
      name: r'searchRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$searchRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SearchRepositoryRef = AutoDisposeFutureProviderRef<SearchRepository?>;
String _$collectionRepositoryHash() =>
    r'391c1a285ceaeed7ca5a8a2619c9b28ce99613bd';

/// See also [collectionRepository].
@ProviderFor(collectionRepository)
final collectionRepositoryProvider =
    AutoDisposeFutureProvider<CollectionRepository?>.internal(
      collectionRepository,
      name: r'collectionRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$collectionRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CollectionRepositoryRef =
    AutoDisposeFutureProviderRef<CollectionRepository?>;
String _$readListRepositoryHash() =>
    r'56a3e75755bf64155ed98b72dab0cf67a76d3010';

/// See also [readListRepository].
@ProviderFor(readListRepository)
final readListRepositoryProvider =
    AutoDisposeFutureProvider<ReadListRepository?>.internal(
      readListRepository,
      name: r'readListRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$readListRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ReadListRepositoryRef =
    AutoDisposeFutureProviderRef<ReadListRepository?>;
String _$activeSourceIdHash() => r'22b7f3722b966f67b2cb8e7d86c30245a854c22d';

/// The currently selected source id. Phase 1 ships a single Komga server, so
/// `build` deterministically picks the lowest source id (sorted), or null when
/// none. Remembering the last-active source across restarts is a follow-up.
///
/// Copied from [ActiveSourceId].
@ProviderFor(ActiveSourceId)
final activeSourceIdProvider =
    AsyncNotifierProvider<ActiveSourceId, String?>.internal(
      ActiveSourceId.new,
      name: r'activeSourceIdProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$activeSourceIdHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ActiveSourceId = AsyncNotifier<String?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
