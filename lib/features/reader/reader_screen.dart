import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_icons.dart';
import '../../app/theme/design_tokens.dart';
import '../../core/network/komga_exception.dart';
import '../offline/offline_providers.dart';
import '../sync/sync_models.dart';
import '../sync/sync_providers.dart';
import 'double_page_layout.dart';
import 'double_page_view.dart';
import 'gestures/tap_zones.dart';
import 'komga_page_source.dart';
import 'offline_page_source.dart';
import 'page_source.dart';
import 'paged_view.dart';
import 'page_prefetcher.dart';
import 'reader_controller.dart';
import 'reader_models.dart';
import 'webtoon_metrics.dart';
import 'webtoon_view.dart';
import 'widgets/reader_chrome.dart';

/// Upper bound on the per-page decode width (physical px). Caps bitmap size on
/// large hi-DPI screens so the prefetch window fits the image-cache budget and
/// GPU uploads stay cheap. Tunable: raise for sharper full-screen pages on big
/// tablets, lower for smoother turning on weak GPUs. Pages are also never
/// upscaled past their intrinsic width.
const int kMaxDecodeWidth = 2048;

/// The reader. Loads the book online, then renders the current mode's view with
/// immersive chrome, tap-zone gestures, and a precache-ahead pipeline.
class ReaderScreen extends ConsumerWidget {
  const ReaderScreen({super.key, required this.sourceId, required this.bookId});

