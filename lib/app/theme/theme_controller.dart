import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/db/database.dart';

part 'theme_controller.g.dart';

enum AppThemeMode { light, dark, system }

ThemeMode toThemeMode(AppThemeMode m) => switch (m) {
      AppThemeMode.light => ThemeMode.light,
      AppThemeMode.dark => ThemeMode.dark,
      AppThemeMode.system => ThemeMode.system,
    };

AppThemeMode _parse(String s) => switch (s) {
      'light' => AppThemeMode.light,
      'dark' => AppThemeMode.dark,
      _ => AppThemeMode.system,
    };

/// Injected in main() via overrideWithValue; throws until overridden so a
/// missing override fails loudly instead of silently.
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) =>
    throw UnimplementedError('override appDatabaseProvider in main');

/// The settings row read once at boot and injected; the controllers seed from
/// it. Written values flow back through the controller setters.
@Riverpod(keepAlive: true)
AppSetting initialSettings(Ref ref) =>
    throw UnimplementedError('override initialSettingsProvider in main');

@riverpod
class ThemeController extends _$ThemeController {
  @override
  AppThemeMode build() => _parse(ref.read(initialSettingsProvider).themeMode);

  Future<void> set(AppThemeMode m) async {
    await ref.read(appDatabaseProvider).updateThemeMode(m.name);
    state = m;
  }
}

@riverpod
class ReduceMotion extends _$ReduceMotion {
  @override
  bool build() => ref.read(initialSettingsProvider).reduceMotionOverride;

  Future<void> set(bool v) async {
    await ref.read(appDatabaseProvider).updateReduceMotionOverride(v);
    state = v;
  }
}
