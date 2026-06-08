import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

/// Modal bottom sheet helper that applies the app's sheet radius and a drag
/// handle.
class AppBottomSheet {
  const AppBottomSheet._();

  static Future<T?> show<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    Color? barrierColor,
  }) {
    final tokens = Theme.of(context).extension<DesignTokens>()!;
    final radius = tokens.sheetRadius;
    return showModalBottomSheet<T>(
      context: context,
      showDragHandle: true,
      // Honor an explicit barrierColor (e.g. the reader color panel passes
      // transparent to keep the page visible). Otherwise, in e-ink, use a light
      // barrier instead of the framework's heavy ~54% black scrim; null keeps
      // the framework default in the normal themes.
      barrierColor: barrierColor ?? (tokens.isEink ? kEinkBarrierColor : null),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
      ),
      builder: builder,
    );
  }
}
