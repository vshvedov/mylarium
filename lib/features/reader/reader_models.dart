/// Reading layout mode. Stored as `.name`.
enum ReadingMode { pagedLtr, pagedRtl, webtoon, webtoonGaps, doublePage }

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
  });

  final ReadingMode mode;
  final FitMode fit;
  final TapZonePreset taps;
  final bool invertTaps;
  final bool doubleTapZoom;
  final bool animatePageTurn;

  ReaderSettings copyWith({
    ReadingMode? mode,
    FitMode? fit,
    TapZonePreset? taps,
    bool? invertTaps,
    bool? doubleTapZoom,
    bool? animatePageTurn,
  }) =>
      ReaderSettings(
        mode: mode ?? this.mode,
        fit: fit ?? this.fit,
        taps: taps ?? this.taps,
        invertTaps: invertTaps ?? this.invertTaps,
        doubleTapZoom: doubleTapZoom ?? this.doubleTapZoom,
        animatePageTurn: animatePageTurn ?? this.animatePageTurn,
      );

  /// Defaults for a series. [mangaDirection] is the ComicInfo `Manga` /
  /// Komga `readingDirection` hint when known (seeds RTL); null in T4 until
  /// ComicInfo parsing lands (T7), so this currently always returns LTR
  /// defaults unless a hint is supplied.
  factory ReaderSettings.defaults({String? mangaDirection}) {
    final rtl = mangaDirection == 'RIGHT_TO_LEFT';
    return ReaderSettings(
      mode: rtl ? ReadingMode.pagedRtl : ReadingMode.pagedLtr,
    );
  }

  static ReaderSettings fromColumns({
    required String mode,
    required String fit,
    required String taps,
    required bool invertTaps,
    required bool doubleTapZoom,
    required bool animatePageTurn,
  }) =>
      ReaderSettings(
        mode: _enumByName(ReadingMode.values, mode, ReadingMode.pagedLtr),
        fit: _enumByName(FitMode.values, fit, FitMode.screen),
        taps: _enumByName(TapZonePreset.values, taps, TapZonePreset.lrEdges),
        invertTaps: invertTaps,
        doubleTapZoom: doubleTapZoom,
        animatePageTurn: animatePageTurn,
      );
}
