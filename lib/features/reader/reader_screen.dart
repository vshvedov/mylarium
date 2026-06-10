import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/error_text.dart';
import '../../app/l10n.dart';
import '../../app/theme/app_icons.dart';
import '../../app/theme/design_tokens.dart';
import '../../app/widgets/app_bottom_sheet.dart';
import '../../app/widgets/app_button.dart';
import '../../app/widgets/app_loading.dart';
import '../../core/archive/archive_reader.dart';
import '../../core/platform/render_capabilities.dart';
import '../../core/platform/system_ui.dart';
import '../gallery/gallery_controller.dart';
import '../offline/download_manager.dart';
import '../offline/offline_providers.dart';
import '../sync/sync_engine.dart';
import '../sync/sync_providers.dart';
import 'capture_controller.dart';
import 'color/color_corrected_image_provider.dart';
import 'color/color_math.dart';
import 'color/color_settings.dart';
import 'color/color_settings_controller.dart';
import 'double_page_layout.dart';
import 'double_page_view.dart';
import 'focus_policy.dart';
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
import 'reader_progress_coordinator.dart';
import '../settings/settings_providers.dart';
import 'reader_navigation.dart';
import 'webtoon_metrics.dart';
import 'webtoon_view.dart';
import 'widgets/capture_overlay.dart';
import 'widgets/color_correction_sheet.dart';
import 'widgets/direction_nudge.dart';
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
          title: context.l10n.readerOpenError,
          detail: localizedFriendlyError(context, e),
          onRetry: () => ref.invalidate(
            readerControllerProvider(sourceId, bookId, preview),
          ),
        ),
        data: (data) => _readerPageCount(data) == 0
            ? _ErrorState(title: context.l10n.readerNoPages)
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

  /// The persistent archive reader for an offline book (one worker isolate, kept
  /// alive for the whole reading session so page reads never pay an isolate
  /// spawn). Created in [initState] for an offline source, disposed in [dispose];
  /// a source rebuild (rotation/color) reuses the same reader.
  ArchiveReader? _archiveReader;

  // Enter distraction-free: the top bar and bottom scrubber start hidden and a
  // tap on the page reveals them.
  bool _chrome = false;
  int? _cacheWidth;

  /// Page-capture state machine + crop/save pipeline. Plain state: [build]
  /// reads its flags, the action handlers wrap its transitions in setState.
  final _capture = CaptureController();

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

  /// Progress write-back + reading-session recording for this open: the
  /// per-turn debounce, the 60s in-flight checkpoint, and the lifecycle
  /// pause/resume bookkeeping. Created in [initState], flushed + disposed in
  /// [dispose]. See [ReaderProgressCoordinator].
  late final ReaderProgressCoordinator _progress;

  /// The app-lifetime sync engine future, captured once in [initState] so the
  /// teardown write-back (in [dispose]) never touches `ref` after the element is
  /// disposed (which throws "Cannot use ref after the widget was disposed").
  late final Future<SyncEngine> _syncEngine;

  /// Captured in [initState] so the offline backfill can run from
  /// [dispose] / lifecycle callbacks without touching `ref` after disposal
  /// (which throws). The manager is app-lifetime (keepAlive).
  late final DownloadManager _downloadManager;

  /// Starts the during-read auto-cache backfill a few seconds after open (online
  /// sources), so a wanted chapter caches while you read instead of only on exit.
  Timer? _backfillTimer;

  /// Guards [_backfillOffline] so the during-read timer, the background-lifecycle
  /// path, and dispose enqueue it at most once.
  bool _backfillStarted = false;

  /// Guards the adaptive image-cache cap so it is computed once per reader
  /// open (it needs MediaQuery, so it runs in [didChangeDependencies]).
  bool _imageCacheCapSet = false;

  /// Hides the first-open direction nudge for this screen instance once acted
  /// on (both actions also persist settings, which clears
  /// `ReaderData.directionUnset` so the nudge never returns for the series).
  bool _directionNudgeDismissed = false;

  /// Double-page "single-page nudge": shifts the spread pairing by one page
  /// (in-session; a transient alignment correction).
  bool _nudge = false;

  /// Canonical current page index (0-based).
  int _page = 0;

  /// Focused-page promotion policy: which page(s) hold a full-resolution
  /// decode (the settled page, lagging [_page] by [kFocusUpgradeDelay]) and
  /// the focus/neighbor decode widths. Owns the settle timer and the zoom
  /// listener on [_zoomed]; see [FocusUpgradePolicy].
  late final FocusUpgradePolicy _focus = FocusUpgradePolicy(
    currentPage: () => _page,
    onPromoted: _onFocusPromoted,
  );

  /// End-of-book seam: true once the last page/spread is reached; [_seamDismissed]
  /// hides it after the user closes it (re-armed by leaving and returning to the
  /// end, or by trying to page past it).
  bool _atEnd = false;
  bool _seamDismissed = false;

  /// GPU sampling quality for page rendering, from the device tier.
  FilterQuality _sampling = FilterQuality.high;

  ReadingMode get _mode => widget.data.settings.mode;

  @override
  void initState() {
    super.initState();
    _syncEngine = ref.read(syncEngineProvider.future);
    _downloadManager = ref.read(downloadManagerProvider);
    // An offline book reads through ONE persistent archive-reader worker for the
    // whole session (no per-page isolate spawn), torn down in [dispose].
    final source = widget.data.source;
    if (source is OfflinePages) {
      _archiveReader = ArchiveReader(source.archivePath);
    }
    // The decoded-page image-cache cap is set adaptively on the first
    // [didChangeDependencies] (it needs MediaQuery, unavailable here).
    // Open at the deep-link page if given (a gallery capture), else resume at
    // the saved page; clamp to the book's range. Start a reading session at the
    // opening page.
    final count = _readerPageCount(widget.data);
    _page = count == 0
        ? 0
        : (widget.initialPage ?? widget.data.initialPage).clamp(0, count - 1);
    // The opening page is stationary, so promote it to full resolution at once
    // (no settle delay on first paint).
    _focus.settleImmediately();
    // The coordinator starts the 60s in-flight session checkpoint itself
    // (never in preview); resume() starts the session at the opening page.
    _progress = ReaderProgressCoordinator(
      syncEngine: _syncEngine,
      sourceId: widget.sourceId,
      bookId: widget.bookId,
      seriesId: widget.data.seriesId,
      preview: widget.preview,
      isLastPage: _isLastPage,
    );
    _progress.resume(_page);
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_onWebtoonScroll);
    // A zoom gesture promotes the focused page to full resolution immediately,
    // so a pinch right after a turn is sharp without waiting for the settle.
    _focus.attachZoom(_zoomed);
    // Distraction-free, full-bleed reading: hide the system bars and claim the
    // screen edges from the Android back/switch gesture (no-op on iOS).
    unawaited(enterReaderImmersive());
    // Start the auto-cache backfill while reading (online sources), a few seconds
    // in so the opening page + window warm first. Gated by the auto-cache + Wi-Fi
    // settings inside the download manager; the dispose/background path is an
    // idempotent fallback if the reader closes before this fires.
    if (!widget.preview && source is OnlinePages) {
      _backfillTimer = Timer(const Duration(seconds: 3), _backfillOffline);
    }
  }

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

  /// Records a page change with the coordinator (session recorder + debounced
  /// progress write-back; the last page flushes immediately) and remembers the
  /// end-reach for delete-on-read at teardown.
  void _reportPage(int page) {
    if (_isLastPage(page)) _reachedEnd = true;
    _progress.onPage(page);
  }

  /// Auto-cache backfill: enqueues the full-chapter download once per session.
  /// Started a few seconds after open (so it never competes with the opening page
  /// fetches), with the background-lifecycle and dispose paths as fallbacks. The
  /// [_backfillStarted] guard keeps it to a single enqueue. Online sources only;
  /// never in preview. Wi-Fi/auto-cache gated by the download manager.
  void _backfillOffline() {
    if (widget.preview) return;
    if (widget.data.source is! OnlinePages) return;
    if (_backfillStarted) return;
    _backfillStarted = true;
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
        _progress.pause();
        _backfillOffline();
      case AppLifecycleState.resumed:
        // Start a fresh session segment at the current page.
        _progress.resume(_page);
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
      _focus.onPageTurned();
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
    // Cap total decoded-page memory ADAPTIVELY, once per reader open: one
    // full-screen page decodes to about (logical width * dpr) x (logical
    // height * dpr) RGBA pixels at 4 bytes each, and the reader keeps roughly
    // a dozen pages alive (focused page, prefetch window, recently viewed).
    // Clamped to [128 MB, 512 MB] so a small phone still gets a useful cache
    // and a high-dpr tablet cannot balloon memory. The full cacheCapBytes-
    // driven LRU media cache is T5.
    if (!_imageCacheCapSet) {
      _imageCacheCapSet = true;
      final size = MediaQuery.sizeOf(context);
      final dpr = MediaQuery.devicePixelRatioOf(context);
      final pageBytes = size.width * size.height * dpr * dpr * 4;
      final cap = (pageBytes * 12).round().clamp(128 << 20, 512 << 20);
      PaintingBinding.instance.imageCache.maximumSizeBytes = cap;
    }
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
    // Recompute the focus/neighbor decode widths BEFORE the rebuild gate below:
    // a live quality change updates the focus width even when the source's
    // default decode width is unchanged, so only the focused page re-decodes
    // (via [_pageImage]).
    final hardwareCap = focusTextureCap(ref.read(renderCapabilitiesProvider));
    final focusCeiling = ref
        .read(imageQualityControllerProvider)
        .focusCeiling(hardwareCap);
    _focus.recomputeWidths(
      viewportWidth: width,
      devicePixelRatio: dpr,
      hardwareCap: hardwareCap,
      focusCeiling: focusCeiling,
    );
    final neighborWidth = _focus.neighborWidth;
    // Only rebuild the source (resetting the prefetch window) when the source's
    // default decode width actually changes (e.g. rotation); a metrics/theme
    // dependency change must not reset the window. [force] rebuilds even when
    // the width is unchanged (a color change).
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
      OfflinePages(:final entries) => OfflinePageSource(
        reader: _archiveReader!,
        sourceId: widget.sourceId,
        bookId: widget.bookId,
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
    // Offline reads are local and cheap (the persistent reader has no per-page
    // spawn), so look a little further ahead; online stays at the default to
    // avoid the archive backfill competing with foreground page fetches.
    final ahead = widget.data.source is OfflinePages ? 4 : 3;
    _prefetcher = PagePrefetcher.forContext(source, context, ahead: ahead);
    _pageController ??= PageController(initialPage: _controllerIndexFor(_page));
    // Warm the window for the current page on every real (re)build, including the
    // initial open, so the next page is decoded BEFORE the first turn. (Previously
    // only a forced color rebuild warmed it, so the first page-turn of a freshly
    // opened book was always a cold decode - the offline "loading" spinner.)
    _prefetcher?.onPage(_page);
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
    _focus.settleImmediately();
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

  /// Provider for page [i]: the focused page/spread decodes at the policy's
  /// focus width (high resolution for sharp zoom), all other pages at its
  /// neighbor width (display resolution, to bound memory).
  ImageProvider _pageImage(int i) {
    final w = _focus.indicesFor(_mode, _pairs).contains(i)
        ? _focus.focusWidth
        : _focus.neighborWidth;
    return _source!.imageProviderAt(i, w);
  }

  /// The focus policy promoted the settled page: rebuild so the focused page
  /// re-decodes at the high-resolution width (via [_pageImage]).
  void _onFocusPromoted() {
    if (!mounted) return;
    setState(() {});
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
    // Cancel the pending focus upgrade and detach the zoom listener (before
    // [_zoomed] itself is disposed below).
    _focus.dispose();
    _backfillTimer?.cancel();
    // Push the final position (durable) and append the session (best-effort;
    // the SyncEngine + database are app-lifetime, so the write survives this
    // screen's teardown). flush() also cancels the debounce/checkpoint timers.
    _progress.flush(page: _page);
    _progress.dispose();
    // Fallback: enqueue the backfill if the during-read timer never fired (the
    // [_backfillStarted] guard makes this a no-op once it has).
    _backfillOffline();
    // Tear down the offline archive worker isolate now that all page reads are
    // done (never mid-session, which would fail in-flight decodes).
    unawaited(_archiveReader?.dispose() ?? Future<void>.value());
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
    _focus.onPageTurned();
    setState(() {});
  }

  void _toggleChrome() => setState(() => _chrome = !_chrome);

  /// Accept the first-open direction nudge: flip this series to right-to-left.
  /// toggleDirection persists the settings, so the nudge never returns.
  void _acceptDirectionNudge() {
    setState(() => _directionNudgeDismissed = true);
    ref
        .read(readerControllerProvider(widget.sourceId, widget.bookId).notifier)
        .toggleDirection();
  }

  /// Dismiss the first-open direction nudge: persist the current settings
  /// as-is so it shows at most once per series, ever.
  void _dismissDirectionNudge() {
    setState(() => _directionNudgeDismissed = true);
    ref
        .read(readerControllerProvider(widget.sourceId, widget.bookId).notifier)
        .updateSettings(widget.data.settings);
  }

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
  String _chromeTitle(BuildContext context, int pageCount) {
    final chapter = widget.data.title.trim();
    final series = widget.data.seriesTitle?.trim();
    if (chapter.isEmpty) {
      return context.l10n.readerPageOfCount(_page + 1, pageCount);
    }
    if (series != null && series.isNotEmpty) return '$series · $chapter';
    return chapter;
  }

  /// Enter capture mode: hide chrome and raise the marquee overlay.
  void _startCapture() => setState(() {
        _chrome = false;
        _capture.start();
      });

  void _cancelCapture() => setState(() => _capture.cancel());

  /// Crop the rendered page to [selection] (WYSIWYG, color correction baked in),
  /// save it to the gallery, and confirm. The controller runs the pipeline and
  /// reports which stage failed (distinct messages for a capture vs a save
  /// failure) and guards against a double-Save; the snackbar/navigation
  /// plumbing stays here, guarded against post-dispose setState.
  Future<void> _onCaptureSave(Rect selection) async {
    if (_capture.saving) return;
    final messenger = ScaffoldMessenger.of(context);
    final navContext = context;
    final l10n = context.l10n;
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final pending = _capture.save(
      crop: () => cropBoundaryToPng(
        boundaryKey: _captureBoundaryKey,
        selectionLogical: selection,
        pixelRatio: pixelRatio,
      ),
      persist: (shot) => ref.read(capturesRepositoryProvider).save(
            sourceId: widget.sourceId,
            seriesId: widget.data.seriesId,
            bookId: widget.bookId,
            bookTitle: widget.data.title,
            pageNumber: _page,
            pngBytes: shot.png,
            width: shot.width,
            height: shot.height,
          ),
    );
    // Reflect the in-flight save (the overlay disables Save while busy).
    setState(() {});
    final outcome = await pending;
    if (outcome == null || !mounted) return;
    // The controller has left capture mode; rebuild to drop the overlay.
    setState(() {});
    switch (outcome) {
      case CaptureSaveOutcome.captureFailed:
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.readerCaptureFailed)),
        );
      case CaptureSaveOutcome.saveFailed:
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.readerCaptureSaveFailed)),
        );
      case CaptureSaveOutcome.saved:
        messenger.showSnackBar(SnackBar(
          content: Text(l10n.readerCaptureSaved),
          // Auto-dismiss the capture confirmation after a short timeout so it does
          // not linger over the page; still long enough to tap "View".
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: l10n.readerCaptureView,
            onPressed: () => navContext.push('/gallery'),
          ),
        ));
    }
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
    _focus.onPageTurned();
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
    // First-open direction nudge: only when the direction is a pure default
    // (no persisted settings, no source hint), reading a paged LTR layout, not
    // previewing, and not capturing (the overlay owns the screen then).
    final showDirectionNudge = widget.data.directionUnset &&
        !widget.preview &&
        !_capture.capturing &&
        !_directionNudgeDismissed &&
        s.mode.isPaged &&
        !effectiveRtl(s);
    return Stack(
      children: [
        Positioned.fill(
          child: RepaintBoundary(
            key: _captureBoundaryKey,
            // While capturing, the page ignores pointers so the overlay's
            // marquee gesture is the sole handler (no photo_view arena contest).
            child: IgnorePointer(
              ignoring: _capture.capturing,
              child: filteredView,
            ),
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
            title: _chromeTitle(context, source.pageCount),
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
        if (showDirectionNudge)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              // Sit above the bottom scrubber area when the chrome is shown.
              minimum: const EdgeInsets.only(bottom: 88),
              child: Center(
                child: DirectionNudge(
                  onRightToLeft: _acceptDirectionNudge,
                  onDismiss: _dismissDirectionNudge,
                ),
              ),
            ),
          ),
        if (_capture.capturing)
          Positioned.fill(
            child: CaptureOverlay(
              onCancel: _cancelCapture,
              onSave: _onCaptureSave,
              busy: _capture.saving,
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
                      label: context.l10n.tryAgain,
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
