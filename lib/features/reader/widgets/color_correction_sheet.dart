import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_icons.dart';
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: async.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (_, _) => Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Color correction unavailable', style: text.bodyMedium),
        ),
        data: (s) => _body(context, s),
      ),
    );
  }

  Widget _body(BuildContext context, ColorState s) {
    final text = Theme.of(context).textTheme;
    final editing = s.editing;
    final on = s.enabled;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Color correction', style: text.titleMedium),
            const Spacer(),
            Switch(value: on, onChanged: _controller.setEnabled),
          ],
        ),
        const SizedBox(height: 4),
        // Everything below is disabled (greyed) while the quick toggle is off.
        AnimatedOpacity(
          opacity: on ? 1 : 0.4,
          duration: const Duration(milliseconds: 150),
          child: IgnorePointer(
            ignoring: !on,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _scopeSelector(s),
                const SizedBox(height: 8),
                _slider(
                  label: 'Brightness',
                  value: _dragBrightness ?? editing.brightness,
                  min: -1,
                  max: 1,
                  divisions: 40,
                  onChanged: (v) => setState(() => _dragBrightness = v),
                  onChangeEnd: (v) async {
                    // Hold the drag value until the commit lands so the thumb
                    // does not snap back to the stale value for a frame.
                    await _controller.apply(editing.copyWith(brightness: v));
                    if (mounted) setState(() => _dragBrightness = null);
                  },
                ),
                _slider(
                  label: 'Contrast',
                  value: _dragContrast ?? editing.contrast,
                  min: -1,
                  max: 1,
                  divisions: 40,
                  onChanged: (v) => setState(() => _dragContrast = v),
                  onChangeEnd: (v) async {
                    await _controller.apply(editing.copyWith(contrast: v));
                    if (mounted) setState(() => _dragContrast = null);
                  },
                ),
                _slider(
                  label: 'Gamma',
                  value: _dragGamma ?? editing.gamma,
                  min: 0.4,
                  max: 2.5,
                  divisions: 42,
                  onChanged: (v) => setState(() => _dragGamma = v),
                  onChangeEnd: (v) async {
                    await _controller.apply(editing.copyWith(gamma: v));
                    if (mounted) setState(() => _dragGamma = null);
                  },
                ),
                const SizedBox(height: 12),
                Text('Tone', style: text.labelMedium),
                const SizedBox(height: 6),
                _modeSelector(editing),
                const SizedBox(height: 12),
                Row(
                  children: [
                    FilterChip(
                      avatar: const Icon(AppIcons.colorCorrection, size: 18),
                      label: const Text('Auto (white point)'),
                      selected: editing.autoLevels,
                      onSelected: (v) =>
                          _controller.apply(editing.copyWith(autoLevels: v)),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: _controller.reset,
                      icon: const Icon(AppIcons.refresh, size: 18),
                      label: const Text('Reset'),
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

  Widget _scopeSelector(ColorState s) {
    final hasSeries = widget.seriesId.isNotEmpty;
    return SegmentedButton<ColorScopeKind>(
      segments: [
        const ButtonSegment(
          value: ColorScopeKind.global,
          label: Text('Global'),
        ),
        if (hasSeries)
          const ButtonSegment(
            value: ColorScopeKind.series,
            label: Text('Series'),
          ),
        const ButtonSegment(
          value: ColorScopeKind.book,
          label: Text('Chapter'),
        ),
      ],
      selected: {s.editingScope},
      showSelectedIcon: false,
      onSelectionChanged: (sel) => _controller.setScope(sel.first),
    );
  }

  Widget _modeSelector(ColorAdjustments editing) {
    return SegmentedButton<ColorMode>(
      segments: const [
        ButtonSegment(value: ColorMode.none, label: Text('None')),
        ButtonSegment(value: ColorMode.grayscale, label: Text('Gray')),
        ButtonSegment(value: ColorMode.sepia, label: Text('Sepia')),
        ButtonSegment(value: ColorMode.invert, label: Text('Invert')),
      ],
      selected: {editing.mode},
      showSelectedIcon: false,
      onSelectionChanged: (sel) =>
          _controller.apply(editing.copyWith(mode: sel.first)),
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
