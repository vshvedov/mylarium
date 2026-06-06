import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/platform/diagnostics_prefs.dart';

part 'show_debug_info.g.dart';

/// The "Show debug info" preference (persisted in the diagnostics store, not the
/// content database). When on, the reader and settings surface diagnostics such
/// as the probed GPU max texture size.
@Riverpod(keepAlive: true)
class ShowDebugInfo extends _$ShowDebugInfo {
  @override
  bool build() {
    _load();
    return false;
  }

  Future<void> _load() async {
    state = await DiagnosticsPrefs.readShowDebugInfo();
  }

  Future<void> set(bool value) async {
    state = value;
    await DiagnosticsPrefs.writeShowDebugInfo(value);
  }
}
