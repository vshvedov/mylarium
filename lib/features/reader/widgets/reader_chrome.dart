import 'package:flutter/material.dart';

import '../reader_models.dart';

/// Immersive reader chrome: a top bar (back, title, mode/fit/options menus) and
/// a bottom thumbnail scrubber. The scrubber is RTL-aware (page 1 sits on the
/// right in right-to-left modes).
class ReaderChrome extends StatelessWidget {
  const ReaderChrome({
    super.key,
    required this.visible,
    required this.title,
    required this.settings,
    required this.pageLabel,
    required this.position,
    required this.count,
    required this.onClose,
    required this.onSettings,
    required this.onSeek,
  });

  final bool visible;
  final String title;
  final ReaderSettings settings;
  final String pageLabel;

  /// Current position (0-based) and total stops for the scrubber.
  final int position;
  final int count;

  final VoidCallback onClose;
  final void Function(ReaderSettings) onSettings;
  final void Function(int position) onSeek;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 150),
        child: Column(
          children: [
            _TopBar(
              title: title,
              settings: settings,
              onClose: onClose,
              onSettings: onSettings,
            ),
            const Spacer(),
            _Scrubber(
              rtl: settings.mode.isRtl,
              pageLabel: pageLabel,
              position: position,
              count: count,
              onSeek: onSeek,
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.title,
    required this.settings,
    required this.onClose,
    required this.onSettings,
  });

  final String title;
  final ReaderSettings settings;
  final VoidCallback onClose;
  final void Function(ReaderSettings) onSettings;

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
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
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

class _Scrubber extends StatelessWidget {
  const _Scrubber({
    required this.rtl,
    required this.pageLabel,
    required this.position,
    required this.count,
    required this.onSeek,
  });

  final bool rtl;
  final String pageLabel;
  final int position;
  final int count;
  final void Function(int position) onSeek;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface.withValues(alpha: 0.92),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              Text(pageLabel, style: Theme.of(context).textTheme.labelMedium),
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
                          value: position.clamp(0, count - 1).toDouble(),
                          onChanged: (v) => onSeek(v.round()),
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
