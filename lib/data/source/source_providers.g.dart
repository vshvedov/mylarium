// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'source_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sourcesStreamHash() => r'b5b8eccf6a8e004066710c1bdc08eebc72a8a366';

/// All connected sources, reactive. Drives source-aware UI and invalidation:
/// deleting a source rebuilds [contentApiFor].
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
String _$contentApiForHash() => r'223e04df2d8d2e888c8fcd026c49142dd2db7bb6';

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

/// Builds an authenticated [ContentApi] for [sourceId], dispatching on the
/// source `kind` to the matching backend (Komga or Kavita), or null when the
/// source row is missing, has no baseUrl, has no stored credential, or is a kind
/// without a remote client (graceful degradation). Watches [sourcesStream] so a
/// deleted source invalidates the cached client.
///
/// Copied from [contentApiFor].
@ProviderFor(contentApiFor)
const contentApiForProvider = ContentApiForFamily();

/// Builds an authenticated [ContentApi] for [sourceId], dispatching on the
/// source `kind` to the matching backend (Komga or Kavita), or null when the
/// source row is missing, has no baseUrl, has no stored credential, or is a kind
/// without a remote client (graceful degradation). Watches [sourcesStream] so a
/// deleted source invalidates the cached client.
///
/// Copied from [contentApiFor].
class ContentApiForFamily extends Family<AsyncValue<ContentApi?>> {
  /// Builds an authenticated [ContentApi] for [sourceId], dispatching on the
  /// source `kind` to the matching backend (Komga or Kavita), or null when the
  /// source row is missing, has no baseUrl, has no stored credential, or is a kind
  /// without a remote client (graceful degradation). Watches [sourcesStream] so a
  /// deleted source invalidates the cached client.
  ///
  /// Copied from [contentApiFor].
  const ContentApiForFamily();

  /// Builds an authenticated [ContentApi] for [sourceId], dispatching on the
  /// source `kind` to the matching backend (Komga or Kavita), or null when the
  /// source row is missing, has no baseUrl, has no stored credential, or is a kind
  /// without a remote client (graceful degradation). Watches [sourcesStream] so a
  /// deleted source invalidates the cached client.
  ///
  /// Copied from [contentApiFor].
  ContentApiForProvider call(String sourceId) {
    return ContentApiForProvider(sourceId);
  }

  @override
  ContentApiForProvider getProviderOverride(
    covariant ContentApiForProvider provider,
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
  String? get name => r'contentApiForProvider';
}

/// Builds an authenticated [ContentApi] for [sourceId], dispatching on the
/// source `kind` to the matching backend (Komga or Kavita), or null when the
/// source row is missing, has no baseUrl, has no stored credential, or is a kind
/// without a remote client (graceful degradation). Watches [sourcesStream] so a
/// deleted source invalidates the cached client.
///
/// Copied from [contentApiFor].
class ContentApiForProvider extends AutoDisposeFutureProvider<ContentApi?> {
  /// Builds an authenticated [ContentApi] for [sourceId], dispatching on the
  /// source `kind` to the matching backend (Komga or Kavita), or null when the
  /// source row is missing, has no baseUrl, has no stored credential, or is a kind
  /// without a remote client (graceful degradation). Watches [sourcesStream] so a
  /// deleted source invalidates the cached client.
  ///
  /// Copied from [contentApiFor].
  ContentApiForProvider(String sourceId)
    : this._internal(
        (ref) => contentApiFor(ref as ContentApiForRef, sourceId),
        from: contentApiForProvider,
        name: r'contentApiForProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$contentApiForHash,
        dependencies: ContentApiForFamily._dependencies,
        allTransitiveDependencies:
            ContentApiForFamily._allTransitiveDependencies,
        sourceId: sourceId,
      );

  ContentApiForProvider._internal(
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
    FutureOr<ContentApi?> Function(ContentApiForRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ContentApiForProvider._internal(
        (ref) => create(ref as ContentApiForRef),
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
  AutoDisposeFutureProviderElement<ContentApi?> createElement() {
    return _ContentApiForProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ContentApiForProvider && other.sourceId == sourceId;
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
mixin ContentApiForRef on AutoDisposeFutureProviderRef<ContentApi?> {
  /// The parameter `sourceId` of this provider.
  String get sourceId;
}

class _ContentApiForProviderElement
    extends AutoDisposeFutureProviderElement<ContentApi?>
    with ContentApiForRef {
  _ContentApiForProviderElement(super.provider);

  @override
  String get sourceId => (origin as ContentApiForProvider).sourceId;
}

String _$activeContentApiHash() => r'2dd10cb453b3e251addde6bd48ac5f8f8cf7f761';

/// The [ContentApi] for the active source, or null when there is no active
/// source.
///
/// Copied from [activeContentApi].
@ProviderFor(activeContentApi)
final activeContentApiProvider =
    AutoDisposeFutureProvider<ContentApi?>.internal(
      activeContentApi,
      name: r'activeContentApiProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$activeContentApiHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveContentApiRef = AutoDisposeFutureProviderRef<ContentApi?>;
String _$seriesRepositoryHash() => r'8e86e09c262714a84814b2f9ed9248cde9250bd1';

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
String _$bookRepositoryHash() => r'f1eb420f8683439f95669d642959efb7531fe0f7';

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
String _$libraryRepositoryHash() => r'73c4c94e2f5e097055adba19c9dd061ff94b4183';

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
String _$searchRepositoryHash() => r'3efa46e86ac9a59ce91b8adf52d626d6af3fa6fe';

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
    r'0183786e0ad466f7ca32057b597577fec2e8f4d1';

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
    r'15e0c681e4ecb0855ab8bc44aba635cdc02edbd1';

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

/// The currently selected source id. With one source, `build` deterministically
/// picks the lowest source id (sorted); [select] switches the active source
/// (used by the sources screen). Remembering the last-active source across
/// restarts is a follow-up.
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
