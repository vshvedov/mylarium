import 'dart:convert';
import 'dart:io';

import '../fs/app_paths.dart';

/// A tiny JSON-file store for diagnostics state that does not belong in the
/// content database: the per-device probed GPU max texture size, so we do not
/// re-probe every launch. Kept out of the Drift `app_settings` table on purpose
/// (no schema migration for a device-derived cache value).
class DiagnosticsPrefs {
  const DiagnosticsPrefs._();

  static const _relPath = 'diagnostics.json';
  static const _kMaxTextureSize = 'maxTextureSize';

  static Future<Map<String, Object?>> _read() async {
    try {
      final file = File(await AppPaths.resolve(_relPath));
      if (!file.existsSync()) return <String, Object?>{};
      final decoded = jsonDecode(await file.readAsString());
      return decoded is Map<String, Object?> ? decoded : <String, Object?>{};
    } catch (_) {
      return <String, Object?>{};
    }
  }

  static Future<void> _write(Map<String, Object?> data) async {
    try {
      final file = await AppPaths.prepareFile(_relPath);
      await file.writeAsString(jsonEncode(data));
    } catch (_) {
      // Diagnostics persistence is best-effort; never fail the caller.
    }
  }

  static Future<int?> readMaxTextureSize() async {
    final v = (await _read())[_kMaxTextureSize];
    return v is int ? v : null;
  }

  static Future<void> writeMaxTextureSize(int value) async {
    final data = await _read();
    data[_kMaxTextureSize] = value;
    await _write(data);
  }
}
