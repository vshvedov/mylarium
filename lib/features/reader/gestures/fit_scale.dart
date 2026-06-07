import 'package:flutter/widgets.dart';

import '../reader_models.dart';

/// The [BoxFit] for a reader [FitMode]. All reading modes render the page through
/// a `BoxFit` (zoom is layered on top by the focal-zoom viewer), so this is the
/// single mapping from the user's fit preference to layout.
///
/// - screen: fit the whole page.
/// - width: page width fills the viewport (may overflow vertically -> pan).
/// - height: page height fills the viewport (may overflow horizontally -> pan).
/// - original: native size (the closest practical "1:1", since the decode is
///   sized by cacheWidth).
BoxFit boxFitFor(FitMode fit) => switch (fit) {
      FitMode.screen => BoxFit.contain,
      FitMode.width => BoxFit.fitWidth,
      FitMode.height => BoxFit.fitHeight,
      FitMode.original => BoxFit.none,
    };
