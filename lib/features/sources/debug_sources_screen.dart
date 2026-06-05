import 'package:flutter/material.dart';
import '../../app/theme/app_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/theme_controller.dart' show appDatabaseProvider;
import '../../core/db/database.dart';
import '../../core/network/komga_exception.dart';
import '../../data/komga/komga_providers.dart';
import '../../data/repositories/series_repository.dart';

/// The only browse surface in T2: lists persisted sources and, on tap, refreshes
/// a source's series so the round trip (connect -> fetch -> persist -> display)
/// is verifiable end to end. The real library UI is T3.
class DebugSourcesScreen extends ConsumerStatefulWidget {
  const DebugSourcesScreen({super.key});

  @override
  ConsumerState<DebugSourcesScreen> createState() =>
      _DebugSourcesScreenState();
}

class _DebugSourcesScreenState extends ConsumerState<DebugSourcesScreen> {
  String? _selectedSourceId;
  int? _total;
  String? _error;
  bool _loading = false;

  Future<void> _refresh(Source source) async {
    setState(() {
      _selectedSourceId = source.id;
      _loading = true;
      _error = null;
      _total = null;
    });
    try {
      final credential =
          await ref.read(komgaCredentialStoreProvider).read(source.id);
      if (credential == null) {
        // Row-without-secret: send the user back to re-authenticate.
        if (mounted) {
          context.go(Uri(
            path: '/onboarding/komga',
            queryParameters: {'url': source.baseUrl ?? ''},
          ).toString());
        }
        return;
      }
      final api = ref.read(komgaApiFactoryProvider)(
        baseUrl: source.baseUrl!,
        auth: credential.toAuth(),
      );
      final repo = SeriesRepository(ref.read(appDatabaseProvider), api);
      final total = await repo.refresh(source.id);
      if (mounted) setState(() => _total = total);
    } on KomgaException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(appDatabaseProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sources (debug)'),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.add),
            onPressed: () => context.go('/onboarding'),
            tooltip: 'Add source',
          ),
        ],
      ),
      body: StreamBuilder<List<Source>>(
        stream: db.watchSources(),
        builder: (context, snapshot) {
          final sources = snapshot.data ?? const [];
          if (sources.isEmpty) {
            return const Center(child: Text('No sources yet.'));
          }
          return Column(
            children: [
              for (final source in sources)
                ListTile(
                  title: Text(source.label),
                  subtitle: Text(source.baseUrl ?? source.kind),
                  selected: source.id == _selectedSourceId,
                  trailing: _loading && source.id == _selectedSourceId
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(AppIcons.refresh),
                  onTap: _loading ? null : () => _refresh(source),
                ),
              const Divider(height: 1),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _error!,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              if (_selectedSourceId != null)
                Expanded(child: _SeriesList(sourceId: _selectedSourceId!, total: _total)),
            ],
          );
        },
      ),
    );
  }
}

class _SeriesList extends ConsumerWidget {
  const _SeriesList({required this.sourceId, this.total});

  final String sourceId;
  final int? total;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    return StreamBuilder<List<SeriesRow>>(
      stream: db.watchSeries(sourceId),
      builder: (context, snapshot) {
        final series = snapshot.data ?? const [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Showing ${series.length}'
                '${total == null ? '' : ' of $total'} series',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: series.length,
                itemBuilder: (context, i) =>
                    ListTile(dense: true, title: Text(series[i].title)),
              ),
            ),
          ],
        );
      },
    );
  }
}
