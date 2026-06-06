import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'reachability.dart';

/// App-bar indicator for the active source's server reachability: a small dot
/// (online / unreachable / checking). Tapping it re-probes the server. The probe
/// targets the specific server, so a reachable LAN server reads online offline.
class SourceStatusButton extends ConsumerWidget {
  const SourceStatusButton({super.key, required this.sourceId});

  final String sourceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final reachable = ref.watch(sourceReachableProvider(sourceId));
    final (Color color, String tooltip) = switch (reachable) {
      AsyncData(:final value) => value
          ? (const Color(0xFF3FB950), 'Server online - tap to recheck')
          : (scheme.error, 'Server unreachable - tap to retry'),
      AsyncError() => (scheme.error, 'Server unreachable - tap to retry'),
      _ => (scheme.onSurfaceVariant, 'Checking server...'),
    };
    return IconButton(
      tooltip: tooltip,
      onPressed: () => ref.invalidate(sourceReachableProvider(sourceId)),
      icon: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}
