import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/theme/theme_controller.dart' show appDatabaseProvider;

part 'settings_providers.g.dart';

/// Human-readable app version, e.g. "1.0.7 (8)". Read from the installed
/// bundle (Info.plist / AndroidManifest), so it reflects the actual build.
@riverpod
Future<String> appVersionLabel(Ref ref) async {
  final info = await PackageInfo.fromPlatform();
  return '${info.version} (${info.buildNumber})';
}

/// Whether reaching the last page auto-loads the next book in the series (T2).
/// Global, reactive: the reader reads it to decide whether to count down at the
/// end-of-book seam, and the settings screen toggles it.
@riverpod
Stream<bool> autoAdvanceEnabled(Ref ref) =>
    ref.watch(appDatabaseProvider).watchSettings().map((s) => s.autoAdvance);
