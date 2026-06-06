import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/source/source_providers.dart';

part 'reachability.g.dart';

/// Reachability of a specific source's server. Probes that server directly (not
/// internet connectivity), so a LAN server is reported online even with no WAN.
/// Resolves to false when there is no client for the source. Refresh by
/// invalidating this provider (the app-bar indicator does so on tap).
@riverpod
Future<bool> sourceReachable(Ref ref, String sourceId) async {
  if (sourceId.isEmpty) return false;
  final api = await ref.watch(contentApiForProvider(sourceId).future);
  if (api == null) return false;
  return api.ping();
}
