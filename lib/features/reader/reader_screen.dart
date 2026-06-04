import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/design_tokens.dart';
import '../offline/offline_providers.dart';
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
        error: (e, _) => _ErrorState(message: '$e'),
        data: (data) => _readerPageCount(data) == 0
            ? const _ErrorState(message: 'This book has no pages.')
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

class _ReaderBodyState extends ConsumerState<_ReaderBody> {
  final _zoomed = ValueNotifier<bool>(false);
  final _scrollController = ScrollController();
  PageController? _pageController;

  PageSource? _source;
  List<List<int>> _pairs = const [];
  PagePrefetcher? _prefetcher;

  bool _chrome = true;
  int? _cacheWidth;

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
    _scrollController.addListener(_onWebtoonScroll);
  }

  void _onWebtoonScroll() {
    if (!_mode.isWebtoon || _source == null) return;
    final offsets = _webtoonOffsets();
    final page = webtoonPageAt(offsets, _scrollController.offset);
    if (page != _page) {
      setState(() => _page = page);
      _prefetcher?.onPage(page);
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
    final cacheWidth = (width * dpr).round();
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
    _zoomed.dispose();
    _scrollController.dispose();
    _pageController?.dispose();
    super.dispose();
  }

  void _onControllerPage(int index) {
    _page = _pageForControllerIndex(index);
    _prefetcher?.onPage(_page);
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
  const _ErrorState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.broken_image_outlined, size: 48),
                    const SizedBox(height: 12),
                    Text(message, textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}
