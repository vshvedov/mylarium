import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/l10n.dart';
import '../../../app/theme/app_icons.dart';
import '../../../app/widgets/app_loading.dart';
import '../../../app/widgets/app_segmented_toggle.dart';
import '../color/color_settings.dart';
import '../color/color_settings_controller.dart';

/// Reader page color-correction controls: a quick on/off, a scope selector
/// (global / this series / this chapter), brightness/contrast/gamma sliders, a
/// tone-mode selector, an Auto (white-point) toggle, and Reset. Brightness,
/// contrast, and mode preview instantly (GPU); gamma and Auto re-decode the
/// page. Sliders commit once on release.
class ColorCorrectionSheet extends ConsumerStatefulWidget {
  const ColorCorrectionSheet({
    super.key,
    required this.sourceId,
    required this.seriesId,
    required this.bookId,
  });

  final String sourceId;
  final String seriesId;
  final String bookId;

  @override
  ConsumerState<ColorCorrectionSheet> createState() =>
      _ColorCorrectionSheetState();
}

class _ColorCorrectionSheetState extends ConsumerState<ColorCorrectionSheet> {
  // Transient drag overrides for the slider in flight (commit on release).
  double? _dragBrightness;
  double? _dragContrast;
  double? _dragGamma;

  ColorSettingsControllerProvider get _provider =>
      colorSettingsControllerProvider(
        widget.sourceId,
        widget.seriesId,
        widget.bookId,
      );

  ColorSettingsController get _controller => ref.read(_provider.notifier);

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final async = ref.watch(_provider);
    // Scrollable so the full control stack stays reachable on short phone
    // screens (the sheet caps at roughly half the screen height).
    return SingleChildScrollView(
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: async.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: AppLoadingIndicator(),
            ),
            error: (_, _) => Padding(
              padding: const EdgeInsets.all(24),
              child: Text(context.l10n.colorCorrectionUnavailable,
                  style: text.bodyMedium),
            ),
            data: (s) => _body(context, s),
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, ColorState s) {
    final text = Theme.of(context).textTheme;
    final editing = s.editing;
    final on = s.editingEnabled;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(context.l10n.readerColorCorrection, style: text.titleMedium),
            const Spacer(),
            // The switch toggles the CURRENTLY selected scope's correction; it
            // and the scope selector stay enabled so each scope can be turned
            // on/off independently.
            Switch(value: on, onChanged: _controller.setEnabled),
          ],
        ),
        const SizedBox(height: 8),
        _scopeSelector(s),
        const SizedBox(height: 8),
        // Only the adjustment controls are greyed while this scope is off; the
        // scope tabs above remain interactive so you can switch and toggle
        // another scope.
        AnimatedOpacity(
          opacity: on ? 1 : 0.4,
          duration: const Duration(milliseconds: 150),
          child: IgnorePointer(
            ignoring: !on,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _slider(
                  label: context.l10n.colorBrightness,
                  value: _dragBrightness ?? editing.brightness,
                  min: -1,
                  max: 1,
                  divisions: 40,
                  onChanged: (v) {
                    setState(() => _dragBrightness = v);
                    _controller.preview(editing.copyWith(brightness: v));
                  },
                  onChangeEnd: (v) async {
                    await _controller.commit(editing.copyWith(brightness: v));
                    if (mounted) setState(() => _dragBrightness = null);
                  },
                ),
                _slider(
                  label: context.l10n.colorContrast,
                  value: _dragContrast ?? editing.contrast,
                  min: -1,
                  max: 1,
                  divisions: 40,
                  onChanged: (v) {
                    setState(() => _dragContrast = v);
                    _controller.preview(editing.copyWith(contrast: v));
                  },
                  onChangeEnd: (v) async {
                    await _controller.commit(editing.copyWith(contrast: v));
                    if (mounted) setState(() => _dragContrast = null);
                  },
                ),
                _slider(
                  label: context.l10n.colorGamma,
                  value: _dragGamma ?? editing.gamma,
                  min: 0.4,
                  max: 2.5,
                  divisions: 42,
                  onChanged: (v) {
                    setState(() => _dragGamma = v);
                    _controller.preview(editing.copyWith(gamma: v));
                  },
                  onChangeEnd: (v) async {
                    await _controller.commit(editing.copyWith(gamma: v));
                    if (mounted) setState(() => _dragGamma = null);
                  },
                ),
                const SizedBox(height: 12),
                Text(context.l10n.colorTone, style: text.labelMedium),
                const SizedBox(height: 6),
                _modeSelector(editing),
                const SizedBox(height: 12),
                Row(
                  // No Spacer: the chip is the only flex child, so it keeps
                  // its intrinsic width when it fits and ellipsizes on narrow
                  // phones instead of overflowing.
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: FilterChip(
                        avatar: const Icon(AppIcons.colorCorrection, size: 18),
                        label: Text(
                          context.l10n.colorAutoWhitePoint,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        selected: editing.autoLevels,
                        onSelected: (v) =>
                            _controller.commit(editing.copyWith(autoLevels: v)),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _controller.reset,
                      icon: const Icon(AppIcons.refresh, size: 18),
                      label: Text(context.l10n.reset),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Both selectors use the app's pill toggle: segments share the width
  // equally and ellipsize, so the row can never overflow on narrow phones
  // (Material's SegmentedButton keeps its intrinsic width and overflows).
  Widget _scopeSelector(ColorState s) {
    final hasSeries = widget.seriesId.isNotEmpty;
    return AppSegmentedToggle<ColorScopeKind>(
      segments: [
        AppSegment(ColorScopeKind.book, context.l10n.colorScopeChapter),
        if (hasSeries)
          AppSegment(ColorScopeKind.series, context.l10n.colorScopeSeries),
        AppSegment(ColorScopeKind.global, context.l10n.colorScopeGlobal),
      ],
      selected: s.editingScope,
      onChanged: _controller.setScope,
    );
  }

  Widget _modeSelector(ColorAdjustments editing) {
    return AppSegmentedToggle<ColorMode>(
      segments: [
        AppSegment(ColorMode.none, context.l10n.colorModeNone),
        AppSegment(ColorMode.grayscale, context.l10n.colorModeGray),
        AppSegment(ColorMode.sepia, context.l10n.colorModeSepia),
        AppSegment(ColorMode.invert, context.l10n.colorModeInvert),
      ],
      selected: editing.mode,
      onChanged: (m) => _controller.commit(editing.copyWith(mode: m)),
    );
  }

  Widget _slider({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    required ValueChanged<double> onChangeEnd,
  }) {
    final text = Theme.of(context).textTheme;
    return Row(
      children: [
        SizedBox(width: 76, child: Text(label, style: text.labelMedium)),
        Expanded(
          child: Slider(
            min: min,
            max: max,
            divisions: divisions,
            value: value.clamp(min, max),
            onChanged: onChanged,
            onChangeEnd: onChangeEnd,
          ),
        ),
      ],
    );
  }
}
