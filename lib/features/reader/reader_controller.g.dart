// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reader_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$readerControllerHash() => r'96e99ecc529de96532b2f6ee054dec6f9d63837d';

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

abstract class _$ReaderController
    extends BuildlessAutoDisposeAsyncNotifier<ReaderData> {
  late final String sourceId;
  late final String bookId;
  late final bool preview;

  FutureOr<ReaderData> build(
    String sourceId,
    String bookId, [
    bool preview = false,
  ]);
}

/// Loads a book for reading, offline-first: a cached archive is read from disk
/// (no network); otherwise pages stream online (per-page, through the byte
/// cache). The full-chapter offline backfill is NOT started here: the reader
/// defers it to close/background so it never competes with foreground page
/// fetches. Throws only when neither a cache nor a reachable source exists.
///
/// Copied from [ReaderController].
@ProviderFor(ReaderController)
const readerControllerProvider = ReaderControllerFamily();

/// Loads a book for reading, offline-first: a cached archive is read from disk
/// (no network); otherwise pages stream online (per-page, through the byte
/// cache). The full-chapter offline backfill is NOT started here: the reader
/// defers it to close/background so it never competes with foreground page
/// fetches. Throws only when neither a cache nor a reachable source exists.
///
/// Copied from [ReaderController].
class ReaderControllerFamily extends Family<AsyncValue<ReaderData>> {
  /// Loads a book for reading, offline-first: a cached archive is read from disk
  /// (no network); otherwise pages stream online (per-page, through the byte
  /// cache). The full-chapter offline backfill is NOT started here: the reader
  /// defers it to close/background so it never competes with foreground page
  /// fetches. Throws only when neither a cache nor a reachable source exists.
  ///
  /// Copied from [ReaderController].
  const ReaderControllerFamily();

  /// Loads a book for reading, offline-first: a cached archive is read from disk
  /// (no network); otherwise pages stream online (per-page, through the byte
  /// cache). The full-chapter offline backfill is NOT started here: the reader
  /// defers it to close/background so it never competes with foreground page
  /// fetches. Throws only when neither a cache nor a reachable source exists.
  ///
  /// Copied from [ReaderController].
  ReaderControllerProvider call(
    String sourceId,
    String bookId, [
    bool preview = false,
  ]) {
    return ReaderControllerProvider(sourceId, bookId, preview);
  }

  @override
  ReaderControllerProvider getProviderOverride(
    covariant ReaderControllerProvider provider,
  ) {
    return call(provider.sourceId, provider.bookId, provider.preview);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'readerControllerProvider';
}

/// Loads a book for reading, offline-first: a cached archive is read from disk
/// (no network); otherwise pages stream online (per-page, through the byte
/// cache). The full-chapter offline backfill is NOT started here: the reader
/// defers it to close/background so it never competes with foreground page
/// fetches. Throws only when neither a cache nor a reachable source exists.
///
/// Copied from [ReaderController].
class ReaderControllerProvider
    extends AutoDisposeAsyncNotifierProviderImpl<ReaderController, ReaderData> {
  /// Loads a book for reading, offline-first: a cached archive is read from disk
  /// (no network); otherwise pages stream online (per-page, through the byte
  /// cache). The full-chapter offline backfill is NOT started here: the reader
  /// defers it to close/background so it never competes with foreground page
  /// fetches. Throws only when neither a cache nor a reachable source exists.
  ///
  /// Copied from [ReaderController].
  ReaderControllerProvider(
    String sourceId,
    String bookId, [
    bool preview = false,
  ]) : this._internal(
         () => ReaderController()
           ..sourceId = sourceId
           ..bookId = bookId
           ..preview = preview,
         from: readerControllerProvider,
         name: r'readerControllerProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$readerControllerHash,
         dependencies: ReaderControllerFamily._dependencies,
         allTransitiveDependencies:
             ReaderControllerFamily._allTransitiveDependencies,
         sourceId: sourceId,
         bookId: bookId,
         preview: preview,
       );

  ReaderControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.sourceId,
    required this.bookId,
    required this.preview,
  }) : super.internal();

  final String sourceId;
  final String bookId;
  final bool preview;

  @override
  FutureOr<ReaderData> runNotifierBuild(covariant ReaderController notifier) {
    return notifier.build(sourceId, bookId, preview);
  }

  @override
  Override overrideWith(ReaderController Function() create) {
    return ProviderOverride(
      origin: this,
      override: ReaderControllerProvider._internal(
        () => create()
          ..sourceId = sourceId
          ..bookId = bookId
          ..preview = preview,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        sourceId: sourceId,
        bookId: bookId,
        preview: preview,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ReaderController, ReaderData>
  createElement() {
    return _ReaderControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ReaderControllerProvider &&
        other.sourceId == sourceId &&
        other.bookId == bookId &&
        other.preview == preview;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, sourceId.hashCode);
    hash = _SystemHash.combine(hash, bookId.hashCode);
    hash = _SystemHash.combine(hash, preview.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ReaderControllerRef on AutoDisposeAsyncNotifierProviderRef<ReaderData> {
  /// The parameter `sourceId` of this provider.
  String get sourceId;

  /// The parameter `bookId` of this provider.
  String get bookId;

  /// The parameter `preview` of this provider.
  bool get preview;
}

class _ReaderControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<ReaderController, ReaderData>
    with ReaderControllerRef {
  _ReaderControllerProviderElement(super.provider);

  @override
  String get sourceId => (origin as ReaderControllerProvider).sourceId;
  @override
  String get bookId => (origin as ReaderControllerProvider).bookId;
  @override
  bool get preview => (origin as ReaderControllerProvider).preview;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
