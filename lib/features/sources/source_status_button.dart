import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n.dart';
import 'reachability.dart';
import 'server_details_dialog.dart';

/// App-bar indicator for the active source's server reachability: a small dot
/// (online / unreachable / checking). Tapping it opens a server details popup
/// where connection info is shown and a Refresh button can re-probe the server.
class SourceStatusButton extends ConsumerWidget {
  const SourceStatusButton({super.key, required this.sourceId});

  final String sourceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final reachable = ref.watch(sourceReachableProvider(sourceId));
    final Color color = switch (reachable) {
      AsyncData(:final value) =>
        value ? const Color(0xFF3FB950) : scheme.error,
      AsyncError() => scheme.error,
      _ => scheme.onSurfaceVariant,
    };
    return IconButton(
      tooltip: switch (reachable) {
        AsyncData(:final value) => value
            ? context.l10n.serverOnlineTooltip
            : context.l10n.serverUnreachableTooltip,
        AsyncError() => context.l10n.serverUnreachableTooltip,
        _ => context.l10n.serverCheckingTooltip,
      },
      onPressed: () => showDialog<void>(
        context: context,
        builder: (_) => ServerDetailsDialog(sourceId: sourceId),
      ),
      icon: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}
