import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n.dart';
import '../../app/theme/app_icons.dart';
import '../../app/theme/theme_controller.dart' show appDatabaseProvider;
import '../../data/source/content_source.dart';
import '../../data/source/models/server_details.dart';
import '../sync/sync_providers.dart';
import 'reachability.dart';
import 'server_details.dart';
import 'sync_status_providers.dart';

/// Centered dialog showing everything fetchable about the active source's
/// server, opened from the app-bar status dot. Fetches on open; Refresh
/// re-fetches and re-syncs the app-bar dot. Read-only.
class ServerDetailsDialog extends ConsumerWidget {
  const ServerDetailsDialog({super.key, required this.sourceId});

  final String sourceId;

  static const _online = Color(0xFF3FB950); // matches the app-bar dot

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(serverDetailsProvider(sourceId));
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: async.when(
            loading: () => const SizedBox(
              height: 160,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => _Frame(
              sourceId: sourceId,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(context.l10n.serverDetailsLoadError),
              ),
            ),
            data: (d) => _Body(details: d, sourceId: sourceId),
          ),
        ),
      ),
    );
  }
}

/// Footer (Refresh + Close) shared by the body and the error frame.
class _Frame extends ConsumerWidget {
  const _Frame({required this.sourceId, required this.child});

  final String sourceId;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(child: SingleChildScrollView(child: child)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              icon: const Icon(AppIcons.refresh, size: 18),
              label: Text(context.l10n.refresh),
              onPressed: () {
                ref.invalidate(serverDetailsProvider(sourceId));
                ref.invalidate(sourceReachableProvider(sourceId));
              },
            ),
            const SizedBox(width: 4),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.l10n.close),
            ),
          ],
        ),
      ],
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.details, required this.sourceId});

  final ServerDetails details;
  final String sourceId;

  IconData get _kindIcon => switch (details.kind) {
        SourceKind.kavita => AppIcons.sourceKavita,
        _ => AppIcons.sourceKomga,
      };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final f = details.facts;

    final l10n = context.l10n;
    final sections = <Widget>[
      _section(context, l10n.serverSectionConnection, [
        if (details.baseUrl.isNotEmpty)
          (label: l10n.serverRowUrl, value: details.baseUrl),
      ]),
    ];

    if (details.online) {
      sections.add(_section(context, l10n.serverSectionServer, [
        if (f.version != null) (label: l10n.serverRowVersion, value: f.version!),
        ...f.extra,
      ]));
      sections.add(_section(context, l10n.serverSectionAccount, [
        if (f.account != null) (label: l10n.serverRowUser, value: f.account!),
        if (f.roles.isNotEmpty)
          (
            label: l10n.serverRowRoles,
            value: (f.roles.toList()..sort()).join(', ')
          ),
      ]));
      sections.add(_section(context, l10n.serverSectionContent, [
        if (f.libraryNames.isNotEmpty)
          (
            label: l10n.serverRowLibraries,
            value:
                '${f.libraryNames.length} (${f.libraryNames.take(3).join(', ')}${f.libraryNames.length > 3 ? '...' : ''})'
          ),
        if (f.totalSeries != null)
          (label: l10n.serverRowSeries, value: '${f.totalSeries}'),
        if (f.totalBooks != null)
          (label: l10n.serverRowBooks, value: '${f.totalBooks}'),
      ]));
    } else {
      sections.add(Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 8),
        child: Text(
          l10n.serverUnreachableBody,
          style: TextStyle(color: scheme.error),
        ),
      ));
    }

    // Queued/dead-lettered write-backs; renders nothing while the queue is
    // empty. Shown offline too: that is exactly when updates pile up.
    sections.add(_SyncSection(sourceId: sourceId));

    return _Frame(
      sourceId: sourceId,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_kindIcon, size: 22, color: scheme.onSurfaceVariant),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  details.label.isEmpty
                      ? context.l10n.serverSectionServer
                      : details.label,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _StatusPill(online: details.online),
            ],
          ),
          const SizedBox(height: 12),
          ...sections,
        ],
      ),
    );
  }

  /// Renders a titled group only when it has at least one row.
  static Widget _section(
    BuildContext context,
    String title,
    List<ServerDetailRow> rows,
  ) {
    final visible = rows.where((r) => r.value.isNotEmpty).toList();
    if (visible.isEmpty) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  letterSpacing: 0.8,
                ),
          ),
          const SizedBox(height: 4),
          for (final r in visible)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 96,
                    child: Text(r.label,
                        style: TextStyle(color: scheme.onSurfaceVariant)),
                  ),
                  Expanded(child: Text(r.value)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// SYNC section: surfaces queued and dead-lettered write-backs for this
/// source. Hidden entirely while the queue is empty (the common case).
/// "Retry now" flips failed rows back to pending and drains the queue.
class _SyncSection extends ConsumerStatefulWidget {
  const _SyncSection({required this.sourceId});

  final String sourceId;

  @override
  ConsumerState<_SyncSection> createState() => _SyncSectionState();
}

class _SyncSectionState extends ConsumerState<_SyncSection> {
  bool _retrying = false;

  Future<void> _retry() async {
    setState(() => _retrying = true);
    try {
      await retryFailedSync(ref.read(appDatabaseProvider), widget.sourceId);
      final engine = await ref.read(syncEngineProvider.future);
      await engine.flushQueue();
    } finally {
      if (mounted) setState(() => _retrying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status =
        ref.watch(syncQueueStatusProvider(widget.sourceId)).valueOrNull;
    if (status == null || status.total == 0) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.syncSectionTitle,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  letterSpacing: 0.8,
                ),
          ),
          const SizedBox(height: 4),
          if (status.pending > 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(context.l10n.syncUpdatesWaiting(status.pending)),
            ),
          if (status.failed > 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                context.l10n.syncFailedCount(status.failed),
                style: TextStyle(color: scheme.error),
              ),
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: _retrying ? null : _retry,
              child: Text(context.l10n.syncRetryNow),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.online});

  final bool online;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = online ? ServerDetailsDialog._online : scheme.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 6),
          Text(online ? context.l10n.statusOnline : context.l10n.statusOffline,
              style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
