import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

/// Wraps [child] with a brief scale-down while pressed: a calm, bespoke
/// alternative to the Material ripple for cover tiles. Honors reduce-motion via
/// `MediaQuery.disableAnimationsOf` (the app folds the in-app reduce-motion
/// override into that flag), snapping instead of animating. The StatefulWidget
/// is created inside a parent's build, so `const` call sites stay const.
class PressableScale extends StatefulWidget {
  const PressableScale({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.97,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  void _set(bool v) {
    if (_pressed != v) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    final duration = reduce
        ? Duration.zero
        : (Theme.of(context).extension<DesignTokens>()?.motion.short ??
              const Duration(milliseconds: 180));
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: widget.onTap == null ? null : (_) => _set(true),
      onTapUp: widget.onTap == null ? null : (_) => _set(false),
      onTapCancel: widget.onTap == null ? null : () => _set(false),
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1.0,
        duration: duration,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
