import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/theme/theme_controller.dart'
    show appDatabaseProvider, initialSettingsProvider;
import 'home_layout.dart';

part 'home_layout_controller.g.dart';

/// The persisted home-screen row layout (order + per-row visibility). Seeded from
/// the boot settings row and written through to the DB on every edit, so changes
/// are immediate (the home watches this) and survive restarts. Mirrors
/// [ThemeController]: read initial -> hold state -> setters persist + update.
@riverpod
class HomeLayoutController extends _$HomeLayoutController {
  @override
  List<HomeRailItem> build() =>
      decodeHomeLayout(ref.read(initialSettingsProvider).homeLayout);

  Future<void> _persist(List<HomeRailItem> next) async {
    state = next;
    await ref.read(appDatabaseProvider).updateHomeLayout(encodeHomeLayout(next));
  }

  /// Moves the row at [oldIndex] to [newIndex]. Expects ReorderableListView's
  /// `onReorderItem` semantics, where [newIndex] is already adjusted for the
  /// removed item, so no manual offset is needed.
  Future<void> reorder(int oldIndex, int newIndex) async {
    final next = [...state];
    final item = next.removeAt(oldIndex);
    next.insert(newIndex, item);
    await _persist(next);
  }

  /// Shows or hides a row.
  Future<void> setVisible(HomeRailKind kind, bool visible) async {
    final next = [
      for (final i in state)
        if (i.kind == kind) i.copyWith(visible: visible) else i,
    ];
    await _persist(next);
  }

  /// Restores the default order with every row visible.
  Future<void> resetToDefault() => _persist(defaultHomeLayout);
}

/// The rows that are currently visible, in order (drives the home rails).
@riverpod
List<HomeRailKind> visibleHomeRails(Ref ref) => [
      for (final i in ref.watch(homeLayoutControllerProvider))
        if (i.visible) i.kind,
    ];
