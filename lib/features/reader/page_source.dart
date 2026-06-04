import 'package:flutter/widgets.dart';

/// The reader consumes a [PageSource], not a specific transport. T4 ships the
/// online [KomgaPageSource]; archive-backed `OfflinePageSource` (T5) and
/// `LocalArchivePageSource` (T7) implement the same contract.
abstract class PageSource {
  /// Number of pages in the book.
  int get pageCount;

  /// An [ImageProvider] for page [i] (0-based). The provider applies
  /// `cacheWidth` sizing; the reader is responsible for precache/evict.
  Future<ImageProvider> page(int i);

  /// Aspect ratio (width / height) of page [i] when known, else null. Used to
  /// reserve webtoon extents so loading a page does not jump the scroll.
  double? aspectRatio(int i);
}

/// Fallback aspect ratio (portrait comic page) reserved when a page's real
/// dimensions are unknown. Webtoon never reflows after a real decode, so this
/// preserves the no-scroll-jump guarantee.
const double kDefaultPageAspect = 0.66;
