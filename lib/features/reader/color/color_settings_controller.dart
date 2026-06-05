import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/theme/theme_controller.dart' show appDatabaseProvider;
import 'color_settings.dart';
import 'color_settings_repository.dart';

part 'color_settings_controller.g.dart';

/// Owns the reader's live color-correction state for one book: the resolved
/// effective adjustment, the value being edited at the active scope, and the
/// session-only quick on/off. Mutations persist through
/// [ColorSettingsRepository] and re-resolve (mirrors `ReaderController`'s
/// AsyncNotifier mutate pattern).
@riverpod
class ColorSettingsController extends _$ColorSettingsController {
  late String _sourceId;
  late String _seriesId;
  late String _bookId;

  ColorSettingsRepository get _repo =>
      ColorSettingsRepository(ref.read(appDatabaseProvider));

  @override
  Future<ColorState> build(
    String sourceId,
    String seriesId,
    String bookId,
  ) async {
    _sourceId = sourceId;
    _seriesId = seriesId;
    _bookId = bookId;
    final repo = _repo;
    // Fetch each scope's row once, then derive resolved + the default editing
    // scope from those rows (no redundant re-reads).
    final global = await repo.forScope(const ColorScope.global());
    final series = seriesId.isNotEmpty
        ? await repo.forScope(ColorScope.series(sourceId, seriesId))
        : null;
    final book = bookId.isNotEmpty
        ? await repo.forScope(ColorScope.book(sourceId, bookId))
        : null;
    final resolved = resolveColorSettings(global, series, book);
    // Default to the most specific scope that already has a saved row.
    final (scopeKind, scopeValue) = book != null
        ? (ColorScopeKind.book, book)
        : series != null
            ? (ColorScopeKind.series, series)
            : (ColorScopeKind.global, global);
    return ColorState(
      resolved: resolved,
      editing: scopeValue ?? resolved,
      editingScope: scopeKind,
      enabled: true,
    );
  }

  /// Persists [adj] at the active editing scope, re-resolves, and updates state.
  Future<void> apply(ColorAdjustments adj) async {
    final st = state.valueOrNull;
    if (st == null) return;
    final repo = _repo;
    await repo.save(_scope(st.editingScope), adj);
    final resolved = await repo.resolve(_sourceId, _seriesId, _bookId);
    state = AsyncData(st.copyWith(resolved: resolved, editing: adj));
  }

  /// Switches the editing scope; shows that scope's saved value, or the
  /// inherited resolved value when it has no row.
  Future<void> setScope(ColorScopeKind kind) async {
    final st = state.valueOrNull;
    if (st == null) return;
    final editing = (await _repo.forScope(_scope(kind))) ?? st.resolved;
    state = AsyncData(st.copyWith(editingScope: kind, editing: editing));
  }

  /// Resets (deletes) the active editing scope's row; re-resolves.
  Future<void> reset() async {
    final st = state.valueOrNull;
    if (st == null) return;
    final repo = _repo;
    await repo.reset(_scope(st.editingScope));
    final resolved = await repo.resolve(_sourceId, _seriesId, _bookId);
    state = AsyncData(st.copyWith(resolved: resolved, editing: resolved));
  }

  /// Quick on/off (session-only; not persisted). Reseeds to true on a provider
  /// rebuild (a new book).
  void setEnabled(bool v) {
    final st = state.valueOrNull;
    if (st == null) return;
    state = AsyncData(st.copyWith(enabled: v));
  }

  ColorScope _scope(ColorScopeKind kind) => switch (kind) {
        ColorScopeKind.global => const ColorScope.global(),
        ColorScopeKind.series => ColorScope.series(_sourceId, _seriesId),
        ColorScopeKind.book => ColorScope.book(_sourceId, _bookId),
      };
}
