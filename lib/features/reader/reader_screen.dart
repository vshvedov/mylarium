import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_icons.dart';
import '../../app/theme/design_tokens.dart';
import '../../app/widgets/app_bottom_sheet.dart';
import '../../app/widgets/app_button.dart';
import '../../app/widgets/app_loading.dart';
import '../../core/network/content_exception.dart';
import '../../core/platform/render_capabilities.dart';
import '../../core/platform/system_ui.dart';
import '../gallery/gallery_controller.dart';
import '../offline/download_manager.dart';
import '../offline/offline_providers.dart';
import '../sync/sync_engine.dart';
import '../sync/sync_models.dart';
import '../sync/sync_providers.dart';
import 'color/color_corrected_image_provider.dart';
import 'color/color_math.dart';
import 'color/color_settings.dart';
import 'color/color_settings_controller.dart';
import 'double_page_layout.dart';
import 'double_page_view.dart';
import 'gestures/tap_zones.dart';
import 'image_quality.dart';
import 'offline_page_source.dart';
import 'online_page_source.dart';
import 'page_byte_store.dart';
import 'page_source.dart';
import 'paged_view.dart';
import 'page_prefetcher.dart';
import 'reader_controller.dart';
import 'reader_models.dart';
import '../settings/settings_providers.dart';
import 'reader_navigation.dart';
import 'webtoon_metrics.dart';
import 'webtoon_view.dart';
import 'widgets/capture_overlay.dart';
import 'widgets/color_correction_sheet.dart';
import 'widgets/image_quality_sheet.dart';
import 'widgets/reader_chrome.dart';
import 'widgets/reader_seam.dart';

/// The reader. Loads the book online, then renders the current mode's view with
/// immersive chrome, tap-zone gestures, and a precache-ahead pipeline.
class ReaderScreen extends ConsumerWidget {
  const ReaderScreen({
    super.key,
    required this.sourceId,
    required this.bookId,
    this.preview = false,
    this.initialPage,
  });

  final String sourceId;
  final String bookId;

  /// "Preview" mode: read the book without reporting any progress to the source
  /// (Komga never sees it as currently-reading) or recording a reading session.
  final bool preview;

  /// Opening page (0-based) override, e.g. a gallery capture deep-link
  /// (`?page=N`). When null, the reader resumes at the saved position.
  final int? initialPage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<DesignTokens>()!;
    final async = ref.watch(
      readerControllerProvider(sourceId, bookId, preview),
    );
    return Scaffold(
      backgroundColor: tokens.readerBackground,
      body: async.when(
        loading: () => const AppLoadingIndicator(),
        error: (e, _) => _ErrorState(
          title: 'Could not open this book',
          detail: friendlyError(e),
          onRetry: () => ref.invalidate(
            readerControllerProvider(sourceId, bookId, preview),
          ),
        ),
        data: (data) => _readerPageCount(data) == 0
            ? const _ErrorState(title: 'This book has no pages')
            // Key on bookId so navigating to a sibling chapter (pushReplacement to
            // the same route with a different bookId) tears down and recreates the
            // reader state (PageController, page index, session recorder).
            : _ReaderBody(
                key: ValueKey(bookId),
                sourceId: sourceId,
                bookId: bookId,
                data: data,
                preview: preview,
                initialPage: initialPage,
              ),
      ),
    );
  }
}

int _readerPageCount(ReaderData data) => switch (data.source) {
  OnlinePages(:final pages) => pages.length,
  OfflinePages(:final entries) => entries.length,
};

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

class _ReaderBody extends ConsumerStatefulWidget {
  const _ReaderBody({
    super.key,
    required this.sourceId,
    required this.bookId,
    required this.data,
    required this.preview,
    this.initialPage,
  });

  final String sourceId;
  final String bookId;
  final ReaderData data;
  final bool preview;

  /// Opening page (0-based) override; null resumes at the saved position.
  final int? initialPage;

  @override
  ConsumerState<_ReaderBody> createState() => _ReaderBodyState();
}

