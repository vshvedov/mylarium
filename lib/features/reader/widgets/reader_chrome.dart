import 'package:flutter/material.dart';

import '../reader_models.dart';

/// Immersive reader chrome: a top bar (back, title, mode/fit/options menus, and
/// a double-page nudge) plus a bottom thumbnail scrubber. The scrubber works in
/// page space, is RTL-aware (page 1 sits on the right in right-to-left modes),
/// and shows a live page-thumbnail preview while dragging.
class ReaderChrome extends StatefulWidget {
  const ReaderChrome({
    super.key,
    required this.visible,
    required this.title,
    required this.offline,
    required this.settings,
    required this.pageCount,
    required this.currentPage,
    required this.previewImage,
    required this.onClose,
    required this.onSettings,
    required this.onSeekPage,
    this.onNudge,
    this.nudged = false,
  });

  final bool visible;
  final String title;

  /// True when reading from the on-device cache (vs streaming from the server).
  final bool offline;
  final ReaderSettings settings;
  final int pageCount;

  /// Current page (0-based).
  final int currentPage;

  /// Provides a page's image for the scrubber preview thumbnail.
  final ImageProvider Function(int page) previewImage;

  final VoidCallback onClose;
  final void Function(ReaderSettings) onSettings;
  final void Function(int page) onSeekPage;

  /// Double-page single-page nudge (shown only when non-null).
  final VoidCallback? onNudge;
  final bool nudged;

  @override
  State<ReaderChrome> createState() => _ReaderChromeState();
}

class _ReaderChromeState extends State<ReaderChrome> {
  int? _dragPage;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !widget.visible,
      child: AnimatedOpacity(
        opacity: widget.visible ? 1 : 0,
        duration: const Duration(milliseconds: 150),
        child: Column(
          children: [
            _TopBar(
              title: widget.title,
              offline: widget.offline,
              settings: widget.settings,
              onClose: widget.onClose,
              onSettings: widget.onSettings,
              onNudge: widget.onNudge,
              nudged: widget.nudged,
            ),
            const Spacer(),
            if (_dragPage != null) _PreviewThumb(
              image: widget.previewImage(_dragPage!),
              label: '${_dragPage! + 1}',
            ),
            _scrubber(context),
          ],
        ),
      ),
    );
  }

  Widget _scrubber(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final rtl = widget.settings.mode.isRtl;
    final count = widget.pageCount;
    final value = (_dragPage ?? widget.currentPage).clamp(0, count - 1);
    return Material(
      color: scheme.surface.withValues(alpha: 0.92),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              Text('${value + 1}/$count',
                  style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(width: 12),
              Expanded(
                child: count <= 1
                    ? const SizedBox.shrink()
                    : Directionality(
                        textDirection:
                            rtl ? TextDirection.rtl : TextDirection.ltr,
                        child: Slider(
                          min: 0,
                          max: (count - 1).toDouble(),
                          divisions: count - 1,
                          value: value.toDouble(),
                          onChangeStart: (v) =>
                              setState(() => _dragPage = v.round()),
                          onChanged: (v) =>
                              setState(() => _dragPage = v.round()),
                          onChangeEnd: (v) {
                            widget.onSeekPage(v.round());
                            setState(() => _dragPage = null);
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewThumb extends StatelessWidget {
  const _PreviewThumb({required this.image, required this.label});

  final ImageProvider image;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 96,
            height: 140,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: scheme.outlineVariant),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image(
              image: image,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          ),
          const SizedBox(height: 4),
          Material(
            color: scheme.surface.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: Text(label,
                  style: Theme.of(context).textTheme.labelMedium),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.title,
    required this.offline,
    required this.settings,
    required this.onClose,
    required this.onSettings,
    required this.onNudge,
    required this.nudged,
  });

  final String title;
  final bool offline;
  final ReaderSettings settings;
  final VoidCallback onClose;
  final void Function(ReaderSettings) onSettings;
  final VoidCallback? onNudge;
  final bool nudged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface.withValues(alpha: 0.92),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: onClose,
              ),
              Icon(
                offline ? Icons.cloud_done_outlined : Icons.cloud_outlined,
                size: 18,
                semanticLabel: offline ? 'Reading offline' : 'Streaming',
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (onNudge != null)
                IconButton(
                  icon: const Icon(Icons.exposure_plus_1),
                  tooltip: 'Nudge spread',
                  isSelected: nudged,
                  onPressed: onNudge,
                ),
              PopupMenuButton<ReadingMode>(
                icon: const Icon(Icons.view_carousel),
                initialValue: settings.mode,
                onSelected: (m) => onSettings(settings.copyWith(mode: m)),
                itemBuilder: (_) => [
                  for (final m in ReadingMode.values)
                    PopupMenuItem(value: m, child: Text(_modeLabel(m))),
                ],
              ),
              PopupMenuButton<FitMode>(
                icon: const Icon(Icons.fit_screen),
                initialValue: settings.fit,
                onSelected: (f) => onSettings(settings.copyWith(fit: f)),
                itemBuilder: (_) => [
                  for (final f in FitMode.values)
                    PopupMenuItem(value: f, child: Text(_fitLabel(f))),
                ],
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.tune),
                onSelected: (key) {
                  switch (key) {
                    case 'invert':
                      onSettings(
                          settings.copyWith(invertTaps: !settings.invertTaps));
                    case 'doubleTap':
                      onSettings(settings.copyWith(
                          doubleTapZoom: !settings.doubleTapZoom));
                    case 'animate':
                      onSettings(settings.copyWith(
                          animatePageTurn: !settings.animatePageTurn));
                  }
                },
                itemBuilder: (_) => [
                  _check('invert', 'Invert taps', settings.invertTaps),
                  _check('doubleTap', 'Double-tap zoom', settings.doubleTapZoom),
                  _check('animate', 'Animate page turn',
                      settings.animatePageTurn),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuItem<String> _check(String value, String label, bool on) =>
      PopupMenuItem<String>(
        value: value,
        child: Row(
          children: [
            Icon(on ? Icons.check_box : Icons.check_box_outline_blank, size: 18),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      );
}

String _modeLabel(ReadingMode m) => switch (m) {
      ReadingMode.pagedLtr => 'Paged (LTR)',
      ReadingMode.pagedRtl => 'Paged (RTL)',
      ReadingMode.webtoon => 'Webtoon',
      ReadingMode.webtoonGaps => 'Webtoon (gaps)',
      ReadingMode.doublePage => 'Double page',
    };

String _fitLabel(FitMode f) => switch (f) {
      FitMode.width => 'Fit width',
      FitMode.height => 'Fit height',
      FitMode.screen => 'Fit screen',
      FitMode.original => 'Original',
    };
