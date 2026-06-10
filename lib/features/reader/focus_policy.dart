import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/platform/render_capabilities.dart';
import 'reader_models.dart';

/// Decode headroom over the viewport so pinch-zoom stays sharp: a page is
/// decoded up to this multiple of the viewport width (every reading mode is
/// pinch-zoomable, up to `maxScale` = 4x). The decode is still bounded by the
/// image-quality ceiling and clamped to the page's intrinsic width in the page
/// sources (never upscaled), so a normal page costs no more than its native
/// resolution and zoom reveals real detail instead of a stretched thumbnail.
const double kReaderZoomHeadroom = 4.0;

/// Delay after the last page change before the now-stationary page is upgraded
/// to a full-resolution decode. Long enough that flipping quickly through pages
/// never triggers a per-page high-res decode mid-slide (the cause of page-turn
/// jank); short enough that a settled page is sharp well before the reader would
/// pinch-zoom it. A zoom gesture promotes immediately, so this is never felt.
const Duration kFocusUpgradeDelay = Duration(milliseconds: 200);

/// Decides which page(s) hold a full-resolution decode, and at what widths.
///
/// One policy lives per reader body, created with the State and disposed in
/// its dispose (before the zoom notifier it listens to). It owns the
/// settled-page lag, the settle timer, the zoom-promotion listener, and the
/// focus/neighbor decode-width computation; the widget reports page turns and
/// rebuild metrics, and rebuilds (a setState) when [onPromoted] fires so the
/// newly focused page re-decodes through its image provider.
class FocusUpgradePolicy {
  FocusUpgradePolicy({required this.currentPage, required this.onPromoted});

  /// The reader's canonical current page (0-based), read at promotion time.
  final int Function() currentPage;

  /// Fired after [settledPage] moves to the current page, so the widget can
  /// rebuild and the focused page re-decodes at [focusWidth].
  final VoidCallback onPromoted;

  /// The page currently promoted to a full-resolution decode (for sharp zoom).
  /// Deliberately LAGS the live page: it is bumped to the current page only a
  /// beat AFTER the controller settles ([kFocusUpgradeDelay]). While a turn is
  /// in flight the focus set still points at the previous page, so neither the
  /// outgoing page (stays full-res) nor the incoming page (stays at its
  /// prefetched display resolution) changes decode width. The slide is then
  /// just translating ready textures - no mid-slide re-decode, no dropped
  /// frames.
  int _settledPage = 0;

  /// Fires [kFocusUpgradeDelay] after the last page change to promote the
  /// stationary page to full resolution. Reset on every turn so a fast
  /// flip-through never decodes at full resolution until it stops.
  Timer? _settleTimer;

  ValueListenable<bool>? _zoom;

  /// Display-resolution decode width for off-focus pages (the page source's
  /// default `cacheWidth`). Bounds memory so only the focused page holds a
  /// full-resolution texture.
  int _neighborWidth = 1;

  /// High-resolution decode width for the focused page/spread: the device-tier
  /// (or manual) ceiling, clamped to the safe texture size. The page sources
  /// never upscale past a page's native width, so a normal page costs at most
  /// its native resolution while a large scan zooms sharply. Recomputed live
  /// when the image-quality preference changes.
  int _focusWidth = 1;

  int get neighborWidth => _neighborWidth;
  int get focusWidth => _focusWidth;

  /// The page whose decode is currently promoted to full resolution.
  int get settledPage => _settledPage;

  /// Listens to the reader's zoom notifier: a zoom gesture promotes the
  /// focused page to full resolution immediately, so a pinch right after a
  /// turn is sharp without waiting for the settle.
  void attachZoom(ValueListenable<bool> zoomed) {
    _zoom = zoomed;
    zoomed.addListener(_onZoomChanged);
  }

  void _onZoomChanged() {
    if (_zoom!.value) promoteNow();
  }

  /// Schedule the focused-page full-resolution upgrade for a beat after motion
  /// stops. Reset on every turn, so flipping quickly never decodes at full
  /// resolution mid-slide; the upgrade lands only once the user pauses.
  void onPageTurned() {
    _settleTimer?.cancel();
    _settleTimer = Timer(kFocusUpgradeDelay, promoteNow);
  }

  /// Promote the current page to a full-resolution decode now: after a settle,
  /// or immediately when a zoom starts so the pinch is sharp. A no-op when the
  /// current page is already the promoted one.
  void promoteNow() {
    _settleTimer?.cancel();
    if (_settledPage == currentPage()) return;
    _settledPage = currentPage();
    onPromoted();
  }

  /// Pins the focus to the current page with no settle delay and no
  /// [onPromoted] callback: the opening page on first paint, and a controller
  /// reset (mode/direction change), where the page is already stationary and
  /// the caller rebuilds anyway.
  void settleImmediately() {
    _settleTimer?.cancel();
    _settledPage = currentPage();
  }

  /// Indices currently in focus (decoded at full resolution): the SETTLED page
  /// in paged and webtoon modes, both pages of the settled spread in
  /// double-page. Keyed on [settledPage] (not the live page) so a page turn
  /// never changes which pages are full-res mid-slide - that is what keeps
  /// paging decode-free.
  Set<int> indicesFor(ReadingMode mode, List<List<int>> pairs) {
    if (mode == ReadingMode.doublePage && pairs.isNotEmpty) {
      var index = 0;
      for (var i = 0; i < pairs.length; i++) {
        if (pairs[i].contains(_settledPage)) {
          index = i;
          break;
        }
      }
      return pairs[index].toSet();
    }
    return {_settledPage};
  }

  /// Recomputes the focus/neighbor decode widths for the current viewport and
  /// quality caps (rotation, a live quality change, or the GPU probe
  /// resolving).
  void recomputeWidths({
    required double viewportWidth,
    required double devicePixelRatio,
    required int hardwareCap,
    required int focusCeiling,
  }) {
    // Off-focus pages decode at display resolution (modest headroom) so only
    // the focused page holds a full-resolution texture; this is what keeps
    // memory in budget while the focused page can be sharp.
    _neighborWidth = (viewportWidth * devicePixelRatio * 1.5).round().clamp(
      1,
      kFallbackMaxTextureDim,
    );
    // The focused page decodes with zoom headroom over the viewport, up to the
    // image-quality ceiling (the device's probed max texture size in Smart
    // mode), bounded by the RAM-safe focus limit. The page sources clamp to
    // each page's intrinsic width (never upscaled), so a normal page costs at
    // most its native resolution and zoom reveals real detail instead of a
    // stretched thumbnail.
    final cap = focusCeiling < hardwareCap ? focusCeiling : hardwareCap;
    _focusWidth = (viewportWidth * devicePixelRatio * kReaderZoomHeadroom)
        .round()
        .clamp(1, cap);
  }

  /// Cancels the pending settle upgrade and detaches the zoom listener. Call
  /// before the zoom notifier itself is disposed.
  void dispose() {
    _settleTimer?.cancel();
    _zoom?.removeListener(_onZoomChanged);
    _zoom = null;
  }
}
