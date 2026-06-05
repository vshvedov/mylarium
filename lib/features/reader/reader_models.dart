/// Reading layout mode. Stored as `.name`.
enum ReadingMode { pagedLtr, pagedRtl, webtoon, webtoonGaps, doublePage }

/// Horizontal reading direction. The single source of truth for direction across
/// modes: paged modes also encode it in their enum suffix (kept in lockstep by the
/// settings normalizer), double-page reads this field. Stored as `.name`.
enum ReadingDirection { ltr, rtl }

/// How a page is fitted to the viewport.
enum FitMode { width, height, screen, original }

/// Named tap-zone presets (>= 5). Each maps a normalized tap position to a
/// [TapAction]. See `gestures/tap_zones.dart` for the geometry.
enum TapZonePreset { lrEdges, lmr, kindleStyle, edgeTopBottom, halves }

/// What a tap resolves to.
enum TapAction { prev, next, toggleChrome }

extension ReadingModeX on ReadingMode {
  bool get isPaged =>
      this == ReadingMode.pagedLtr ||
      this == ReadingMode.pagedRtl ||
      this == ReadingMode.doublePage;
  bool get isWebtoon =>
      this == ReadingMode.webtoon || this == ReadingMode.webtoonGaps;
  bool get isRtl => this == ReadingMode.pagedRtl;
}

/// The effective horizontal reading direction for rendering and gestures. Paged
/// modes carry it in the enum; double-page reads [ReaderSettings.direction]. Both
/// agree for paged modes because the settings normalizer keeps them in lockstep.
/// Webtoon variants are never RTL here (direction is moot for vertical scroll).
bool effectiveRtl(ReaderSettings s) =>
    s.mode.isRtl ||
    (s.mode == ReadingMode.doublePage && s.direction == ReadingDirection.rtl);

T _enumByName<T extends Enum>(List<T> values, String? name, T fallback) {
  for (final v in values) {
    if (v.name == name) return v;
  }
  return fallback;
}

/// Per-series reader preferences (the domain object; persisted via the
/// `reader_settings` Drift table).
class ReaderSettings {
  const ReaderSettings({
    this.mode = ReadingMode.pagedLtr,
    this.fit = FitMode.screen,
    this.taps = TapZonePreset.lrEdges,
    this.invertTaps = false,
    this.doubleTapZoom = true,
    this.animatePageTurn = true,
    this.direction = ReadingDirection.ltr,
  });

  final ReadingMode mode;
  final FitMode fit;
  final TapZonePreset taps;
  final bool invertTaps;
  final bool doubleTapZoom;
  final bool animatePageTurn;

  /// Horizontal reading direction (single source of truth; see [effectiveRtl]).
  final ReadingDirection direction;

  ReaderSettings copyWith({
    ReadingMode? mode,
    FitMode? fit,
    TapZonePreset? taps,
    bool? invertTaps,
    bool? doubleTapZoom,
    bool? animatePageTurn,
    ReadingDirection? direction,
  }) =>
      ReaderSettings(
        mode: mode ?? this.mode,
        fit: fit ?? this.fit,
        taps: taps ?? this.taps,
        invertTaps: invertTaps ?? this.invertTaps,
        doubleTapZoom: doubleTapZoom ?? this.doubleTapZoom,
        animatePageTurn: animatePageTurn ?? this.animatePageTurn,
        direction: direction ?? this.direction,
      );

  /// Defaults for a series. [mangaDirection] is the source's reading-direction
  /// hint when known: Komga `metadata.readingDirection` (phase 1) or, later,
  /// the ComicInfo `Manga` flag for local files (T7). Null falls back to LTR.
  factory ReaderSettings.defaults({String? mangaDirection}) {
    final mode = switch (mangaDirection) {
      'RIGHT_TO_LEFT' => ReadingMode.pagedRtl,
      'VERTICAL' || 'WEBTOON' => ReadingMode.webtoon,
      _ => ReadingMode.pagedLtr,
    };
    final direction = mangaDirection == 'RIGHT_TO_LEFT'
        ? ReadingDirection.rtl
        : ReadingDirection.ltr;
    return ReaderSettings(mode: mode, direction: direction);
  }

  static ReaderSettings fromColumns({
    required String mode,
    required String fit,
    required String taps,
    required bool invertTaps,
    required bool doubleTapZoom,
    required bool animatePageTurn,
    required String direction,
  }) =>
      ReaderSettings(
        mode: _enumByName(ReadingMode.values, mode, ReadingMode.pagedLtr),
        fit: _enumByName(FitMode.values, fit, FitMode.screen),
        taps: _enumByName(TapZonePreset.values, taps, TapZonePreset.lrEdges),
        invertTaps: invertTaps,
        doubleTapZoom: doubleTapZoom,
        animatePageTurn: animatePageTurn,
        direction:
            _enumByName(ReadingDirection.values, direction, ReadingDirection.ltr),
      );
}
