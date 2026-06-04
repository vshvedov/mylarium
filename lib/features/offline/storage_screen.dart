import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/theme_controller.dart'
    show appDatabaseProvider, initialSettingsProvider;
import '../../core/db/database.dart';
import 'offline_providers.dart';

String _fmtBytes(int b) {
  if (b < 1024) return '$b B';
  const units = ['KB', 'MB', 'GB'];
  var v = b / 1024;
  var i = 0;
  while (v >= 1024 && i < units.length - 1) {
    v /= 1024;
    i++;
  }
  return '${v.toStringAsFixed(1)} ${units[i]}';
}

/// Offline storage usage + per-book pin/delete and a cache-size cap.
class StorageScreen extends ConsumerStatefulWidget {
  const StorageScreen({super.key});

  @override
  ConsumerState<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends ConsumerState<StorageScreen> {
  @override
  Widget build(BuildContext context) {
    final db = ref.watch(appDatabaseProvider);
    final cache = ref.watch(offlineCacheManagerProvider);
    final capBytes = ref.watch(initialSettingsProvider).cacheCapBytes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Storage'),
        actions: [
          TextButton(
            onPressed: () async {
              await cache.evictToCap();
              if (context.mounted) setState(() {});
            },
            child: const Text('Evict now'),
          ),
        ],
      ),
      body: StreamBuilder<List<CachedAsset>>(
        stream: db.watchCachedAssets(),
        builder: (context, snap) {
          final assets = snap.data ?? const [];
          final total = assets.fold<int>(0, (s, a) => s + a.sizeBytes);
          return ListView(
            children: [
              ListTile(
                title: const Text('Used'),
                trailing: Text('${_fmtBytes(total)} / ${_fmtBytes(capBytes)}'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: LinearProgressIndicator(
                  value: capBytes == 0 ? 0 : (total / capBytes).clamp(0, 1),
                ),
              ),
              _CapControl(
                capBytes: capBytes,
                onChanged: (gib) async {
                  await db.updateCacheCapBytes(gib * 1024 * 1024 * 1024);
                  ref.invalidate(initialSettingsProvider);
                  if (context.mounted) setState(() {});
                },
              ),
              const Divider(),
              if (assets.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: Text('No downloaded books.')),
                ),
              for (final a in assets)
                ListTile(
                  title: Text(a.bookId),
                  subtitle: Text(_fmtBytes(a.sizeBytes)),
                  leading: IconButton(
                    icon: Icon(a.pinned ? Icons.push_pin : Icons.push_pin_outlined),
                    onPressed: () =>
                        cache.pin(a.sourceId, a.bookId, !a.pinned),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => cache.delete(a.sourceId, a.bookId),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _CapControl extends StatelessWidget {
  const _CapControl({required this.capBytes, required this.onChanged});

  final int capBytes;
  final void Function(int gib) onChanged;

  @override
  Widget build(BuildContext context) {
    final gib = (capBytes / (1024 * 1024 * 1024)).round().clamp(1, 50);
    return ListTile(
      title: const Text('Cache limit'),
      subtitle: Slider(
        min: 1,
        max: 50,
        divisions: 49,
        label: '$gib GB',
        value: gib.toDouble(),
        onChanged: (v) => onChanged(v.round()),
      ),
      trailing: Text('$gib GB'),
    );
  }
}
