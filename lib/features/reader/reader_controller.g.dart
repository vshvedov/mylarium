// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reader_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$readerControllerHash() => r'76fb3aee5cdaa7a203aab3478d6638a63a57f1a4';

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

  FutureOr<ReaderData> build(String sourceId, String bookId);
}

/// Loads a book for reading (online-first). Throws when there is no source/api
/// or the page list cannot be fetched; the screen renders an error state.
///
/// Copied from [ReaderController].
@ProviderFor(ReaderController)
const readerControllerProvider = ReaderControllerFamily();

/// Loads a book for reading (online-first). Throws when there is no source/api
/// or the page list cannot be fetched; the screen renders an error state.
///
/// Copied from [ReaderController].
class ReaderControllerFamily extends Family<AsyncValue<ReaderData>> {
  /// Loads a book for reading (online-first). Throws when there is no source/api
  /// or the page list cannot be fetched; the screen renders an error state.
  ///
  /// Copied from [ReaderController].
  const ReaderControllerFamily();

  /// Loads a book for reading (online-first). Throws when there is no source/api
  /// or the page list cannot be fetched; the screen renders an error state.
  ///
  /// Copied from [ReaderController].
  ReaderControllerProvider call(String sourceId, String bookId) {
    return ReaderControllerProvider(sourceId, bookId);
  }

  @override
  ReaderControllerProvider getProviderOverride(
    covariant ReaderControllerProvider provider,
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
  String? get name => r'readerControllerProvider';
}

/// Loads a book for reading (online-first). Throws when there is no source/api
/// or the page list cannot be fetched; the screen renders an error state.
///
/// Copied from [ReaderController].
class ReaderControllerProvider
    extends AutoDisposeAsyncNotifierProviderImpl<ReaderController, ReaderData> {
  /// Loads a book for reading (online-first). Throws when there is no source/api
  /// or the page list cannot be fetched; the screen renders an error state.
  ///
  /// Copied from [ReaderController].
  ReaderControllerProvider(String sourceId, String bookId)
    : this._internal(
        () => ReaderController()
          ..sourceId = sourceId
          ..bookId = bookId,
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
  }) : super.internal();

  final String sourceId;
  final String bookId;

  @override
  FutureOr<ReaderData> runNotifierBuild(covariant ReaderController notifier) {
    return notifier.build(sourceId, bookId);
  }

  @override
  Override overrideWith(ReaderController Function() create) {
    return ProviderOverride(
      origin: this,
      override: ReaderControllerProvider._internal(
        () => create()
          ..sourceId = sourceId
          ..bookId = bookId,
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
  AutoDisposeAsyncNotifierProviderElement<ReaderController, ReaderData>
  createElement() {
    return _ReaderControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ReaderControllerProvider &&
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
mixin ReaderControllerRef on AutoDisposeAsyncNotifierProviderRef<ReaderData> {
  /// The parameter `sourceId` of this provider.
  String get sourceId;

  /// The parameter `bookId` of this provider.
  String get bookId;
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
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
