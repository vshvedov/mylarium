import 'page_source.dart';

/// Cumulative top offsets (in logical px) for each webtoon page, given the
/// viewport [width], per-page aspect ratios, and the inter-page [gap]. Returns a
/// list of length `aspects.length + 1`; entry i is the scroll offset at which
/// page i starts, and the final entry is the total content extent.
///
/// Page height = width / aspect (fit-width), using [kDefaultPageAspect] when an
/// aspect is unknown. This mirrors `WebtoonView`'s reserved extents so the
/// scrubber and current-page tracking stay exact (no scroll-jump).
List<double> webtoonOffsets(double width, List<double?> aspects, double gap) {
  final offsets = <double>[0];
  var acc = 0.0;
  for (final a in aspects) {
    final aspect = (a == null || a <= 0) ? kDefaultPageAspect : a;
    acc += width / aspect + gap;
    offsets.add(acc);
  }
  return offsets;
}

/// The page index whose row contains scroll [offset], given cumulative
/// [offsets] (from [webtoonOffsets]). Clamped to a valid page index.
int webtoonPageAt(List<double> offsets, double offset) {
  if (offsets.length <= 1) return 0;
  // offsets has n+1 entries; pages are 0..n-1.
  for (var i = 0; i < offsets.length - 1; i++) {
    if (offset < offsets[i + 1]) return i;
  }
  return offsets.length - 2;
}
