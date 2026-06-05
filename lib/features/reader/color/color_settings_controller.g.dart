// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'color_settings_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$colorSettingsControllerHash() =>
    r'ac2c8a0822f6549e1e60b4e68c47970ce903bc69';

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

abstract class _$ColorSettingsController
    extends BuildlessAutoDisposeAsyncNotifier<ColorState> {
  late final String sourceId;
  late final String seriesId;
  late final String bookId;

  FutureOr<ColorState> build(String sourceId, String seriesId, String bookId);
}

/// Owns the reader's live color-correction state for one book: the resolved
/// effective adjustment, the value being edited at the active scope, and the
/// session-only quick on/off. Mutations persist through
/// [ColorSettingsRepository] and re-resolve (mirrors `ReaderController`'s
/// AsyncNotifier mutate pattern).
///
/// Copied from [ColorSettingsController].
@ProviderFor(ColorSettingsController)
const colorSettingsControllerProvider = ColorSettingsControllerFamily();

/// Owns the reader's live color-correction state for one book: the resolved
/// effective adjustment, the value being edited at the active scope, and the
/// session-only quick on/off. Mutations persist through
/// [ColorSettingsRepository] and re-resolve (mirrors `ReaderController`'s
/// AsyncNotifier mutate pattern).
///
/// Copied from [ColorSettingsController].
class ColorSettingsControllerFamily extends Family<AsyncValue<ColorState>> {
  /// Owns the reader's live color-correction state for one book: the resolved
  /// effective adjustment, the value being edited at the active scope, and the
  /// session-only quick on/off. Mutations persist through
  /// [ColorSettingsRepository] and re-resolve (mirrors `ReaderController`'s
  /// AsyncNotifier mutate pattern).
  ///
  /// Copied from [ColorSettingsController].
  const ColorSettingsControllerFamily();

  /// Owns the reader's live color-correction state for one book: the resolved
  /// effective adjustment, the value being edited at the active scope, and the
  /// session-only quick on/off. Mutations persist through
  /// [ColorSettingsRepository] and re-resolve (mirrors `ReaderController`'s
  /// AsyncNotifier mutate pattern).
  ///
  /// Copied from [ColorSettingsController].
  ColorSettingsControllerProvider call(
    String sourceId,
    String seriesId,
    String bookId,
  ) {
    return ColorSettingsControllerProvider(sourceId, seriesId, bookId);
  }

  @override
  ColorSettingsControllerProvider getProviderOverride(
    covariant ColorSettingsControllerProvider provider,
  ) {
    return call(provider.sourceId, provider.seriesId, provider.bookId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'colorSettingsControllerProvider';
}

/// Owns the reader's live color-correction state for one book: the resolved
/// effective adjustment, the value being edited at the active scope, and the
/// session-only quick on/off. Mutations persist through
/// [ColorSettingsRepository] and re-resolve (mirrors `ReaderController`'s
/// AsyncNotifier mutate pattern).
///
/// Copied from [ColorSettingsController].
class ColorSettingsControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          ColorSettingsController,
          ColorState
        > {
  /// Owns the reader's live color-correction state for one book: the resolved
  /// effective adjustment, the value being edited at the active scope, and the
  /// session-only quick on/off. Mutations persist through
  /// [ColorSettingsRepository] and re-resolve (mirrors `ReaderController`'s
  /// AsyncNotifier mutate pattern).
  ///
  /// Copied from [ColorSettingsController].
  ColorSettingsControllerProvider(
    String sourceId,
    String seriesId,
    String bookId,
  ) : this._internal(
        () => ColorSettingsController()
          ..sourceId = sourceId
          ..seriesId = seriesId
          ..bookId = bookId,
        from: colorSettingsControllerProvider,
        name: r'colorSettingsControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$colorSettingsControllerHash,
        dependencies: ColorSettingsControllerFamily._dependencies,
        allTransitiveDependencies:
            ColorSettingsControllerFamily._allTransitiveDependencies,
        sourceId: sourceId,
        seriesId: seriesId,
        bookId: bookId,
      );

  ColorSettingsControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.sourceId,
    required this.seriesId,
    required this.bookId,
  }) : super.internal();

  final String sourceId;
  final String seriesId;
  final String bookId;

  @override
  FutureOr<ColorState> runNotifierBuild(
    covariant ColorSettingsController notifier,
  ) {
    return notifier.build(sourceId, seriesId, bookId);
  }

  @override
  Override overrideWith(ColorSettingsController Function() create) {
    return ProviderOverride(
      origin: this,
      override: ColorSettingsControllerProvider._internal(
        () => create()
          ..sourceId = sourceId
          ..seriesId = seriesId
          ..bookId = bookId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        sourceId: sourceId,
        seriesId: seriesId,
        bookId: bookId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ColorSettingsController, ColorState>
  createElement() {
    return _ColorSettingsControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ColorSettingsControllerProvider &&
        other.sourceId == sourceId &&
        other.seriesId == seriesId &&
        other.bookId == bookId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, sourceId.hashCode);
    hash = _SystemHash.combine(hash, seriesId.hashCode);
    hash = _SystemHash.combine(hash, bookId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ColorSettingsControllerRef
    on AutoDisposeAsyncNotifierProviderRef<ColorState> {
  /// The parameter `sourceId` of this provider.
  String get sourceId;

  /// The parameter `seriesId` of this provider.
  String get seriesId;

  /// The parameter `bookId` of this provider.
  String get bookId;
}

class _ColorSettingsControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          ColorSettingsController,
          ColorState
        >
    with ColorSettingsControllerRef {
  _ColorSettingsControllerProviderElement(super.provider);

  @override
  String get sourceId => (origin as ColorSettingsControllerProvider).sourceId;
  @override
  String get seriesId => (origin as ColorSettingsControllerProvider).seriesId;
  @override
  String get bookId => (origin as ColorSettingsControllerProvider).bookId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
