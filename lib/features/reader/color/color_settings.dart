import 'package:flutter/foundation.dart';

/// Page color-correction mode. Stored as `.name`.
enum ColorMode { none, grayscale, sepia, invert }

/// An immutable set of reader page color adjustments. All math is defined on
/// normalized channel values in [0, 1] (see `color_math.dart`); the fields here
/// are the user-facing parameters.
///
/// - [brightness] in [-1, 1] (additive offset; 0 = unchanged).
/// - [contrast] in [-1, 1] (factor `1 + contrast` about 0.5; 0 = unchanged).
/// - [gamma] in [0.4, 2.5] (`out = pow(in, 1/gamma)`; 1 = unchanged). Non-affine.
/// - [mode] a tone mode (none/grayscale/sepia/invert).
/// - [autoLevels] white-point/levels stretch from a per-page histogram.
///   Non-affine (needs the decoded pixels).
@immutable
class ColorAdjustments {
  const ColorAdjustments({
    this.brightness = 0,
    this.contrast = 0,
    this.gamma = 1,
    this.mode = ColorMode.none,
    this.autoLevels = false,
  });

  final double brightness;
  final double contrast;
  final double gamma;
  final ColorMode mode;
  final bool autoLevels;

  /// The neutral default: applying it is a no-op (the pipeline is skipped).
  static const identity = ColorAdjustments();

  /// True when this is the neutral default (nothing to apply).
  bool get isIdentity =>
      brightness == 0 &&
      contrast == 0 &&
      gamma == 1.0 &&
      mode == ColorMode.none &&
      !autoLevels;

  /// True when every adjustment is expressible as a single 4x5 color matrix
  /// (a GPU `ColorFilter.matrix`): no gamma, no auto-levels. Brightness,
  /// contrast, and mode are all affine.
  bool get isAffineOnly => !autoLevels && gamma == 1.0;

  ColorAdjustments copyWith({
    double? brightness,
    double? contrast,
    double? gamma,
    ColorMode? mode,
    bool? autoLevels,
  }) =>
      ColorAdjustments(
        brightness: brightness ?? this.brightness,
        contrast: contrast ?? this.contrast,
        gamma: gamma ?? this.gamma,
        mode: mode ?? this.mode,
        autoLevels: autoLevels ?? this.autoLevels,
      );

  /// A stable cache-key fragment, fields rounded to 2 decimal places. This is
  /// the intentional cache-equality granularity for the corrected-image
  /// provider: sub-0.01 deltas collapse to one cache entry. Slider steps are
  /// >= 0.05, so distinct user values never collide.
  String get signature =>
      'b${brightness.toStringAsFixed(2)}_c${contrast.toStringAsFixed(2)}'
      '_g${gamma.toStringAsFixed(2)}_m${mode.name}_a${autoLevels ? 1 : 0}';

  @override
  bool operator ==(Object other) =>
      other is ColorAdjustments &&
      other.brightness == brightness &&
      other.contrast == contrast &&
      other.gamma == gamma &&
      other.mode == mode &&
      other.autoLevels == autoLevels;

  @override
  int get hashCode =>
      Object.hash(brightness, contrast, gamma, mode, autoLevels);
}

/// Which tier a set of adjustments applies to. Most specific wins.
enum ColorScopeKind { global, series, book }

/// Identifies a persisted color-settings row. `global` is app-wide
/// (sourceId and id empty); `series`/`book` carry the owning ids.
@immutable
class ColorScope {
  const ColorScope.global()
      : kind = ColorScopeKind.global,
        sourceId = '',
        id = '';
  const ColorScope.series(this.sourceId, this.id)
      : kind = ColorScopeKind.series;
  const ColorScope.book(this.sourceId, this.id) : kind = ColorScopeKind.book;

  final ColorScopeKind kind;
  final String sourceId;
  final String id;

  @override
  bool operator ==(Object other) =>
      other is ColorScope &&
      other.kind == kind &&
      other.sourceId == sourceId &&
      other.id == id;

  @override
  int get hashCode => Object.hash(kind, sourceId, id);
}

/// Resolves the effective adjustments by precedence: the most specific
/// non-null scope wins as a whole record (no field-level merge). Pure and
/// unit-tested.
ColorAdjustments resolveColorSettings(
  ColorAdjustments? global,
  ColorAdjustments? series,
  ColorAdjustments? chapter,
) =>
    chapter ?? series ?? global ?? ColorAdjustments.identity;

/// Splits [adj] into the part applied per-frame on the GPU (affine: contrast,
/// brightness, mode) and the part baked at decode time off the UI isolate
/// (residual: levels via auto-levels, and gamma). The pipeline order is
/// levels -> gamma -> contrast -> brightness -> mode, so the residual prefix
/// (levels, gamma) is baked into the decoded image and the affine suffix
/// (contrast, brightness, mode) is layered on at render via a `ColorFilter`.
({ColorAdjustments affine, ColorAdjustments residual}) splitAdjustments(
  ColorAdjustments adj,
) =>
    (
      affine: ColorAdjustments(
        brightness: adj.brightness,
        contrast: adj.contrast,
        mode: adj.mode,
      ),
      residual: ColorAdjustments(
        gamma: adj.gamma,
        autoLevels: adj.autoLevels,
      ),
    );

/// Reader-session color state held by the controller. [resolved] is the active
/// effective adjustment; [editing] is the value shown/edited at [editingScope]
/// (the inherited [resolved] when that scope has no row); [enabled] is the
/// session-only quick on/off.
@immutable
class ColorState {
  const ColorState({
    required this.resolved,
    required this.editing,
    required this.editingScope,
    required this.enabled,
  });

  final ColorAdjustments resolved;
  final ColorAdjustments editing;
  final ColorScopeKind editingScope;
  final bool enabled;

  ColorState copyWith({
    ColorAdjustments? resolved,
    ColorAdjustments? editing,
    ColorScopeKind? editingScope,
    bool? enabled,
  }) =>
      ColorState(
        resolved: resolved ?? this.resolved,
        editing: editing ?? this.editing,
        editingScope: editingScope ?? this.editingScope,
        enabled: enabled ?? this.enabled,
      );
}
