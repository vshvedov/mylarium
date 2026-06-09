// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gallery_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$capturesRepositoryHash() =>
    r'5047aa1e41225368d6a99b946973b6efc961d8d7';

/// See also [capturesRepository].
@ProviderFor(capturesRepository)
final capturesRepositoryProvider =
    AutoDisposeProvider<CapturesRepository>.internal(
      capturesRepository,
      name: r'capturesRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$capturesRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CapturesRepositoryRef = AutoDisposeProviderRef<CapturesRepository>;
String _$capturesHash() => r'4be13a6bb10a7965bf537aa3916bbc3f825500e2';

/// All saved captures for the gallery, newest first, with captures whose library
/// is currently locked filtered out (mirrors the app-wide lock model). Re-emits
/// when a library is locked/unlocked.
///
/// Copied from [captures].
@ProviderFor(captures)
final capturesProvider = AutoDisposeStreamProvider<List<Capture>>.internal(
  captures,
  name: r'capturesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$capturesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CapturesRef = AutoDisposeStreamProviderRef<List<Capture>>;
String _$captureByIdHash() => r'4d0475f2fb8aad077af5e3ba60fc0e95648e395d';

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

/// A single capture by id (with its absolute path resolved), or null if it no
/// longer exists. Drives the capture viewer.
///
/// Copied from [captureById].
@ProviderFor(captureById)
const captureByIdProvider = CaptureByIdFamily();

/// A single capture by id (with its absolute path resolved), or null if it no
/// longer exists. Drives the capture viewer.
///
/// Copied from [captureById].
class CaptureByIdFamily extends Family<AsyncValue<Capture?>> {
  /// A single capture by id (with its absolute path resolved), or null if it no
  /// longer exists. Drives the capture viewer.
  ///
  /// Copied from [captureById].
  const CaptureByIdFamily();

  /// A single capture by id (with its absolute path resolved), or null if it no
  /// longer exists. Drives the capture viewer.
  ///
  /// Copied from [captureById].
  CaptureByIdProvider call(String id) {
    return CaptureByIdProvider(id);
  }

  @override
  CaptureByIdProvider getProviderOverride(
    covariant CaptureByIdProvider provider,
  ) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'captureByIdProvider';
}

/// A single capture by id (with its absolute path resolved), or null if it no
/// longer exists. Drives the capture viewer.
///
/// Copied from [captureById].
class CaptureByIdProvider extends AutoDisposeFutureProvider<Capture?> {
  /// A single capture by id (with its absolute path resolved), or null if it no
  /// longer exists. Drives the capture viewer.
  ///
  /// Copied from [captureById].
  CaptureByIdProvider(String id)
    : this._internal(
        (ref) => captureById(ref as CaptureByIdRef, id),
        from: captureByIdProvider,
        name: r'captureByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$captureByIdHash,
        dependencies: CaptureByIdFamily._dependencies,
        allTransitiveDependencies: CaptureByIdFamily._allTransitiveDependencies,
        id: id,
      );

  CaptureByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    FutureOr<Capture?> Function(CaptureByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CaptureByIdProvider._internal(
        (ref) => create(ref as CaptureByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Capture?> createElement() {
    return _CaptureByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CaptureByIdProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CaptureByIdRef on AutoDisposeFutureProviderRef<Capture?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _CaptureByIdProviderElement
    extends AutoDisposeFutureProviderElement<Capture?>
    with CaptureByIdRef {
  _CaptureByIdProviderElement(super.provider);

  @override
  String get id => (origin as CaptureByIdProvider).id;
}

String _$captureChapterAvailableHash() =>
    r'adcaf3a087ae9d9b9df4314febacac0e22da8b81';

/// Whether the chapter a capture came from can still be opened, so the viewer
/// knows whether to offer "Go to page". True when the book is still in the
/// catalog OR a cached offline archive is present; false when the chapter was
/// deleted (book purged / source removed / local file gone with nothing left).
///
/// Copied from [captureChapterAvailable].
@ProviderFor(captureChapterAvailable)
const captureChapterAvailableProvider = CaptureChapterAvailableFamily();

/// Whether the chapter a capture came from can still be opened, so the viewer
/// knows whether to offer "Go to page". True when the book is still in the
/// catalog OR a cached offline archive is present; false when the chapter was
/// deleted (book purged / source removed / local file gone with nothing left).
///
/// Copied from [captureChapterAvailable].
class CaptureChapterAvailableFamily extends Family<AsyncValue<bool>> {
  /// Whether the chapter a capture came from can still be opened, so the viewer
  /// knows whether to offer "Go to page". True when the book is still in the
  /// catalog OR a cached offline archive is present; false when the chapter was
  /// deleted (book purged / source removed / local file gone with nothing left).
  ///
  /// Copied from [captureChapterAvailable].
  const CaptureChapterAvailableFamily();

  /// Whether the chapter a capture came from can still be opened, so the viewer
  /// knows whether to offer "Go to page". True when the book is still in the
  /// catalog OR a cached offline archive is present; false when the chapter was
  /// deleted (book purged / source removed / local file gone with nothing left).
  ///
  /// Copied from [captureChapterAvailable].
  CaptureChapterAvailableProvider call(String sourceId, String bookId) {
    return CaptureChapterAvailableProvider(sourceId, bookId);
  }

  @override
  CaptureChapterAvailableProvider getProviderOverride(
    covariant CaptureChapterAvailableProvider provider,
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
  String? get name => r'captureChapterAvailableProvider';
}

/// Whether the chapter a capture came from can still be opened, so the viewer
/// knows whether to offer "Go to page". True when the book is still in the
/// catalog OR a cached offline archive is present; false when the chapter was
/// deleted (book purged / source removed / local file gone with nothing left).
///
/// Copied from [captureChapterAvailable].
class CaptureChapterAvailableProvider extends AutoDisposeFutureProvider<bool> {
  /// Whether the chapter a capture came from can still be opened, so the viewer
  /// knows whether to offer "Go to page". True when the book is still in the
  /// catalog OR a cached offline archive is present; false when the chapter was
  /// deleted (book purged / source removed / local file gone with nothing left).
  ///
  /// Copied from [captureChapterAvailable].
  CaptureChapterAvailableProvider(String sourceId, String bookId)
    : this._internal(
        (ref) => captureChapterAvailable(
          ref as CaptureChapterAvailableRef,
          sourceId,
          bookId,
        ),
        from: captureChapterAvailableProvider,
        name: r'captureChapterAvailableProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$captureChapterAvailableHash,
        dependencies: CaptureChapterAvailableFamily._dependencies,
        allTransitiveDependencies:
            CaptureChapterAvailableFamily._allTransitiveDependencies,
        sourceId: sourceId,
        bookId: bookId,
      );

  CaptureChapterAvailableProvider._internal(
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
    FutureOr<bool> Function(CaptureChapterAvailableRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CaptureChapterAvailableProvider._internal(
        (ref) => create(ref as CaptureChapterAvailableRef),
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
  AutoDisposeFutureProviderElement<bool> createElement() {
    return _CaptureChapterAvailableProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CaptureChapterAvailableProvider &&
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
mixin CaptureChapterAvailableRef on AutoDisposeFutureProviderRef<bool> {
  /// The parameter `sourceId` of this provider.
  String get sourceId;

  /// The parameter `bookId` of this provider.
  String get bookId;
}

class _CaptureChapterAvailableProviderElement
    extends AutoDisposeFutureProviderElement<bool>
    with CaptureChapterAvailableRef {
  _CaptureChapterAvailableProviderElement(super.provider);

  @override
  String get sourceId => (origin as CaptureChapterAvailableProvider).sourceId;
  @override
  String get bookId => (origin as CaptureChapterAvailableProvider).bookId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
