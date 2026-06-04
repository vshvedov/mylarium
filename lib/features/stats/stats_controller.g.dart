// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$statsSummaryHash() => r'6682fbfe7c288f4ebff12e7e2253f89416f060e3';

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

/// Computes the [StatsSummary] for [period], picking the local-time range, the
/// comparable previous period, and the bucket granularity.
///
/// Copied from [statsSummary].
@ProviderFor(statsSummary)
const statsSummaryProvider = StatsSummaryFamily();

/// Computes the [StatsSummary] for [period], picking the local-time range, the
/// comparable previous period, and the bucket granularity.
///
/// Copied from [statsSummary].
class StatsSummaryFamily extends Family<AsyncValue<StatsSummary>> {
  /// Computes the [StatsSummary] for [period], picking the local-time range, the
  /// comparable previous period, and the bucket granularity.
  ///
  /// Copied from [statsSummary].
  const StatsSummaryFamily();

  /// Computes the [StatsSummary] for [period], picking the local-time range, the
  /// comparable previous period, and the bucket granularity.
  ///
  /// Copied from [statsSummary].
  StatsSummaryProvider call(StatsPeriod period) {
    return StatsSummaryProvider(period);
  }

  @override
  StatsSummaryProvider getProviderOverride(
    covariant StatsSummaryProvider provider,
  ) {
    return call(provider.period);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'statsSummaryProvider';
}

/// Computes the [StatsSummary] for [period], picking the local-time range, the
/// comparable previous period, and the bucket granularity.
///
/// Copied from [statsSummary].
class StatsSummaryProvider extends AutoDisposeFutureProvider<StatsSummary> {
  /// Computes the [StatsSummary] for [period], picking the local-time range, the
  /// comparable previous period, and the bucket granularity.
  ///
  /// Copied from [statsSummary].
  StatsSummaryProvider(StatsPeriod period)
    : this._internal(
        (ref) => statsSummary(ref as StatsSummaryRef, period),
        from: statsSummaryProvider,
        name: r'statsSummaryProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$statsSummaryHash,
        dependencies: StatsSummaryFamily._dependencies,
        allTransitiveDependencies:
            StatsSummaryFamily._allTransitiveDependencies,
        period: period,
      );

  StatsSummaryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.period,
  }) : super.internal();

  final StatsPeriod period;

  @override
  Override overrideWith(
    FutureOr<StatsSummary> Function(StatsSummaryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StatsSummaryProvider._internal(
        (ref) => create(ref as StatsSummaryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        period: period,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<StatsSummary> createElement() {
    return _StatsSummaryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StatsSummaryProvider && other.period == period;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, period.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin StatsSummaryRef on AutoDisposeFutureProviderRef<StatsSummary> {
  /// The parameter `period` of this provider.
  StatsPeriod get period;
}

class _StatsSummaryProviderElement
    extends AutoDisposeFutureProviderElement<StatsSummary>
    with StatsSummaryRef {
  _StatsSummaryProviderElement(super.provider);

  @override
  StatsPeriod get period => (origin as StatsSummaryProvider).period;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
