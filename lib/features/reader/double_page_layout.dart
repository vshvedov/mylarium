/// Pure double-page pairing. Produces a list of page groups (each `[i]` solo or
/// `[i, i+1]` a spread) from a page count, honoring a solo cover offset and
/// wide pages (which are shown solo and resync parity afterward).
class DoublePageLayout {
  const DoublePageLayout();

  /// Pairs pages `0..count-1`.
  ///
  /// - [coverSolo]: page 0 is shown alone; pairing starts at index 1.
  /// - [widePages]: indices that are landscape/double-wide; each is solo. After
  ///   a solo page, pairing simply continues from the next index, so parity
  ///   resynchronizes automatically (no forced even pairing).
  ///
  /// Example `pairs(6, coverSolo: true, widePages: {3})` -> `[[0],[1,2],[3],[4,5]]`.
  List<List<int>> pairs(
    int count, {
    bool coverSolo = false,
    Set<int> widePages = const {},
  }) {
    final out = <List<int>>[];
    var i = 0;
    while (i < count) {
      if (i == 0 && coverSolo) {
        out.add([0]);
        i += 1;
      } else if (widePages.contains(i)) {
        out.add([i]);
        i += 1;
      } else if (i + 1 < count && !widePages.contains(i + 1)) {
        out.add([i, i + 1]);
        i += 2;
      } else {
        out.add([i]);
        i += 1;
      }
    }
    return out;
  }
}
