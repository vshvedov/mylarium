import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/theme/theme_controller.dart' show appDatabaseProvider;
import 'color_settings.dart';
import 'color_settings_repository.dart';

part 'color_settings_controller.g.dart';

/// Owns the reader's live color-correction state for one book: the resolved
/// effective adjustment (what the reader renders, updated live while editing),
/// the value being edited at the active scope, and that scope's persisted
/// on/off. [preview] updates the effective adjustment in memory (for real-time
/// slider feedback) without touching the DB; [commit] persists.
@riverpod
class ColorSettingsController extends _$ColorSettingsController {
  late String _sourceId;
  late String _seriesId;
  late String _bookId;

  // In-memory mirror of the three scope rows, loaded in build and kept current
  // by mutations, so resolution and previews never re-query.
  ScopedColor? _global;
  ScopedColor? _series;
  ScopedColor? _book;

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
    _global = await repo.forScope(const ColorScope.global());
    _series = seriesId.isNotEmpty
        ? await repo.forScope(ColorScope.series(sourceId, seriesId))
        : null;
    _book = bookId.isNotEmpty
        ? await repo.forScope(ColorScope.book(sourceId, bookId))
        : null;
    // Default to the most specific scope that already has a saved row.
    final scopeKind = _book != null
        ? ColorScopeKind.book
        : _series != null
            ? ColorScopeKind.series
            : ColorScopeKind.global;
    return _stateFor(scopeKind);
  }

  /// Live, in-memory preview at the active scope (no DB write). Drives the
  /// reader's real-time slider feedback.
  void preview(ColorAdjustments adj) {
    final st = state.valueOrNull;
    if (st == null) return;
    _setScoped(st.editingScope, ScopedColor(adj, st.editingEnabled));
    state = AsyncData(st.copyWith(resolved: _effective(), editing: adj));
  }

  /// Persists [adj] at the active scope (and its current enable flag).
  Future<void> commit(ColorAdjustments adj) async {
    final st = state.valueOrNull;
    if (st == null) return;
    preview(adj);
    await _repo.save(_scope(st.editingScope), adj, enabled: st.editingEnabled);
  }

  /// Toggles the active scope's persisted on/off (creating its row from the
  /// current editing values if it has none).
  Future<void> setEnabled(bool enabled) async {
    final st = state.valueOrNull;
    if (st == null) return;
    _setScoped(st.editingScope, ScopedColor(st.editing, enabled));
    state = AsyncData(
      st.copyWith(editingEnabled: enabled, resolved: _effective()),
    );
    await _repo.save(_scope(st.editingScope), st.editing, enabled: enabled);
  }

  /// Switches the editing scope; shows that scope's saved value (or the
  /// inherited effective value when it has no row) without a DB write.
  void setScope(ColorScopeKind kind) {
    final st = state.valueOrNull;
    if (st == null) return;
    state = AsyncData(_stateFor(kind).copyWith(resolved: _effective()));
  }

  /// Resets (deletes) the active scope's row; re-resolves and shows inherited.
  Future<void> reset() async {
    final st = state.valueOrNull;
    if (st == null) return;
    final scope = st.editingScope;
    _setScoped(scope, null);
    await _repo.reset(_scope(scope));
    final inherited = _effective();
    state = AsyncData(ColorState(
      resolved: inherited,
      editing: inherited,
      editingScope: scope,
      editingEnabled: true,
    ));
  }

  // --- internals -----------------------------------------------------------

  /// Builds the state for editing [kind]: editing value + enable from that
  /// scope's row, or the inherited effective value when it has no row.
  ColorState _stateFor(ColorScopeKind kind) {
    final scoped = _scopedFor(kind);
    final effective = _effective();
    return ColorState(
      resolved: effective,
      editing: scoped?.adjustments ?? effective,
      editingScope: kind,
      editingEnabled: scoped?.enabled ?? true,
    );
  }

  ColorAdjustments _effective() => resolveScopedColor(_global, _series, _book);

  ScopedColor? _scopedFor(ColorScopeKind kind) => switch (kind) {
        ColorScopeKind.global => _global,
        ColorScopeKind.series => _series,
        ColorScopeKind.book => _book,
      };

  void _setScoped(ColorScopeKind kind, ScopedColor? value) {
    switch (kind) {
      case ColorScopeKind.global:
        _global = value;
      case ColorScopeKind.series:
        _series = value;
      case ColorScopeKind.book:
        _book = value;
    }
  }

  ColorScope _scope(ColorScopeKind kind) => switch (kind) {
        ColorScopeKind.global => const ColorScope.global(),
        ColorScopeKind.series => ColorScope.series(_sourceId, _seriesId),
        ColorScopeKind.book => ColorScope.book(_sourceId, _bookId),
      };
}
