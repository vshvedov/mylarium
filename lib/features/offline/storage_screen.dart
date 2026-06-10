import 'package:flutter/material.dart';
import '../../app/l10n.dart';
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
      appBar: AppBar(title: Text(context.l10n.storageTitle)),
      body: StreamBuilder<AppSetting>(
        stream: db.watchSettings(),
        builder: (context, settingsSnap) {
          final settings = settingsSnap.data;
          return StreamBuilder<List<({CachedAsset asset, String? title})>>(
            stream: db.watchCachedAssetsWithTitles(),
            builder: (context, snap) {
              final assets = snap.data ?? const [];
              final auto =
                  assets.where((a) => !a.asset.permanent).toList();
              final downloads =
                  assets.where((a) => a.asset.permanent).toList();
              final autoTotal =
                  auto.fold<int>(0, (s, a) => s + a.asset.sizeBytes);
              final dlTotal =
                  downloads.fold<int>(0, (s, a) => s + a.asset.sizeBytes);
              final cap = settings?.cacheCapBytes ?? 0;

              return ListView(
                children: [
                  if (settings != null) ...[
                    SwitchListTile(
                      title: Text(context.l10n.storageAutoDownload),
                      subtitle: Text(context.l10n.storageAutoDownloadSubtitle),
                      value: settings.autoCacheEnabled,
                      onChanged: (v) => db.updateAutoCacheEnabled(v),
                    ),
                    SwitchListTile(
                      title: Text(context.l10n.storageAutoDownloadWifi),
                      value: settings.downloadWifiOnly,
                      onChanged: (v) => db.updateDownloadWifiOnly(v),
                    ),
                    SwitchListTile(
                      title: Text(context.l10n.storageDeleteOnRead),
                      subtitle: Text(context.l10n.storageDeleteOnReadSubtitle),
                      value: settings.deleteOnRead ?? false,
                      onChanged: (v) => db.updateDeleteOnRead(v),
                    ),
                    _CapControl(
                      capBytes: cap,
                      onChanged: (gib) =>
                          db.updateCacheCapBytes(gib * 1024 * 1024 * 1024),
                    ),
                    _BookCapControl(
                      capMb: settings.autoCacheBookCapMb,
                      onChanged: (mb) => db.updateAutoCacheBookCapMb(mb),
                    ),
                  ],
                  const Divider(),
                  ListTile(
                    dense: true,
                    title: Text(context.l10n.storageAutoCache),
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
                    _EmptyRow(context.l10n.storageNoAutoCache)
                  else
                    for (final e in auto)
                      ListTile(
                        title: Text(e.title ?? e.asset.bookId),
                        subtitle: Text(_fmtBytes(e.asset.sizeBytes)),
                        leading: const Icon(AppIcons.savedOffline),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(AppIcons.download),
                              tooltip: context.l10n.storageKeepTooltip,
                              onPressed: () => ref
                                  .read(downloadManagerProvider)
                                  .enqueueBook(e.asset.sourceId, e.asset.bookId,
                                      manual: true),
                            ),
                            IconButton(
                              icon: const Icon(AppIcons.delete),
                              onPressed: () => cache.delete(
                                  e.asset.sourceId, e.asset.bookId),
                            ),
                          ],
                        ),
                      ),
                  const Divider(),
                  ListTile(
                    dense: true,
                    title: Text(context.l10n.storageDownloads),
                    subtitle: Text(context.l10n.storageDownloadsSubtitle),
                    trailing: Text(_fmtBytes(dlTotal)),
                  ),
                  if (downloads.isEmpty)
                    _EmptyRow(context.l10n.storageNoDownloads)
                  else
                    for (final e in downloads)
                      ListTile(
                        title: Text(e.title ?? e.asset.bookId),
                        subtitle: Text(_fmtBytes(e.asset.sizeBytes)),
                        leading: const Icon(AppIcons.downloaded),
                        trailing: IconButton(
                          icon: const Icon(AppIcons.delete),
                          onPressed: () =>
                              cache.delete(e.asset.sourceId, e.asset.bookId),
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
      title: Text(context.l10n.storageAutoCacheLimit),
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

/// Per-book auto-cache ceiling: a stepped slider over fixed MB stops, with a
/// final "No limit" stop that maps to 0 (see AppSettings.autoCacheBookCapMb).
class _BookCapControl extends StatelessWidget {
  const _BookCapControl({required this.capMb, required this.onChanged});

  static const _stops = [50, 100, 200, 300, 500, 1000, 0];

  final int capMb;
  final void Function(int mb) onChanged;

  static String _label(BuildContext context, int mb) =>
      mb == 0 ? context.l10n.storageNoLimit : '$mb MB';

  /// The slider index for [mb]: 0 maps to the trailing "No limit" stop; an
  /// off-grid value (never written by this control) snaps to the nearest stop
  /// at or above it.
  static int _indexFor(int mb) {
    if (mb <= 0) return _stops.length - 1;
    for (var i = 0; i < _stops.length - 1; i++) {
      if (mb <= _stops[i]) return i;
    }
    return _stops.length - 2;
  }

  @override
  Widget build(BuildContext context) {
    final index = _indexFor(capMb);
    return ListTile(
      title: Text(context.l10n.storagePerBookLimit),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.storagePerBookLimitSubtitle),
          Slider(
            min: 0,
            max: (_stops.length - 1).toDouble(),
            divisions: _stops.length - 1,
            label: _label(context, _stops[index]),
            value: index.toDouble(),
            onChanged: (v) => onChanged(_stops[v.round()]),
          ),
        ],
      ),
      trailing: Text(_label(context, capMb)),
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
