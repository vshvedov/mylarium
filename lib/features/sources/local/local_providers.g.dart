// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$importServiceHash() => r'3fac531e742edb89374bf9ab76f6245e97a4fa34';

/// The import pipeline for the Local files source (copy-on-import).
///
/// Copied from [importService].
@ProviderFor(importService)
final importServiceProvider = AutoDisposeProvider<ImportService>.internal(
  importService,
  name: r'importServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$importServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ImportServiceRef = AutoDisposeProviderRef<ImportService>;
String _$localComicsRepositoryHash() =>
    r'f898b3cf17b0855c317c9be70a07659a84936e28';

/// Read-side access to local comics (series grouping, books, single book).
///
/// Copied from [localComicsRepository].
@ProviderFor(localComicsRepository)
final localComicsRepositoryProvider =
    AutoDisposeProvider<LocalComicsRepository>.internal(
      localComicsRepository,
      name: r'localComicsRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$localComicsRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LocalComicsRepositoryRef =
    AutoDisposeProviderRef<LocalComicsRepository>;
String _$localSeriesHash() => r'329e8cc8c4d09b9cb84283bf8ccd3e56a4db717e';

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

/// The local series grid for one source.
///
/// Copied from [localSeries].
@ProviderFor(localSeries)
const localSeriesProvider = LocalSeriesFamily();

/// The local series grid for one source.
///
/// Copied from [localSeries].
class LocalSeriesFamily extends Family<AsyncValue<List<LocalSeriesRaw>>> {
  /// The local series grid for one source.
  ///
  /// Copied from [localSeries].
  const LocalSeriesFamily();

  /// The local series grid for one source.
  ///
  /// Copied from [localSeries].
  LocalSeriesProvider call(String sourceId) {
    return LocalSeriesProvider(sourceId);
  }

  @override
  LocalSeriesProvider getProviderOverride(
    covariant LocalSeriesProvider provider,
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
  String? get name => r'localSeriesProvider';
}

/// The local series grid for one source.
///
/// Copied from [localSeries].
class LocalSeriesProvider
    extends AutoDisposeStreamProvider<List<LocalSeriesRaw>> {
  /// The local series grid for one source.
  ///
  /// Copied from [localSeries].
  LocalSeriesProvider(String sourceId)
    : this._internal(
        (ref) => localSeries(ref as LocalSeriesRef, sourceId),
        from: localSeriesProvider,
        name: r'localSeriesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$localSeriesHash,
        dependencies: LocalSeriesFamily._dependencies,
        allTransitiveDependencies: LocalSeriesFamily._allTransitiveDependencies,
        sourceId: sourceId,
      );

  LocalSeriesProvider._internal(
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
    Stream<List<LocalSeriesRaw>> Function(LocalSeriesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LocalSeriesProvider._internal(
        (ref) => create(ref as LocalSeriesRef),
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
  AutoDisposeStreamProviderElement<List<LocalSeriesRaw>> createElement() {
    return _LocalSeriesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LocalSeriesProvider && other.sourceId == sourceId;
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
mixin LocalSeriesRef on AutoDisposeStreamProviderRef<List<LocalSeriesRaw>> {
  /// The parameter `sourceId` of this provider.
  String get sourceId;
}

class _LocalSeriesProviderElement
    extends AutoDisposeStreamProviderElement<List<LocalSeriesRaw>>
    with LocalSeriesRef {
  _LocalSeriesProviderElement(super.provider);

  @override
  String get sourceId => (origin as LocalSeriesProvider).sourceId;
}

String _$localBooksHash() => r'4a929d9d8afc55e96d6f9ea31ce310052a435d32';

/// Books of one local series (numberSort order, specials last).
///
/// Copied from [localBooks].
@ProviderFor(localBooks)
const localBooksProvider = LocalBooksFamily();

/// Books of one local series (numberSort order, specials last).
///
/// Copied from [localBooks].
class LocalBooksFamily extends Family<AsyncValue<List<LocalComic>>> {
  /// Books of one local series (numberSort order, specials last).
  ///
  /// Copied from [localBooks].
  const LocalBooksFamily();

  /// Books of one local series (numberSort order, specials last).
  ///
  /// Copied from [localBooks].
  LocalBooksProvider call(String sourceId, String series) {
    return LocalBooksProvider(sourceId, series);
  }

  @override
  LocalBooksProvider getProviderOverride(
    covariant LocalBooksProvider provider,
  ) {
    return call(provider.sourceId, provider.series);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'localBooksProvider';
}

/// Books of one local series (numberSort order, specials last).
///
/// Copied from [localBooks].
class LocalBooksProvider extends AutoDisposeStreamProvider<List<LocalComic>> {
  /// Books of one local series (numberSort order, specials last).
  ///
  /// Copied from [localBooks].
  LocalBooksProvider(String sourceId, String series)
    : this._internal(
        (ref) => localBooks(ref as LocalBooksRef, sourceId, series),
        from: localBooksProvider,
        name: r'localBooksProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$localBooksHash,
        dependencies: LocalBooksFamily._dependencies,
        allTransitiveDependencies: LocalBooksFamily._allTransitiveDependencies,
        sourceId: sourceId,
        series: series,
      );

  LocalBooksProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.sourceId,
    required this.series,
  }) : super.internal();

  final String sourceId;
  final String series;

  @override
  Override overrideWith(
    Stream<List<LocalComic>> Function(LocalBooksRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LocalBooksProvider._internal(
        (ref) => create(ref as LocalBooksRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        sourceId: sourceId,
        series: series,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<LocalComic>> createElement() {
    return _LocalBooksProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LocalBooksProvider &&
        other.sourceId == sourceId &&
        other.series == series;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, sourceId.hashCode);
    hash = _SystemHash.combine(hash, series.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin LocalBooksRef on AutoDisposeStreamProviderRef<List<LocalComic>> {
  /// The parameter `sourceId` of this provider.
  String get sourceId;

  /// The parameter `series` of this provider.
  String get series;
}

class _LocalBooksProviderElement
    extends AutoDisposeStreamProviderElement<List<LocalComic>>
    with LocalBooksRef {
  _LocalBooksProviderElement(super.provider);

  @override
  String get sourceId => (origin as LocalBooksProvider).sourceId;
  @override
  String get series => (origin as LocalBooksProvider).series;
}

String _$localComicHash() => r'53a5e5ddb19bc89c7e6ca0ef2421b42e6550934b';

/// One local comic by id (null when deleted).
///
/// Copied from [localComic].
@ProviderFor(localComic)
const localComicProvider = LocalComicFamily();

/// One local comic by id (null when deleted).
///
/// Copied from [localComic].
class LocalComicFamily extends Family<AsyncValue<LocalComic?>> {
  /// One local comic by id (null when deleted).
  ///
  /// Copied from [localComic].
  const LocalComicFamily();

  /// One local comic by id (null when deleted).
  ///
  /// Copied from [localComic].
  LocalComicProvider call(String comicId) {
    return LocalComicProvider(comicId);
  }

  @override
  LocalComicProvider getProviderOverride(
    covariant LocalComicProvider provider,
  ) {
    return call(provider.comicId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'localComicProvider';
}

/// One local comic by id (null when deleted).
///
/// Copied from [localComic].
class LocalComicProvider extends AutoDisposeFutureProvider<LocalComic?> {
  /// One local comic by id (null when deleted).
  ///
  /// Copied from [localComic].
  LocalComicProvider(String comicId)
    : this._internal(
        (ref) => localComic(ref as LocalComicRef, comicId),
        from: localComicProvider,
        name: r'localComicProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$localComicHash,
        dependencies: LocalComicFamily._dependencies,
        allTransitiveDependencies: LocalComicFamily._allTransitiveDependencies,
        comicId: comicId,
      );

  LocalComicProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.comicId,
  }) : super.internal();

  final String comicId;

  @override
  Override overrideWith(
    FutureOr<LocalComic?> Function(LocalComicRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LocalComicProvider._internal(
        (ref) => create(ref as LocalComicRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        comicId: comicId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<LocalComic?> createElement() {
    return _LocalComicProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LocalComicProvider && other.comicId == comicId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, comicId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin LocalComicRef on AutoDisposeFutureProviderRef<LocalComic?> {
  /// The parameter `comicId` of this provider.
  String get comicId;
}

class _LocalComicProviderElement
    extends AutoDisposeFutureProviderElement<LocalComic?>
    with LocalComicRef {
  _LocalComicProviderElement(super.provider);

  @override
  String get comicId => (origin as LocalComicProvider).comicId;
}

String _$localKeepReadingHash() => r'2f589dd524cab203c801f052a58bea66ef4e6f3e';

/// Keep-reading rail: in-progress local books, newest first.
///
/// Copied from [localKeepReading].
@ProviderFor(localKeepReading)
const localKeepReadingProvider = LocalKeepReadingFamily();

/// Keep-reading rail: in-progress local books, newest first.
///
/// Copied from [localKeepReading].
class LocalKeepReadingFamily extends Family<AsyncValue<List<LocalComic>>> {
  /// Keep-reading rail: in-progress local books, newest first.
  ///
  /// Copied from [localKeepReading].
  const LocalKeepReadingFamily();

  /// Keep-reading rail: in-progress local books, newest first.
  ///
  /// Copied from [localKeepReading].
  LocalKeepReadingProvider call(String sourceId) {
    return LocalKeepReadingProvider(sourceId);
  }

  @override
  LocalKeepReadingProvider getProviderOverride(
    covariant LocalKeepReadingProvider provider,
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
  String? get name => r'localKeepReadingProvider';
}

/// Keep-reading rail: in-progress local books, newest first.
///
/// Copied from [localKeepReading].
class LocalKeepReadingProvider
    extends AutoDisposeStreamProvider<List<LocalComic>> {
  /// Keep-reading rail: in-progress local books, newest first.
  ///
  /// Copied from [localKeepReading].
  LocalKeepReadingProvider(String sourceId)
    : this._internal(
        (ref) => localKeepReading(ref as LocalKeepReadingRef, sourceId),
        from: localKeepReadingProvider,
        name: r'localKeepReadingProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$localKeepReadingHash,
        dependencies: LocalKeepReadingFamily._dependencies,
        allTransitiveDependencies:
            LocalKeepReadingFamily._allTransitiveDependencies,
        sourceId: sourceId,
      );

  LocalKeepReadingProvider._internal(
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
    Stream<List<LocalComic>> Function(LocalKeepReadingRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LocalKeepReadingProvider._internal(
        (ref) => create(ref as LocalKeepReadingRef),
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
  AutoDisposeStreamProviderElement<List<LocalComic>> createElement() {
    return _LocalKeepReadingProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LocalKeepReadingProvider && other.sourceId == sourceId;
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
mixin LocalKeepReadingRef on AutoDisposeStreamProviderRef<List<LocalComic>> {
  /// The parameter `sourceId` of this provider.
  String get sourceId;
}

class _LocalKeepReadingProviderElement
    extends AutoDisposeStreamProviderElement<List<LocalComic>>
    with LocalKeepReadingRef {
  _LocalKeepReadingProviderElement(super.provider);

  @override
  String get sourceId => (origin as LocalKeepReadingProvider).sourceId;
}

String _$localRecentlyImportedHash() =>
    r'2a3d89fcca60023b10831e273ed547c2cb1ec773';

/// Recently-imported rail: newest imports first.
///
/// Copied from [localRecentlyImported].
@ProviderFor(localRecentlyImported)
const localRecentlyImportedProvider = LocalRecentlyImportedFamily();

/// Recently-imported rail: newest imports first.
///
/// Copied from [localRecentlyImported].
class LocalRecentlyImportedFamily extends Family<AsyncValue<List<LocalComic>>> {
  /// Recently-imported rail: newest imports first.
  ///
  /// Copied from [localRecentlyImported].
  const LocalRecentlyImportedFamily();

  /// Recently-imported rail: newest imports first.
  ///
  /// Copied from [localRecentlyImported].
  LocalRecentlyImportedProvider call(String sourceId) {
    return LocalRecentlyImportedProvider(sourceId);
  }

  @override
  LocalRecentlyImportedProvider getProviderOverride(
    covariant LocalRecentlyImportedProvider provider,
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
  String? get name => r'localRecentlyImportedProvider';
}

/// Recently-imported rail: newest imports first.
///
/// Copied from [localRecentlyImported].
class LocalRecentlyImportedProvider
    extends AutoDisposeStreamProvider<List<LocalComic>> {
  /// Recently-imported rail: newest imports first.
  ///
  /// Copied from [localRecentlyImported].
  LocalRecentlyImportedProvider(String sourceId)
    : this._internal(
        (ref) =>
            localRecentlyImported(ref as LocalRecentlyImportedRef, sourceId),
        from: localRecentlyImportedProvider,
        name: r'localRecentlyImportedProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$localRecentlyImportedHash,
        dependencies: LocalRecentlyImportedFamily._dependencies,
        allTransitiveDependencies:
            LocalRecentlyImportedFamily._allTransitiveDependencies,
        sourceId: sourceId,
      );

  LocalRecentlyImportedProvider._internal(
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
    Stream<List<LocalComic>> Function(LocalRecentlyImportedRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LocalRecentlyImportedProvider._internal(
        (ref) => create(ref as LocalRecentlyImportedRef),
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
  AutoDisposeStreamProviderElement<List<LocalComic>> createElement() {
    return _LocalRecentlyImportedProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LocalRecentlyImportedProvider && other.sourceId == sourceId;
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
mixin LocalRecentlyImportedRef
    on AutoDisposeStreamProviderRef<List<LocalComic>> {
  /// The parameter `sourceId` of this provider.
  String get sourceId;
}

class _LocalRecentlyImportedProviderElement
    extends AutoDisposeStreamProviderElement<List<LocalComic>>
    with LocalRecentlyImportedRef {
  _LocalRecentlyImportedProviderElement(super.provider);

  @override
  String get sourceId => (origin as LocalRecentlyImportedProvider).sourceId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
