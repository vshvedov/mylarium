import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

bool _online(List<ConnectivityResult> results) =>
    results.any((r) => r != ConnectivityResult.none);

/// Whether the device currently has any network connection.
///
/// A coarse reachability signal for features that need the public internet
/// (e.g. Comic Vine, which is distinct from the self-hosted Komga server being
/// reachable on a LAN). The authoritative signal is still a failed request;
/// this just lets the UI show an offline state up front.
final isOnlineProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();
  yield _online(await connectivity.checkConnectivity());
  yield* connectivity.onConnectivityChanged.map(_online);
});
