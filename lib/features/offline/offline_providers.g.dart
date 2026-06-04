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
String _$downloadManagerHash() => r'fb08bd6bc2963fc264d3ea08d1908b58ecbea958';

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
String _$offlineAvailableHash() => r'8638cc19d0aa43be85f9d740e0388e82e544ce1a';

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

/// Whether a book is available offline, reactive to cache changes (streams the
/// cached-asset set and maps to this book's presence).
///
/// Copied from [offlineAvailable].
@ProviderFor(offlineAvailable)
const offlineAvailableProvider = OfflineAvailableFamily();

/// Whether a book is available offline, reactive to cache changes (streams the
/// cached-asset set and maps to this book's presence).
///
/// Copied from [offlineAvailable].
class OfflineAvailableFamily extends Family<AsyncValue<bool>> {
  /// Whether a book is available offline, reactive to cache changes (streams the
  /// cached-asset set and maps to this book's presence).
  ///
  /// Copied from [offlineAvailable].
  const OfflineAvailableFamily();

  /// Whether a book is available offline, reactive to cache changes (streams the
  /// cached-asset set and maps to this book's presence).
  ///
  /// Copied from [offlineAvailable].
  OfflineAvailableProvider call(String sourceId, String bookId) {
    return OfflineAvailableProvider(sourceId, bookId);
  }

  @override
  OfflineAvailableProvider getProviderOverride(
    covariant OfflineAvailableProvider provider,
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
  String? get name => r'offlineAvailableProvider';
}

/// Whether a book is available offline, reactive to cache changes (streams the
/// cached-asset set and maps to this book's presence).
///
/// Copied from [offlineAvailable].
class OfflineAvailableProvider extends AutoDisposeStreamProvider<bool> {
  /// Whether a book is available offline, reactive to cache changes (streams the
  /// cached-asset set and maps to this book's presence).
  ///
  /// Copied from [offlineAvailable].
  OfflineAvailableProvider(String sourceId, String bookId)
    : this._internal(
        (ref) => offlineAvailable(ref as OfflineAvailableRef, sourceId, bookId),
        from: offlineAvailableProvider,
        name: r'offlineAvailableProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$offlineAvailableHash,
        dependencies: OfflineAvailableFamily._dependencies,
        allTransitiveDependencies:
            OfflineAvailableFamily._allTransitiveDependencies,
        sourceId: sourceId,
        bookId: bookId,
      );

  OfflineAvailableProvider._internal(
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
    Stream<bool> Function(OfflineAvailableRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: OfflineAvailableProvider._internal(
        (ref) => create(ref as OfflineAvailableRef),
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
  AutoDisposeStreamProviderElement<bool> createElement() {
    return _OfflineAvailableProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is OfflineAvailableProvider &&
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
mixin OfflineAvailableRef on AutoDisposeStreamProviderRef<bool> {
  /// The parameter `sourceId` of this provider.
  String get sourceId;

  /// The parameter `bookId` of this provider.
  String get bookId;
}

class _OfflineAvailableProviderElement
    extends AutoDisposeStreamProviderElement<bool>
    with OfflineAvailableRef {
  _OfflineAvailableProviderElement(super.provider);

  @override
  String get sourceId => (origin as OfflineAvailableProvider).sourceId;
  @override
  String get bookId => (origin as OfflineAvailableProvider).bookId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
