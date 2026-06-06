import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/core/fs/app_paths.dart';
import 'package:mylarium/core/platform/diagnostics_prefs.dart';

void main() {
  late Directory tmp;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('diag_prefs_test');
    AppPaths.debugOverrideRoot = tmp.path;
  });

  tearDown(() async {
    AppPaths.debugOverrideRoot = null;
    if (tmp.existsSync()) await tmp.delete(recursive: true);
  });

  test('max texture size defaults to null then round-trips', () async {
    expect(await DiagnosticsPrefs.readMaxTextureSize(), isNull);
    await DiagnosticsPrefs.writeMaxTextureSize(16384);
    expect(await DiagnosticsPrefs.readMaxTextureSize(), 16384);
  });

  test('a later write overwrites the cached value', () async {
    await DiagnosticsPrefs.writeMaxTextureSize(8192);
    expect(await DiagnosticsPrefs.readMaxTextureSize(), 8192);
    await DiagnosticsPrefs.writeMaxTextureSize(4096);
    expect(await DiagnosticsPrefs.readMaxTextureSize(), 4096);
  });
}