  final String sourceId;
  final String bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<DesignTokens>()!;
    final async = ref.watch(readerControllerProvider(sourceId, bookId));
    return Scaffold(
      backgroundColor: tokens.readerBackground,
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorState(
          title: 'Could not open this book',
          detail: friendlyError(e),
          onRetry: () =>
              ref.invalidate(readerControllerProvider(sourceId, bookId)),
        ),
        data: (data) => _readerPageCount(data) == 0
            ? const _ErrorState(title: 'This book has no pages')
            : _ReaderBody(sourceId: sourceId, bookId: bookId, data: data),
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
    required this.sourceId,
    required this.bookId,
    required this.data,
  });

  final String sourceId;
  final String bookId;
  final ReaderData data;

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

  bool _chrome = true;
  int? _cacheWidth;

  /// Reading-time + page-span accumulator for the current session. Lives on the
  /// State (a stable lifetime) so orientation rebuilds do not reset it.
  final _recorder = ReadingSessionRecorder();

  /// Debounces per-turn progress write-back (BookState + Komga queue).
  Timer? _progressDebounce;

  /// Double-page "single-page nudge": shifts the spread pairing by one page
  /// (in-session; a transient alignment correction).
  bool _nudge = false;

  /// Canonical current page index (0-based).
  int _page = 0;

  ReadingMode get _mode => widget.data.settings.mode;

  @override
  void initState() {
    super.initState();
    // Cap total decoded-page memory so a long book cannot grow the global image
    // cache without bound. The full cacheCapBytes-driven LRU media cache is T5.
    PaintingBinding.instance.imageCache.maximumSizeBytes = 256 << 20; // 256 MB
    // Resume at the saved page (clamped to the book's range), and start a
    // reading session at the opening page.
    final count = _readerPageCount(widget.data);
    _page = count == 0 ? 0 : widget.data.initialPage.clamp(0, count - 1);
    _recorder.onPage(_page, _nowMs());
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_onWebtoonScroll);
  }

  int _nowMs() => DateTime.now().millisecondsSinceEpoch;

  int get _pageCount => _source?.pageCount ?? _readerPageCount(widget.data);

  bool _isLastPage(int page) => _pageCount > 0 && page >= _pageCount - 1;

  /// Records a page change: feeds the session recorder and schedules a debounced
  /// progress write-back. The last page flushes immediately (marks completion).
  void _reportPage(int page) {
    _recorder.onPage(page, _nowMs());
    _progressDebounce?.cancel();
    if (_isLastPage(page)) {
      _pushProgress(page, completed: true);
    } else {
      _progressDebounce = Timer(
        const Duration(seconds: 2),
        () => _pushProgress(page, completed: false),
      );
    }
  }

  void _pushProgress(int page, {required bool completed}) {
    final sourceId = widget.sourceId;
    final bookId = widget.bookId;
    ref
        .read(syncEngineProvider.future)
        .then((e) => e.recordProgress(sourceId, bookId, page, completed))
        .catchError((Object _) {});
  }

  /// Appends the current reading session (if it has measurable activity) and
  /// resets the recorder so a later checkpoint or dispose does not double-emit.
  void _finalizeSession() {
    final span = _recorder.build(
      sourceId: widget.sourceId,
      bookId: widget.bookId,
      seriesId: widget.data.seriesId,
    );
    _recorder.reset();
    if (span == null) return;
    final isCompletion = _isLastPage(span.endPage);
    ref
        .read(syncEngineProvider.future)
        .then((e) => e.recordSession(span, isCompletion: isCompletion))
        .catchError((Object _) {});
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
      case AppLifecycleState.resumed:
        // Start a fresh session segment at the current page.
        _recorder.onPage(_page, _nowMs());
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
      setState(() => _page = page);
      _prefetcher?.onPage(page);
      _reportPage(page);
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
    if (old.data.settings.mode != _mode) {
      _resetControllerForMode();
    }
  }

  void _rebuildSource() {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final width = MediaQuery.sizeOf(context).width;
    // Decode to the viewport's physical width, but cap it: on a large hi-DPI
    // tablet the raw value (e.g. ~2560px) yields ~40 MB bitmaps that blow the
    // image-cache budget and hitch the GPU upload on every page. Capping bounds
    // per-page memory so the prefetch window fits with headroom; pinch-zoom
    // past this is a deliberate, rare path, not the per-turn cost. The decode
    // is additionally clamped to each page's intrinsic width (never upscaled)
    // inside the page sources.
    final cacheWidth = (width * dpr).round().clamp(1, kMaxDecodeWidth);
    // Only rebuild when the decode sizing actually changes (e.g. rotation), so
    // a metrics/theme dependency change does not reset the prefetch window.
    if (_source != null && _cacheWidth == cacheWidth) return;
    _cacheWidth = cacheWidth;
    final source = switch (widget.data.source) {
      OnlinePages(:final api, :final pages) => KomgaPageSource(
          api: api,
          sourceId: widget.sourceId,
          bookId: widget.bookId,
          pages: pages,
          cacheWidth: cacheWidth,
        ),
      OfflinePages(:final archivePath, :final entries) => OfflinePageSource(
          extractor: ref.read(archiveExtractorProvider),
          sourceId: widget.sourceId,
          bookId: widget.bookId,
          archivePath: archivePath,
          entries: entries,
          cacheWidth: cacheWidth,
        ),
    };
    _source = source;
    _recomputePairs();
    _prefetcher = PagePrefetcher.forContext(source, context);
    _pageController ??= PageController(initialPage: _controllerIndexFor(_page));
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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _progressDebounce?.cancel();
    // Push the final position (durable) and append the session (best-effort;
    // the SyncEngine + database are app-lifetime, so the write survives this
    // screen's teardown).
    _pushProgress(_page, completed: _isLastPage(_page));
    _finalizeSession();
    _zoomed.dispose();
    _scrollController.dispose();
    _pageController?.dispose();
    super.dispose();
  }

  void _onControllerPage(int index) {
    _page = _pageForControllerIndex(index);
    _prefetcher?.onPage(_page);
    _reportPage(_page);
    setState(() {});
  }

  void _toggleChrome() => setState(() => _chrome = !_chrome);

  void _step(int delta) {
    final controller = _pageController;
    if (controller == null || !controller.hasClients) return;
    final next = (controller.page?.round() ?? 0) + delta;
    final maxIndex =
        (_mode == ReadingMode.doublePage ? _pairs.length : _source!.pageCount) - 1;
    if (next < 0 || next > maxIndex) return;
    if (widget.data.settings.animatePageTurn) {
      controller.animateToPage(next,
          duration: const Duration(milliseconds: 220), curve: Curves.easeOut);
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
      rtl: s.mode.isRtl,
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
    final source = _source!;
    final s = widget.data.settings;
    final size = MediaQuery.sizeOf(context);
    final viewportAspect = size.height == 0 ? 0.7 : size.width / size.height;
    final view = switch (s.mode) {
      ReadingMode.pagedLtr || ReadingMode.pagedRtl => PagedView(
          pageController: _pageController!,
          pageCount: source.pageCount,
          imageBuilder: source.imageProvider,
          aspectRatioOf: source.aspectRatio,
          fit: s.fit,
          viewportAspect: viewportAspect,
          rtl: s.mode.isRtl,
          doubleTapZoom: s.doubleTapZoom,
          zoomed: _zoomed,
          onPageChanged: _onControllerPage,
          onTap: _handleTap,
        ),
      // Double-page is LTR in T4: the reading-mode enum has no RTL spread
      // variant and ReaderSettings carries no separate direction field, so
      // RTL (manga) double-page is a follow-up that needs a model addition.
      ReadingMode.doublePage => DoublePageView(
          pageController: _pageController!,
          pairs: _pairs,
          imageBuilder: source.imageProvider,
          fit: s.fit,
          rtl: false,
          onPageChanged: _onControllerPage,
          onTap: _handleTap,
        ),
      ReadingMode.webtoon || ReadingMode.webtoonGaps => WebtoonView(
          scrollController: _scrollController,
          pageCount: source.pageCount,
          imageBuilder: source.imageProvider,
          aspectRatio: source.aspectRatio,
          gaps: s.mode == ReadingMode.webtoonGaps,
          onTapToggle: _toggleChrome,
        ),
    };

    return Stack(
      children: [
        Positioned.fill(child: view),
        Positioned.fill(
          child: ReaderChrome(
            visible: _chrome,
            title: 'Page ${_page + 1} of ${source.pageCount}',
            offline: widget.data.source is OfflinePages,
            settings: s,
            pageCount: source.pageCount,
            currentPage: _page,
            previewImage: source.imageProvider,
            onClose: () => context.pop(),
            onSettings: (next) =>
                ref.read(readerControllerProvider(widget.sourceId, widget.bookId)
                    .notifier).updateSettings(next),
            onSeekPage: _seekPage,
            onNudge: s.mode == ReadingMode.doublePage ? _toggleNudge : null,
            nudged: _nudge,
          ),
        ),
      ],
    );
  }
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
                  Icon(AppIcons.brokenImage,
                      size: 44, color: scheme.onSurfaceVariant),
                  const SizedBox(height: 14),
                  Text(title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium),
                  if (detail != null) ...[
                    const SizedBox(height: 6),
                    Text(detail!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant)),
                  ],
                  if (onRetry != null) ...[
                    const SizedBox(height: 20),
                    FilledButton.tonalIcon(
                      icon: const Icon(AppIcons.refresh, size: 18),
                      label: const Text('Try again'),
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
