// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'series_sync.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$seriesSyncHash() => r'00b9f7ee478bd96a320ae089bb71f4387f106fca';

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

/// Shared per (sourceId, libraryId) full sync; watching it kicks the
/// background fill. keepAlive so it is not torn down between rebuilds while
/// browsing.
///
/// Returns null when the [SeriesRepository] is not yet available (e.g. auth
/// still loading). The grid can await the non-null value before rendering.
///
/// Copied from [seriesSync].
@ProviderFor(seriesSync)
const seriesSyncProvider = SeriesSyncFamily();

/// Shared per (sourceId, libraryId) full sync; watching it kicks the
/// background fill. keepAlive so it is not torn down between rebuilds while
/// browsing.
///
/// Returns null when the [SeriesRepository] is not yet available (e.g. auth
/// still loading). The grid can await the non-null value before rendering.
///
/// Copied from [seriesSync].
class SeriesSyncFamily extends Family<AsyncValue<SeriesSync?>> {
  /// Shared per (sourceId, libraryId) full sync; watching it kicks the
  /// background fill. keepAlive so it is not torn down between rebuilds while
  /// browsing.
  ///
  /// Returns null when the [SeriesRepository] is not yet available (e.g. auth
  /// still loading). The grid can await the non-null value before rendering.
  ///
  /// Copied from [seriesSync].
  const SeriesSyncFamily();

  /// Shared per (sourceId, libraryId) full sync; watching it kicks the
  /// background fill. keepAlive so it is not torn down between rebuilds while
  /// browsing.
  ///
  /// Returns null when the [SeriesRepository] is not yet available (e.g. auth
  /// still loading). The grid can await the non-null value before rendering.
  ///
  /// Copied from [seriesSync].
  SeriesSyncProvider call(String sourceId, String? libraryId) {
    return SeriesSyncProvider(sourceId, libraryId);
  }

  @override
  SeriesSyncProvider getProviderOverride(
    covariant SeriesSyncProvider provider,
  ) {
    return call(provider.sourceId, provider.libraryId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'seriesSyncProvider';
}

/// Shared per (sourceId, libraryId) full sync; watching it kicks the
/// background fill. keepAlive so it is not torn down between rebuilds while
/// browsing.
///
/// Returns null when the [SeriesRepository] is not yet available (e.g. auth
/// still loading). The grid can await the non-null value before rendering.
///
/// Copied from [seriesSync].
class SeriesSyncProvider extends FutureProvider<SeriesSync?> {
  /// Shared per (sourceId, libraryId) full sync; watching it kicks the
  /// background fill. keepAlive so it is not torn down between rebuilds while
  /// browsing.
  ///
  /// Returns null when the [SeriesRepository] is not yet available (e.g. auth
  /// still loading). The grid can await the non-null value before rendering.
  ///
  /// Copied from [seriesSync].
  SeriesSyncProvider(String sourceId, String? libraryId)
    : this._internal(
        (ref) => seriesSync(ref as SeriesSyncRef, sourceId, libraryId),
        from: seriesSyncProvider,
        name: r'seriesSyncProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$seriesSyncHash,
        dependencies: SeriesSyncFamily._dependencies,
        allTransitiveDependencies: SeriesSyncFamily._allTransitiveDependencies,
        sourceId: sourceId,
        libraryId: libraryId,
      );

  SeriesSyncProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.sourceId,
    required this.libraryId,
  }) : super.internal();

  final String sourceId;
  final String? libraryId;

  @override
  Override overrideWith(
    FutureOr<SeriesSync?> Function(SeriesSyncRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SeriesSyncProvider._internal(
        (ref) => create(ref as SeriesSyncRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        sourceId: sourceId,
        libraryId: libraryId,
      ),
    );
  }

  @override
  FutureProviderElement<SeriesSync?> createElement() {
    return _SeriesSyncProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SeriesSyncProvider &&
        other.sourceId == sourceId &&
        other.libraryId == libraryId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, sourceId.hashCode);
    hash = _SystemHash.combine(hash, libraryId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SeriesSyncRef on FutureProviderRef<SeriesSync?> {
  /// The parameter `sourceId` of this provider.
  String get sourceId;

  /// The parameter `libraryId` of this provider.
  String? get libraryId;
}

class _SeriesSyncProviderElement extends FutureProviderElement<SeriesSync?>
    with SeriesSyncRef {
  _SeriesSyncProviderElement(super.provider);

  @override
  String get sourceId => (origin as SeriesSyncProvider).sourceId;
  @override
  String? get libraryId => (origin as SeriesSyncProvider).libraryId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
