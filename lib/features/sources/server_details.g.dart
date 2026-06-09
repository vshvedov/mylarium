// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_details.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$serverDetailsHash() => r'2521bcfc205d8c517cb0d56818fc29794a14bcfb';

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

/// Fetches [ServerDetails] for one source when the details popup opens. Reads the
/// local `Source` row for connection metadata, resolves the `ContentApi`, and
/// merges best-effort [ServerFacts]. An unreachable server or expired session is
/// a rendered offline state (online:false), not an AsyncError, so the dialog can
/// show connection info plus a Retry. Refresh by invalidating this provider.
///
/// Copied from [serverDetails].
@ProviderFor(serverDetails)
const serverDetailsProvider = ServerDetailsFamily();

/// Fetches [ServerDetails] for one source when the details popup opens. Reads the
/// local `Source` row for connection metadata, resolves the `ContentApi`, and
/// merges best-effort [ServerFacts]. An unreachable server or expired session is
/// a rendered offline state (online:false), not an AsyncError, so the dialog can
/// show connection info plus a Retry. Refresh by invalidating this provider.
///
/// Copied from [serverDetails].
class ServerDetailsFamily extends Family<AsyncValue<ServerDetails>> {
  /// Fetches [ServerDetails] for one source when the details popup opens. Reads the
  /// local `Source` row for connection metadata, resolves the `ContentApi`, and
  /// merges best-effort [ServerFacts]. An unreachable server or expired session is
  /// a rendered offline state (online:false), not an AsyncError, so the dialog can
  /// show connection info plus a Retry. Refresh by invalidating this provider.
  ///
  /// Copied from [serverDetails].
  const ServerDetailsFamily();

  /// Fetches [ServerDetails] for one source when the details popup opens. Reads the
  /// local `Source` row for connection metadata, resolves the `ContentApi`, and
  /// merges best-effort [ServerFacts]. An unreachable server or expired session is
  /// a rendered offline state (online:false), not an AsyncError, so the dialog can
  /// show connection info plus a Retry. Refresh by invalidating this provider.
  ///
  /// Copied from [serverDetails].
  ServerDetailsProvider call(String sourceId) {
    return ServerDetailsProvider(sourceId);
  }

  @override
  ServerDetailsProvider getProviderOverride(
    covariant ServerDetailsProvider provider,
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
  String? get name => r'serverDetailsProvider';
}

/// Fetches [ServerDetails] for one source when the details popup opens. Reads the
/// local `Source` row for connection metadata, resolves the `ContentApi`, and
/// merges best-effort [ServerFacts]. An unreachable server or expired session is
/// a rendered offline state (online:false), not an AsyncError, so the dialog can
/// show connection info plus a Retry. Refresh by invalidating this provider.
///
/// Copied from [serverDetails].
class ServerDetailsProvider extends AutoDisposeFutureProvider<ServerDetails> {
  /// Fetches [ServerDetails] for one source when the details popup opens. Reads the
  /// local `Source` row for connection metadata, resolves the `ContentApi`, and
  /// merges best-effort [ServerFacts]. An unreachable server or expired session is
  /// a rendered offline state (online:false), not an AsyncError, so the dialog can
  /// show connection info plus a Retry. Refresh by invalidating this provider.
  ///
  /// Copied from [serverDetails].
  ServerDetailsProvider(String sourceId)
    : this._internal(
        (ref) => serverDetails(ref as ServerDetailsRef, sourceId),
        from: serverDetailsProvider,
        name: r'serverDetailsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$serverDetailsHash,
        dependencies: ServerDetailsFamily._dependencies,
        allTransitiveDependencies:
            ServerDetailsFamily._allTransitiveDependencies,
        sourceId: sourceId,
      );

  ServerDetailsProvider._internal(
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
    FutureOr<ServerDetails> Function(ServerDetailsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ServerDetailsProvider._internal(
        (ref) => create(ref as ServerDetailsRef),
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
  AutoDisposeFutureProviderElement<ServerDetails> createElement() {
    return _ServerDetailsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ServerDetailsProvider && other.sourceId == sourceId;
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
mixin ServerDetailsRef on AutoDisposeFutureProviderRef<ServerDetails> {
  /// The parameter `sourceId` of this provider.
  String get sourceId;
}

class _ServerDetailsProviderElement
    extends AutoDisposeFutureProviderElement<ServerDetails>
    with ServerDetailsRef {
  _ServerDetailsProviderElement(super.provider);

  @override
  String get sourceId => (origin as ServerDetailsProvider).sourceId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
