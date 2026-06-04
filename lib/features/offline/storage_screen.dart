import 'package:flutter/material.dart';
import '../../app/theme/app_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/theme_controller.dart' show appDatabaseProvider;
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

/// Offline storage: auto-cache settings (toggle + Wi-Fi-only + size cap) and the
/// two pools - auto-cached (evictable) and manual downloads (permanent).
class StorageScreen extends ConsumerWidget {
  const StorageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    final cache = ref.watch(offlineCacheManagerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Storage')),
      body: StreamBuilder<AppSetting>(
        stream: db.watchSettings(),
        builder: (context, settingsSnap) {
          final settings = settingsSnap.data;
          return StreamBuilder<List<CachedAsset>>(
            stream: db.watchCachedAssets(),
            builder: (context, snap) {
              final assets = snap.data ?? const [];
              final auto = assets.where((a) => !a.permanent).toList();
              final downloads = assets.where((a) => a.permanent).toList();
              final autoTotal = auto.fold<int>(0, (s, a) => s + a.sizeBytes);
              final dlTotal = downloads.fold<int>(0, (s, a) => s + a.sizeBytes);
              final cap = settings?.cacheCapBytes ?? 0;

              return ListView(
                children: [
                  if (settings != null) ...[
                    SwitchListTile(
                      title: const Text('Auto-download on open'),
                      subtitle: const Text(
                          'Cache chapters you open (within the size limit)'),
                      value: settings.autoCacheEnabled,
                      onChanged: (v) => db.updateAutoCacheEnabled(v),
                    ),
                    SwitchListTile(
                      title: const Text('Auto-download on Wi-Fi only'),
                      value: settings.downloadWifiOnly,
                      onChanged: (v) => db.updateDownloadWifiOnly(v),
                    ),
                    _CapControl(
                      capBytes: cap,
                      onChanged: (gib) =>
                          db.updateCacheCapBytes(gib * 1024 * 1024 * 1024),
                    ),
                  ],
                  const Divider(),
                  ListTile(
                    dense: true,
                    title: const Text('Auto-cache'),
                    trailing:
                        Text('${_fmtBytes(autoTotal)} / ${_fmtBytes(cap)}'),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: LinearProgressIndicator(
                      value: cap == 0 ? 0 : (autoTotal / cap).clamp(0, 1),
                    ),
                  ),
                  if (auto.isEmpty)
                    const _EmptyRow('No auto-cached chapters.')
                  else
                    for (final a in auto)
                      ListTile(
                        title: Text(a.bookId),
                        subtitle: Text(_fmtBytes(a.sizeBytes)),
                        leading: const Icon(AppIcons.savedOffline),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(AppIcons.download),
                              tooltip: 'Keep (move to Downloads)',
                              onPressed: () => ref
                                  .read(downloadManagerProvider)
                                  .enqueueBook(a.sourceId, a.bookId,
                                      manual: true),
                            ),
                            IconButton(
                              icon: const Icon(AppIcons.delete),
                              onPressed: () =>
                                  cache.delete(a.sourceId, a.bookId),
                            ),
                          ],
                        ),
                      ),
                  const Divider(),
                  ListTile(
                    dense: true,
                    title: const Text('Downloads'),
                    subtitle:
                        const Text('Kept until you remove them (no limit)'),
                    trailing: Text(_fmtBytes(dlTotal)),
                  ),
                  if (downloads.isEmpty)
                    const _EmptyRow('No downloaded chapters.')
                  else
                    for (final a in downloads)
                      ListTile(
                        title: Text(a.bookId),
                        subtitle: Text(_fmtBytes(a.sizeBytes)),
                        leading: const Icon(AppIcons.downloaded),
                        trailing: IconButton(
                          icon: const Icon(AppIcons.delete),
                          onPressed: () => cache.delete(a.sourceId, a.bookId),
                        ),
                      ),
                ],
              );
            },
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
      title: const Text('Auto-cache limit'),
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

class _EmptyRow extends StatelessWidget {
  const _EmptyRow(this.label);
  final String label;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text(label, style: Theme.of(context).textTheme.bodySmall),
      );
}
