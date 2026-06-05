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
    final radius = Theme.of(context).extension<DesignTokens>()!.sheetRadius;
    return showModalBottomSheet<T>(
      context: context,
      showDragHandle: true,
      // Allow a transparent barrier (e.g. the reader color panel keeps the page
      // fully visible while adjusting); null uses the framework default scrim.
      barrierColor: barrierColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
      ),
      builder: builder,
    );
  }
}