class _ReaderBodyState extends ConsumerState<_ReaderBody>
    with WidgetsBindingObserver {
  final _zoomed = ValueNotifier<bool>(false);
  final _scrollController = ScrollController();
  PageController? _pageController;

  PageSource? _source;
  List<List<int>> _pairs = const [];
  PagePrefetcher? _prefetcher;

  // Enter distraction-free: the top bar and bottom scrubber start hidden and a
  // tap on the page reveals them.
  bool _chrome = false;
  int? _cacheWidth;

  /// Page-capture mode: when true the capture overlay is up, chrome is hidden,
  /// and the page view ignores pointers so the overlay owns the marquee gesture.
  bool _capturing = false;

  /// Guards against a double-Save while a capture write is in flight.
  bool _saving = false;

  /// Identifies the RepaintBoundary wrapping the rendered page, for WYSIWYG
  /// capture (color correction is inside it; chrome is outside).
  final _captureBoundaryKey = GlobalKey();

  /// Whether the last page was reached during this session. Drives delete-on-read
  /// at teardown (deleting earlier would break in-flight page decodes).
  bool _reachedEnd = false;

  /// Live page color correction. [_adj] is the resolved effective adjustment,
  /// seeded from [ReaderData] (correct first paint) and kept current by the
  /// color-settings listener (which updates it live while sliders move). The
  /// non-linear residual (gamma/auto-levels) is baked into [_source] via a
  /// corrected provider; the affine layer (brightness/contrast/mode) is applied
  /// at render through [_colorFilter] (a GPU `ColorFilter`, instant in every
  /// mode, swapped without a re-decode when only the affine part changes).
  late ColorAdjustments _adj = widget.data.colorAdjustments;
  ColorFilter? _colorFilter;

  /// Reading-time + page-span accumulator for the current session. Lives on the
  /// State (a stable lifetime) so orientation rebuilds do not reset it.
  final _recorder = ReadingSessionRecorder();

  /// The app-lifetime sync engine future, captured once in [initState] so the
  /// teardown write-back (in [dispose]) never touches `ref` after the element is
  /// disposed (which throws "Cannot use ref after the widget was disposed").
  late final Future<SyncEngine> _syncEngine;

  /// Captured in [initState] so the deferred offline backfill can run from
  /// [dispose] / lifecycle callbacks without touching `ref` after disposal
  /// (which throws). The manager is app-lifetime (keepAlive).
  late final DownloadManager _downloadManager;

  /// Debounces per-turn progress write-back (BookState + Komga queue).
  Timer? _progressDebounce;

  /// Double-page "single-page nudge": shifts the spread pairing by one page
  /// (in-session; a transient alignment correction).
  bool _nudge = false;

  /// Canonical current page index (0-based).
  int _page = 0;

  /// The page currently promoted to a full-resolution decode (for sharp zoom).
  /// Deliberately LAGS [_page]: it is bumped to the current page only a beat
  /// AFTER the controller settles ([kFocusUpgradeDelay]). While a turn is in
  /// flight the focus set still points at the previous page, so neither the
  /// outgoing page (stays full-res) nor the incoming page (stays at its
  /// prefetched display resolution) changes decode width. The slide is then just
  /// translating ready textures - no mid-slide re-decode, no dropped frames.
  int _settledPage = 0;

  /// Fires [kFocusUpgradeDelay] after the last page change to promote the
  /// stationary page to full resolution. Reset on every turn so a fast
  /// flip-through never decodes at full resolution until it stops.
  Timer? _focusSettleTimer;

  /// End-of-book seam: true once the last page/spread is reached; [_seamDismissed]
  /// hides it after the user closes it (re-armed by leaving and returning to the
  /// end, or by trying to page past it).
  bool _atEnd = false;
  bool _seamDismissed = false;

  /// Display-resolution decode width for off-focus pages (the page source's
  /// default `cacheWidth`). Bounds memory so only the focused page holds a
  /// full-resolution texture.
  int _neighborWidth = 1;

  /// High-resolution decode width for the focused page/spread: the device-tier
  /// (or manual) ceiling, clamped to the safe texture size. The page sources
  /// never upscale past a page's native width, so a normal page costs at most its
  /// native resolution while a large scan zooms sharply. Recomputed live when the
  /// image-quality preference changes.
  int _focusWidth = 1;

  /// GPU sampling quality for page rendering, from the device tier.
  FilterQuality _sampling = FilterQuality.high;

  ReadingMode get _mode => widget.data.settings.mode;

  @override
  void initState() {
    super.initState();
    _syncEngine = ref.read(syncEngineProvider.future);
    _downloadManager = ref.read(downloadManagerProvider);
    // Cap total decoded-page memory so a long book cannot grow the global image
    // cache without bound. The full cacheCapBytes-driven LRU media cache is T5.
    PaintingBinding.instance.imageCache.maximumSizeBytes = 256 << 20; // 256 MB
    // Open at the deep-link page if given (a gallery capture), else resume at
    // the saved page; clamp to the book's range. Start a reading session at the
    // opening page.
    final count = _readerPageCount(widget.data);
    _page = count == 0
        ? 0
        : (widget.initialPage ?? widget.data.initialPage).clamp(0, count - 1);
    // The opening page is stationary, so promote it to full resolution at once
    // (no settle delay on first paint).
    _settledPage = _page;
    _recorder.onPage(_page, _nowMs());
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_onWebtoonScroll);
    // A zoom gesture promotes the focused page to full resolution immediately,
    // so a pinch right after a turn is sharp without waiting for the settle.
    _zoomed.addListener(_onZoomChanged);
    // Distraction-free, full-bleed reading: hide the system bars and claim the
    // screen edges from the Android back/switch gesture (no-op on iOS).
    unawaited(enterReaderImmersive());
  }

  int _nowMs() => DateTime.now().millisecondsSinceEpoch;

  int get _pageCount => _source?.pageCount ?? _readerPageCount(widget.data);

  /// Whether [page] is at the end of the book in the current mode. In double-page
  /// the final spread shows two pages, so any page in that spread counts as the
  /// end (otherwise finishing a spread-read book would never mark it completed).
  bool _isLastPage(int page) {
    if (_pageCount <= 0) return false;
    if (_mode == ReadingMode.doublePage && _pairs.isNotEmpty) {
      return _pairs.last.contains(page);
    }
    return page >= _pageCount - 1;
  }

  /// Records a page change: feeds the session recorder and schedules a debounced
  /// progress write-back. The last page flushes immediately (marks completion).
  void _reportPage(int page) {
    _recorder.onPage(page, _nowMs());
    _progressDebounce?.cancel();
    if (_isLastPage(page)) {
      _reachedEnd = true;
      _pushProgress(page, completed: true);
    } else {
      _progressDebounce = Timer(
        const Duration(seconds: 2),
        () => _pushProgress(page, completed: false),
      );
    }
  }

  void _pushProgress(int page, {required bool completed}) {
    // Preview mode is a non-committal peek: never report progress (local or to
    // the source), so the book is not marked currently-reading anywhere.
    if (widget.preview) return;
    final sourceId = widget.sourceId;
    final bookId = widget.bookId;
    _syncEngine
        .then((e) => e.recordProgress(sourceId, bookId, page, completed))
        .catchError((Object _) {});
  }

  /// Appends the current reading session (if it has measurable activity) and
  /// resets the recorder so a later checkpoint or dispose does not double-emit.
  void _finalizeSession() {
    // Preview mode records no reading session (no stats, no completion).
    if (widget.preview) return;
    final span = _recorder.build(
      sourceId: widget.sourceId,
      bookId: widget.bookId,
      seriesId: widget.data.seriesId,
    );
    _recorder.reset();
    if (span == null) return;
    final isCompletion = _isLastPage(span.endPage);
    _syncEngine
        .then((e) => e.recordSession(span, isCompletion: isCompletion))
        .catchError((Object _) {});
  }

  /// Deferred + throttled auto-cache: the full-chapter download is enqueued only
  /// when the reader is no longer actively pulling pages (on close / background),
  /// so foreground page fetches always have the connection to themselves. Online
  /// sources only; never in preview. Idempotent and Wi-Fi/auto-cache gated by the
  /// download manager.
  void _backfillOffline() {
    if (widget.preview) return;
    if (widget.data.source is! OnlinePages) return;
    final sourceId = widget.sourceId;
    final bookId = widget.bookId;
    unawaited(
      _downloadManager.enqueueBook(sourceId, bookId).catchError((_) {}),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        // Background: flush time, push the final position, and checkpoint the
        // session so a background-kill does not lose it.
        _recorder.pause(_nowMs());
        _progressDebounce?.cancel();
        _pushProgress(_page, completed: _isLastPage(_page));
        _finalizeSession();
        _backfillOffline();
      case AppLifecycleState.resumed:
        // Start a fresh session segment at the current page.
        _recorder.onPage(_page, _nowMs());
        // Re-assert immersion + gesture exclusion (the OS can restore the bars
        // and clear exclusion rects while backgrounded).
        unawaited(enterReaderImmersive());
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        break;
    }
  }

  void _onWebtoonScroll() {
    if (!_mode.isWebtoon || _source == null) return;
    final offsets = _webtoonOffsets();
    final page = webtoonPageAt(offsets, _scrollController.offset);
    if (page != _page) {
      _setAtEnd(page >= _pageCount - 1);
      setState(() => _page = page);
      _prefetcher?.onPage(page);
      _reportPage(page);
      _scheduleFocusUpgrade();
    }
  }

  List<double> _webtoonOffsets() {
    final source = _source!;
    final gap = _mode == ReadingMode.webtoonGaps ? 12.0 : 0.0;
    return webtoonOffsets(
      (_cacheWidth ?? 1) / MediaQuery.devicePixelRatioOf(context),
      [for (var i = 0; i < source.pageCount; i++) source.aspectRatio(i)],
      gap,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _rebuildSource();
  }

  @override
  void didUpdateWidget(_ReaderBody old) {
    super.didUpdateWidget(old);
    // Reset the controller on a mode change OR an effective-direction flip: in
    // double-page a direction toggle changes only `direction` (not `mode`), but
    // the spread `reverse:` flips, so the controller must be rebuilt at the
    // current page to land on the right spread.
    if (old.data.settings.mode != _mode ||
        effectiveRtl(old.data.settings) != effectiveRtl(widget.data.settings)) {
      _resetControllerForMode();
    }
  }

  void _rebuildSource({bool force = false}) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final width = MediaQuery.sizeOf(context).width;
    _sampling = kReaderSampling;
    // Off-focus pages decode at display resolution (modest headroom) so only the
    // focused page holds a full-resolution texture; this is what keeps memory in
    // budget while the focused page can be sharp.
    final neighborWidth = (width * dpr * 1.5).round().clamp(
      1,
      kFallbackMaxTextureDim,
    );
    // The focused page decodes with zoom headroom over the viewport, up to the
    // image-quality ceiling (the device's probed max texture size in Smart mode),
    // bounded by the RAM-safe focus limit. The page sources clamp to each page's
    // intrinsic width (never upscaled), so a normal page costs at most its native
    // resolution and zoom reveals real detail instead of a stretched thumbnail.
    final hardwareCap = focusTextureCap(ref.read(renderCapabilitiesProvider));
    final focusCeiling = ref
        .read(imageQualityControllerProvider)
        .focusCeiling(hardwareCap);
    final cap = focusCeiling < hardwareCap ? focusCeiling : hardwareCap;
    _focusWidth = (width * dpr * kReaderZoomHeadroom).round().clamp(1, cap);
    _neighborWidth = neighborWidth;
    // Only rebuild the source (resetting the prefetch window) when the source's
    // default decode width actually changes (e.g. rotation); a metrics/theme
    // dependency change must not reset the window. A live quality change updates
    // [_focusWidth] above and only the focused page re-decodes (via [_pageImage]).
    // [force] rebuilds even when the width is unchanged (a color change).
    if (!force && _source != null && _cacheWidth == neighborWidth) return;
    _cacheWidth = neighborWidth;
    final base = switch (widget.data.source) {
      OnlinePages(:final api, :final pages) => OnlinePageSource(
        api: api,
        sourceId: widget.sourceId,
        bookId: widget.bookId,
        pages: pages,
        cacheWidth: neighborWidth,
        byteStore: ref.read(pageByteStoreProvider),
      ),
      OfflinePages(:final archivePath, :final entries) => OfflinePageSource(
        extractor: ref.read(archiveExtractorProvider),
        sourceId: widget.sourceId,
        bookId: widget.bookId,
        archivePath: archivePath,
        entries: entries,
        cacheWidth: neighborWidth,
      ),
    };
    // Split the live correction: the non-linear residual (gamma/auto-levels) is
    // baked into the decoded page by a corrected provider; the affine part
    // (brightness/contrast/mode) is layered on at render via a GPU ColorFilter.
    final (affine: affine, residual: residual) = splitAdjustments(_adj);
    final source = colorCorrectedSource(base, residual);
    _colorFilter = affine.isIdentity
        ? null
        : ColorFilter.matrix(buildMatrix(affine));
    _source = source;
    _recomputePairs();
    _prefetcher = PagePrefetcher.forContext(source, context);
    _pageController ??= PageController(initialPage: _controllerIndexFor(_page));
    // On a forced (color) rebuild, warm the new providers for the visible
    // window so the corrected pages decode now rather than on the next turn.
    if (force) _prefetcher?.onPage(_page);
  }

  void _recomputePairs() {
    final source = _source;
    if (source == null) return;
    // Nudge toggles the cover-solo offset, shifting the spread pairing by one.
    _pairs = const DoublePageLayout().pairs(
      source.pageCount,
      coverSolo: !_nudge,
      widePages: source.widePages,
    );
  }

  void _toggleNudge() {
    setState(() {
      _nudge = !_nudge;
      _recomputePairs();
    });
    final controller = _pageController;
    if (controller != null && controller.hasClients) {
      controller.jumpToPage(_controllerIndexFor(_page));
    }
  }

  void _resetControllerForMode() {
    final target = _controllerIndexFor(_page);
    _pageController?.dispose();
    _pageController = PageController(initialPage: target);
    // A new controller does not fire onPageChanged, so recompute end-ness here
    // (e.g. switching mode while the seam is showing on the last page). The
    // current page is stationary in the new mode, so make it full-res at once.
    _setAtEnd(_isEndController(target));
    _focusSettleTimer?.cancel();
    _settledPage = _page;
    setState(() {});
  }

  /// Maps the canonical page index to the controller index for the current
  /// mode (spread index in double-page mode, page index otherwise).
  int _controllerIndexFor(int page) {
    if (_mode != ReadingMode.doublePage) return page;
    for (var i = 0; i < _pairs.length; i++) {
      if (_pairs[i].contains(page)) return i;
    }
    return 0;
  }

  int _pageForControllerIndex(int index) {
    if (_mode != ReadingMode.doublePage) return index;
    if (index < 0 || index >= _pairs.length) return 0;
    return _pairs[index].first;
  }

  /// Indices currently in focus (decoded at full resolution): the SETTLED page in
  /// paged and webtoon modes, both pages of the settled spread in double-page.
  /// Keyed on [_settledPage] (not the live [_page]) so a page turn never changes
  /// which pages are full-res mid-slide - that is what keeps paging decode-free.
  Set<int> _focusIndices() {
    if (_mode == ReadingMode.doublePage && _pairs.isNotEmpty) {
      final i = _controllerIndexFor(_settledPage).clamp(0, _pairs.length - 1);
      return _pairs[i].toSet();
    }
    return {_settledPage};
  }

  /// Provider for page [i]: the focused page/spread decodes at [_focusWidth] (high
  /// resolution for sharp zoom), all other pages at [_neighborWidth] (display
  /// resolution, to bound memory).
  ImageProvider _pageImage(int i) {
    final w = _focusIndices().contains(i) ? _focusWidth : _neighborWidth;
    return _source!.imageProviderAt(i, w);
  }

  /// Schedule the focused-page full-resolution upgrade for a beat after motion
  /// stops. Reset on every turn, so flipping quickly never decodes at full
  /// resolution mid-slide; the upgrade lands only once the user pauses.
  void _scheduleFocusUpgrade() {
    _focusSettleTimer?.cancel();
    _focusSettleTimer = Timer(kFocusUpgradeDelay, _promoteFocusNow);
  }

  /// Promote the current page to a full-resolution decode now: after a settle,
  /// or immediately when a zoom starts so the pinch is sharp. A no-op when the
  /// current page is already the promoted one.
  void _promoteFocusNow() {
    _focusSettleTimer?.cancel();
    if (!mounted || _settledPage == _page) return;
    setState(() => _settledPage = _page);
  }

  void _onZoomChanged() {
    if (_zoomed.value) _promoteFocusNow();
  }

  /// Whether [controllerIndex] is the last position in the current paged mode
  /// (the last spread in double-page, the last page otherwise).
  bool _isEndController(int controllerIndex) {
    final source = _source;
    if (source == null) return false;
    final maxIndex =
        (_mode == ReadingMode.doublePage ? _pairs.length : source.pageCount) -
        1;
    return maxIndex >= 0 && controllerIndex >= maxIndex;
  }

  /// Updates [_atEnd]; leaving the end re-arms the seam (clears the dismissal).
  void _setAtEnd(bool atEnd) {
    if (atEnd == _atEnd) return;
    _atEnd = atEnd;
    if (!atEnd) _seamDismissed = false;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Leave the reader: restore the app-wide chrome and clear gesture exclusion.
    unawaited(exitReaderImmersive());
    _progressDebounce?.cancel();
    _focusSettleTimer?.cancel();
    // Push the final position (durable) and append the session (best-effort;
    // the SyncEngine + database are app-lifetime, so the write survives this
    // screen's teardown).
    _pushProgress(_page, completed: _isLastPage(_page));
    _finalizeSession();
    // Now that reading is over, backfill the rest of the chapter offline without
    // competing with foreground page fetches.
    _backfillOffline();
    // If the chapter was finished this session, reclaim its cached copy now that
    // the reader (and its archive reads) are tearing down - never mid-session,
    // which would fail in-flight decodes. No-op unless "delete on read" is on.
    if (!widget.preview && _reachedEnd) {
      final sourceId = widget.sourceId;
      final bookId = widget.bookId;
      _syncEngine
          .then((e) => e.maybeDeleteOnRead(sourceId, bookId))
          .catchError((Object _) {});
    }
    _zoomed.removeListener(_onZoomChanged);
    _zoomed.dispose();
    _scrollController.dispose();
    _pageController?.dispose();
    super.dispose();
  }

  void _onControllerPage(int index) {
    _page = _pageForControllerIndex(index);
    _prefetcher?.onPage(_page);
    _reportPage(_page);
    _setAtEnd(_isEndController(index));
    // Hold the full-res focus on the previous page until the turn settles, so
    // the slide does not re-decode either page; promote a beat after it stops.
    _scheduleFocusUpgrade();
    setState(() {});
  }

  void _toggleChrome() => setState(() => _chrome = !_chrome);

  void _openImageQuality() => AppBottomSheet.show<void>(
    context,
    builder: (_) => const ImageQualitySheet(),
  );

  void _openColorCorrection() => AppBottomSheet.show<void>(
    context,
    // Keep the page fully visible (no dim) so corrections preview clearly.
    barrierColor: Colors.transparent,
    builder: (_) => ColorCorrectionSheet(
      sourceId: widget.sourceId,
      seriesId: widget.data.seriesId,
      bookId: widget.bookId,
    ),
  );

  /// The reader top-bar title: "series · chapter" when known, the chapter alone
  /// if the series is uncached, or the page position as a last resort (e.g. an
  /// offline book with no cached title). The page count still lives in the
  /// bottom scrubber, so the top bar leads with the series/chapter name.
  String _chromeTitle(int pageCount) {
    final chapter = widget.data.title.trim();
    final series = widget.data.seriesTitle?.trim();
    if (chapter.isEmpty) return 'Page ${_page + 1} of $pageCount';
    if (series != null && series.isNotEmpty) return '$series · $chapter';
    return chapter;
  }

  /// Enter capture mode: hide chrome and raise the marquee overlay.
  void _startCapture() => setState(() {
        _chrome = false;
        _capturing = true;
      });

  void _cancelCapture() => setState(() => _capturing = false);

  /// Crop the rendered page to [selection] (WYSIWYG, color correction baked in),
  /// save it to the gallery, and confirm. Distinct messages for a capture vs a
  /// save failure; guarded against double-save and post-dispose setState.
  Future<void> _onCaptureSave(Rect selection) async {
    if (_saving) return;
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    final navContext = context;
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    ({Uint8List png, int width, int height}) shot;
    try {
      shot = await cropBoundaryToPng(
        boundaryKey: _captureBoundaryKey,
        selectionLogical: selection,
        pixelRatio: pixelRatio,
      );
    } catch (_) {
      _finishCapture(messenger, 'Could not capture this page.');
      return;
    }
    try {
      await ref.read(capturesRepositoryProvider).save(
            sourceId: widget.sourceId,
            seriesId: widget.data.seriesId,
            bookId: widget.bookId,
            bookTitle: widget.data.title,
            pageNumber: _page,
            pngBytes: shot.png,
            width: shot.width,
            height: shot.height,
          );
    } catch (_) {
      _finishCapture(messenger, 'Could not save capture.');
      return;
    }
    if (!mounted) return;
    setState(() {
      _capturing = false;
      _saving = false;
    });
    messenger.showSnackBar(SnackBar(
      content: const Text('Saved to Gallery'),
      // Auto-dismiss the capture confirmation after a short timeout so it does
      // not linger over the page; still long enough to tap "View".
      duration: const Duration(seconds: 3),
      action: SnackBarAction(
        label: 'View',
        onPressed: () => navContext.push('/gallery'),
      ),
    ));
  }

  void _finishCapture(ScaffoldMessengerState messenger, String message) {
    if (!mounted) return;
    setState(() {
      _capturing = false;
      _saving = false;
    });
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  void _step(int delta) {
    final controller = _pageController;
    if (controller == null || !controller.hasClients) return;
    final next = (controller.page?.round() ?? 0) + delta;
    final maxIndex =
        (_mode == ReadingMode.doublePage ? _pairs.length : _source!.pageCount) -
        1;
    if (next < 0) return;
    if (next > maxIndex) {
      // Trying to advance past the last page raises the seam (re-arming it even
      // if it was dismissed).
      if (delta > 0) {
        setState(() {
          _atEnd = true;
          _seamDismissed = false;
        });
      }
      return;
    }
    final eink =
        Theme.of(context).extension<DesignTokens>()?.isEink ?? false;
    if (widget.data.settings.animatePageTurn && !eink) {
      controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    } else {
      controller.jumpToPage(next);
    }
  }

  void _handleTap(Offset normalized) {
    final s = widget.data.settings;
    final action = resolveTapZone(
      normalized: normalized,
      preset: s.taps,
      invert: s.invertTaps,
      rtl: effectiveRtl(s),
    );
    switch (action) {
      case TapAction.prev:
        _step(-1);
      case TapAction.next:
        _step(1);
      case TapAction.toggleChrome:
        _toggleChrome();
    }
  }

  void _seekPage(int page) {
    _page = page;
    _reportPage(page);
    _scheduleFocusUpgrade();
    if (_mode.isWebtoon) {
      if (_scrollController.hasClients) {
        final offsets = _webtoonOffsets();
        final max = _scrollController.position.maxScrollExtent;
        _scrollController.jumpTo(offsets[page].clamp(0.0, max));
      }
      setState(() {});
      return;
    }
    final controller = _pageController;
    if (controller != null && controller.hasClients) {
      controller.jumpToPage(_controllerIndexFor(page));
    }
  }

  @override
  Widget build(BuildContext context) {
    // React to a live image-quality change: recompute the focus/neighbor decode
    // widths so the focused page re-decodes at the new quality (via [_pageImage]).
    ref.listen(imageQualityControllerProvider, (_, _) {
      _rebuildSource();
      setState(() {});
    });
    // React to the GPU max-texture-size probe resolving (it bootstraps to the
    // safe fallback, then jumps to the real device value): re-derive the focus
    // width so the focused page can decode sharper on capable hardware.
    ref.listen(renderCapabilitiesProvider, (_, _) {
      _rebuildSource();
      setState(() {});
    });
    // React to a live color-correction change: re-split into the baked residual
    // and the GPU affine layer, rebuild the source, and re-prefetch.
    ref.listen(
      colorSettingsControllerProvider(
        widget.sourceId,
        widget.data.seriesId,
        widget.bookId,
      ),
      (_, next) {
        next.whenData((s) {
          final adj = s.resolved;
          if (adj == _adj) return;
          final residualChanged =
              splitAdjustments(adj).residual.signature !=
              splitAdjustments(_adj).residual.signature;
          _adj = adj;
          if (_source != null && !residualChanged) {
            // Only the affine (GPU) layer changed: swap the ColorFilter with no
            // re-decode, so brightness/contrast/mode preview in real time.
            final affine = splitAdjustments(adj).affine;
            setState(
              () => _colorFilter = affine.isIdentity
                  ? null
                  : ColorFilter.matrix(buildMatrix(affine)),
            );
          } else {
            // Residual (gamma/auto-levels) changed: re-bake via the provider.
            _rebuildSource(force: true);
            setState(() {});
          }
        });
      },
    );
    final source = _source!;
    final s = widget.data.settings;
    final size = MediaQuery.sizeOf(context);
    final viewportAspect = size.height == 0 ? 0.7 : size.width / size.height;
    final view = switch (s.mode) {
      ReadingMode.pagedLtr || ReadingMode.pagedRtl => PagedView(
        pageController: _pageController!,
        pageCount: source.pageCount,
        imageBuilder: _pageImage,
        aspectRatioOf: source.aspectRatio,
        fit: s.fit,
        viewportAspect: viewportAspect,
        rtl: effectiveRtl(s),
        doubleTapZoom: s.doubleTapZoom,
        filterQuality: _sampling,
        zoomed: _zoomed,
        onPageChanged: _onControllerPage,
        onTap: _handleTap,
      ),
      // Double-page direction follows the per-series reading direction (T4):
      // effectiveRtl reads the `direction` field for double-page mode.
      ReadingMode.doublePage => DoublePageView(
        pageController: _pageController!,
        pairs: _pairs,
        imageBuilder: _pageImage,
        fit: s.fit,
        rtl: effectiveRtl(s),
        filterQuality: _sampling,
        onPageChanged: _onControllerPage,
        onTap: _handleTap,
      ),
      ReadingMode.webtoon || ReadingMode.webtoonGaps => WebtoonView(
        scrollController: _scrollController,
        pageCount: source.pageCount,
        imageBuilder: _pageImage,
        aspectRatio: source.aspectRatio,
        gaps: s.mode == ReadingMode.webtoonGaps,
        filterQuality: _sampling,
        onTapToggle: _toggleChrome,
      ),
    };

    // The GPU affine layer (brightness/contrast/mode). A single ColorFilter
    // over the composited view applies instantly in every reading mode; absent
    // any affine adjustment there is no layer (zero cost for uncorrected
    // reading). The non-linear residual is already baked into [source].
    final filter = _colorFilter;
    final filteredView = filter == null
        ? view
        : ColorFiltered(colorFilter: filter, child: view);
    final neighbors =
        ref
            .watch(
              bookNeighborsProvider(
                widget.sourceId,
                widget.data.seriesId,
                widget.bookId,
              ),
            )
            .valueOrNull ??
        const BookNeighbors();
    final autoAdvance =
        ref.watch(autoAdvanceEnabledProvider).valueOrNull ?? false;
    return Stack(
      children: [
        Positioned.fill(
          child: RepaintBoundary(
            key: _captureBoundaryKey,
            // While capturing, the page ignores pointers so the overlay's
            // marquee gesture is the sole handler (no photo_view arena contest).
            child: IgnorePointer(ignoring: _capturing, child: filteredView),
          ),
        ),
        if (_atEnd && !_seamDismissed)
          Positioned.fill(
            child: ReaderSeam(
              title: widget.data.title,
              neighbors: neighbors,
              onOpenBook: _openBook,
              onDismiss: () => setState(() => _seamDismissed = true),
              autoAdvance: autoAdvance,
            ),
          ),
        Positioned.fill(
          child: ReaderChrome(
            visible: _chrome,
            title: _chromeTitle(source.pageCount),
            sourceId: widget.sourceId,
            bookId: widget.bookId,
            offline: widget.data.source is OfflinePages,
            settings: s,
            pageCount: source.pageCount,
            currentPage: _page,
            thumbnailImage: source.thumbnail,
            rtl: effectiveRtl(s),
            neighbors: neighbors,
            onClose: () => context.pop(),
            onSettings: (next) => ref
                .read(
                  readerControllerProvider(
                    widget.sourceId,
                    widget.bookId,
                  ).notifier,
                )
                .updateSettings(next),
            onSeekPage: _seekPage,
            onJumpToPage: _seekPage,
            onOpenBook: _openBook,
            onToggleDirection: s.mode.isWebtoon
                ? null
                : () => ref
                      .read(
                        readerControllerProvider(
                          widget.sourceId,
                          widget.bookId,
                        ).notifier,
                      )
                      .toggleDirection(),
            onImageQuality: _openImageQuality,
            onColorCorrection: _openColorCorrection,
            onNudge: s.mode == ReadingMode.doublePage ? _toggleNudge : null,
            nudged: _nudge,
            onCapture: _startCapture,
          ),
        ),
        if (_capturing)
          Positioned.fill(
            child: CaptureOverlay(
              onCancel: _cancelCapture,
              onSave: _onCaptureSave,
              busy: _saving,
            ),
          ),
      ],
    );
  }

  /// Opens a sibling book in place (replaces the current reader route so back
  /// returns to the series, not a chain of chapters).
  void _openBook(String bookId) =>
      context.pushReplacement('/reader/${widget.sourceId}/$bookId');
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.title, this.detail, this.onRetry});

  final String title;
  final String? detail;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: const Icon(AppIcons.back),
              onPressed: () => context.pop(),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    AppIcons.brokenImage,
                    size: 44,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (detail != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      detail!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (onRetry != null) ...[
                    const SizedBox(height: 20),
                    AppButton(
                      kind: AppButtonKind.tonal,
                      icon: AppIcons.refresh,
                      label: 'Try again',
                      onPressed: onRetry,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
