import 'dart:io' show Platform;

import 'package:flutter/services.dart';

/// One mounted removable volume (SD card, USB drive) reported by Android's
/// StorageManager. [initialUri] (API 29+) positions the SAF folder picker at
/// the volume's root; null on older Android (the picker opens at its default).
class RemovableVolume {
  const RemovableVolume({
    required this.description,
    this.uuid,
    this.initialUri,
  });

  /// User-facing name, e.g. "SD card".
  final String description;
  final String? uuid;
  final String? initialUri;
}

/// Queries mounted removable volumes via the `mylarium/storage` channel.
/// Android-only by nature: every other platform reports none, so callers can
/// gate the "use SD card" affordance on a simple emptiness check.
class StorageVolumes {
  const StorageVolumes();

  static const _channel = MethodChannel('mylarium/storage');

  Future<List<RemovableVolume>> removable() async {
    if (!Platform.isAndroid) return const [];
    try {
      final raw = await _channel.invokeListMethod<Map<Object?, Object?>>(
        'removableVolumes',
      );
      return [
        for (final m in raw ?? const <Map<Object?, Object?>>[])
          RemovableVolume(
            description: (m['description'] as String?) ?? 'SD card',
            uuid: m['uuid'] as String?,
            initialUri: m['initialUri'] as String?,
          ),
      ];
    } on PlatformException {
      // Detection is a convenience; a probe failure just hides the shortcut.
      return const [];
    } on MissingPluginException {
      return const [];
    }
  }
}
