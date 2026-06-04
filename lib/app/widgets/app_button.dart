import 'package:flutter/material.dart';

enum AppButtonKind { filled, tonal, text }

/// Thin wrapper over the Material button family so call sites use one widget
/// and the kind is a token, not a different class each time.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.kind = AppButtonKind.filled,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonKind kind;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final child = Text(label);
    switch (kind) {
      case AppButtonKind.filled:
        return icon == null
            ? FilledButton(onPressed: onPressed, child: child)
            : FilledButton.icon(
                onPressed: onPressed, icon: Icon(icon), label: child);
      case AppButtonKind.tonal:
        return icon == null
            ? FilledButton.tonal(onPressed: onPressed, child: child)
            : FilledButton.tonalIcon(
                onPressed: onPressed, icon: Icon(icon), label: child);
      case AppButtonKind.text:
        return icon == null
            ? TextButton(onPressed: onPressed, child: child)
            : TextButton.icon(
                onPressed: onPressed, icon: Icon(icon), label: child);
    }
  }
}
