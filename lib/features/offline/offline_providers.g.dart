// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$archiveExtractorHash() => r'f3b59759818ac76ae0678338f4731879f3e67242';

/// See also [archiveExtractor].
@ProviderFor(archiveExtractor)
final archiveExtractorProvider = Provider<ArchiveExtractor>.internal(
  archiveExtractor,
  name: r'archiveExtractorProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$archiveExtractorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ArchiveExtractorRef = ProviderRef<ArchiveExtractor>;
String _$downloaderHash() => r'7aaa4d7ff166dcbfbeaa5c2540fdd6df28ef03d4';

/// The platform download backend. Overridden with a fake in tests.
///
/// Copied from [downloader].
@ProviderFor(downloader)
final downloaderProvider = Provider<Downloader>.internal(
  downloader,
  name: r'downloaderProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$downloaderHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DownloaderRef = ProviderRef<Downloader>;
String _$offlineCacheManagerHash() =>
    r'7ace07c6c6d5dad33a2506de10766db9b6779f27';

/// See also [offlineCacheManager].
@ProviderFor(offlineCacheManager)
final offlineCacheManagerProvider = Provider<OfflineCacheManager>.internal(
  offlineCacheManager,
  name: r'offlineCacheManagerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$offlineCacheManagerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OfflineCacheManagerRef = ProviderRef<OfflineCacheManager>;
String _$downloadManagerHash() => r'74baf8e5581ad3f949c9a81cad92c6ce5a1f192d';

/// See also [downloadManager].
@ProviderFor(downloadManager)
final downloadManagerProvider = Provider<DownloadManager>.internal(
  downloadManager,
  name: r'downloadManagerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$downloadManagerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DownloadManagerRef = ProviderRef<DownloadManager>;
String _$cachedAssetHash() => r'521c8063fd809750f78c046277db7d3fb06e07ac';

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

/// The cached asset for a book (or null), reactive. Drives the per-book offline
/// indicator and Download control.
///
/// Copied from [cachedAsset].
@ProviderFor(cachedAsset)
const cachedAssetProvider = CachedAssetFamily();

/// The cached asset for a book (or null), reactive. Drives the per-book offline
/// indicator and Download control.
///
/// Copied from [cachedAsset].
class CachedAssetFamily extends Family<AsyncValue<CachedAsset?>> {
  /// The cached asset for a book (or null), reactive. Drives the per-book offline
  /// indicator and Download control.
  ///
  /// Copied from [cachedAsset].
  const CachedAssetFamily();

  /// The cached asset for a book (or null), reactive. Drives the per-book offline
  /// indicator and Download control.
  ///
  /// Copied from [cachedAsset].
  CachedAssetProvider call(String sourceId, String bookId) {
    return CachedAssetProvider(sourceId, bookId);
  }

  @override
  CachedAssetProvider getProviderOverride(
    covariant CachedAssetProvider provider,
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
  String? get name => r'cachedAssetProvider';
}

/// The cached asset for a book (or null), reactive. Drives the per-book offline
/// indicator and Download control.
///
/// Copied from [cachedAsset].
class CachedAssetProvider extends AutoDisposeStreamProvider<CachedAsset?> {
  /// The cached asset for a book (or null), reactive. Drives the per-book offline
  /// indicator and Download control.
  ///
  /// Copied from [cachedAsset].
  CachedAssetProvider(String sourceId, String bookId)
    : this._internal(
        (ref) => cachedAsset(ref as CachedAssetRef, sourceId, bookId),
        from: cachedAssetProvider,
        name: r'cachedAssetProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$cachedAssetHash,
        dependencies: CachedAssetFamily._dependencies,
        allTransitiveDependencies: CachedAssetFamily._allTransitiveDependencies,
        sourceId: sourceId,
        bookId: bookId,
      );

  CachedAssetProvider._internal(
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
    Stream<CachedAsset?> Function(CachedAssetRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CachedAssetProvider._internal(
        (ref) => create(ref as CachedAssetRef),
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
  AutoDisposeStreamProviderElement<CachedAsset?> createElement() {
    return _CachedAssetProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CachedAssetProvider &&
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
mixin CachedAssetRef on AutoDisposeStreamProviderRef<CachedAsset?> {
  /// The parameter `sourceId` of this provider.
  String get sourceId;

  /// The parameter `bookId` of this provider.
  String get bookId;
}

class _CachedAssetProviderElement
    extends AutoDisposeStreamProviderElement<CachedAsset?>
    with CachedAssetRef {
  _CachedAssetProviderElement(super.provider);

  @override
  String get sourceId => (origin as CachedAssetProvider).sourceId;
  @override
  String get bookId => (origin as CachedAssetProvider).bookId;
}

String _$downloadProgressHash() => r'eb63daed55b4df6c6b382bc95680055a9ef3ed15';

/// Live download progress for a book.
///
/// Copied from [downloadProgress].
@ProviderFor(downloadProgress)
const downloadProgressProvider = DownloadProgressFamily();

/// Live download progress for a book.
///
/// Copied from [downloadProgress].
class DownloadProgressFamily extends Family<AsyncValue<DownloadProgress>> {
  /// Live download progress for a book.
  ///
  /// Copied from [downloadProgress].
  const DownloadProgressFamily();

  /// Live download progress for a book.
  ///
  /// Copied from [downloadProgress].
  DownloadProgressProvider call(String sourceId, String bookId) {
    return DownloadProgressProvider(sourceId, bookId);
  }

  @override
  DownloadProgressProvider getProviderOverride(
    covariant DownloadProgressProvider provider,
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
  String? get name => r'downloadProgressProvider';
}

/// Live download progress for a book.
///
/// Copied from [downloadProgress].
class DownloadProgressProvider
    extends AutoDisposeStreamProvider<DownloadProgress> {
  /// Live download progress for a book.
  ///
  /// Copied from [downloadProgress].
  DownloadProgressProvider(String sourceId, String bookId)
    : this._internal(
        (ref) => downloadProgress(ref as DownloadProgressRef, sourceId, bookId),
        from: downloadProgressProvider,
        name: r'downloadProgressProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$downloadProgressHash,
        dependencies: DownloadProgressFamily._dependencies,
        allTransitiveDependencies:
            DownloadProgressFamily._allTransitiveDependencies,
        sourceId: sourceId,
        bookId: bookId,
      );

  DownloadProgressProvider._internal(
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
    Stream<DownloadProgress> Function(DownloadProgressRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DownloadProgressProvider._internal(
        (ref) => create(ref as DownloadProgressRef),
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
  AutoDisposeStreamProviderElement<DownloadProgress> createElement() {
    return _DownloadProgressProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DownloadProgressProvider &&
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
mixin DownloadProgressRef on AutoDisposeStreamProviderRef<DownloadProgress> {
  /// The parameter `sourceId` of this provider.
  String get sourceId;

  /// The parameter `bookId` of this provider.
  String get bookId;
}

class _DownloadProgressProviderElement
    extends AutoDisposeStreamProviderElement<DownloadProgress>
    with DownloadProgressRef {
  _DownloadProgressProviderElement(super.provider);

  @override
  String get sourceId => (origin as DownloadProgressProvider).sourceId;
  @override
  String get bookId => (origin as DownloadProgressProvider).bookId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
