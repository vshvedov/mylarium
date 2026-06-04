import 'package:flutter/material.dart';

/// A responsive master-detail scaffold. At widths >= [breakpoint] it shows the
/// [master] (fixed [masterWidth]) beside the [detail] (or [detailPlaceholder]
/// when nothing is selected). Below the breakpoint it shows only the [master].
///
/// Width comes from the available constraints (not the screen), so it composes
/// inside split-screen and nested layouts. No platform checks.
class AdaptiveLayout extends StatelessWidget {
  const AdaptiveLayout({
    super.key,
    required this.master,
    this.detail,
    this.detailPlaceholder,
    this.breakpoint = 840,
    this.masterWidth = 360,
  });

  final Widget master;
  final Widget? detail;
  final Widget? detailPlaceholder;
  final double breakpoint;
  final double masterWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < breakpoint) return master;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(width: masterWidth, child: master),
            const VerticalDivider(width: 1),
            Expanded(
              child: detail ?? detailPlaceholder ?? const SizedBox.shrink(),
            ),
          ],
        );
      },
    );
  }
}
