import 'package:flutter/widgets.dart';

/// The reader consumes a [PageSource], not a specific transport. T4 ships the
/// online [KomgaPageSource]; archive-backed `OfflinePageSource` (T5) and
/// `LocalArchivePageSource` (T7) implement the same contract.
abstract class PageSource {
  /// Number of pages in the book.
  int get pageCount;

  /// A synchronous [ImageProvider] for page [i] (0-based). The provider itself
  /// defers the byte load to the image pipeline and applies `cacheWidth` sizing.
  /// The reader views use this directly.
  ImageProvider imageProvider(int i);

  /// A provider for page [i] (0-based) decoded to [cacheWidth] physical px,
  /// overriding the source's default width. The reader uses this to decode the
  /// focused page at a higher resolution than its neighbors (keeping zoom sharp
  /// while bounding memory). A null [cacheWidth] decodes at native resolution.
  ImageProvider imageProviderAt(int i, int? cacheWidth);

  /// A small-[kScrubberThumbWidth] provider for the scrubber drag preview. Reuses
  /// the same decode path as [imageProvider] (the byte fetch is unchanged; only
  /// the decode is shrunk), keyed distinctly in the image cache by its cacheWidth.
  ImageProvider thumbnail(int i);

  /// An [ImageProvider] for page [i], as a resolved future (used by the
  /// precache pipeline). Defaults to wrapping [imageProvider].
  Future<ImageProvider> page(int i);

  /// Aspect ratio (width / height) of page [i] when known, else null. Used to
  /// reserve webtoon extents so loading a page does not jump the scroll.
  double? aspectRatio(int i);

  /// Indices of landscape/double-wide pages (shown solo in double-page mode).
  /// Empty when page dimensions are unknown (e.g. offline before decode).
  Set<int> get widePages;
}

/// Fallback aspect ratio (portrait comic page) reserved when a page's real
/// dimensions are unknown. Webtoon never reflows after a real decode, so this
/// preserves the no-scroll-jump guarantee.
const double kDefaultPageAspect = 0.66;

/// Physical-pixel decode width for scrubber-preview thumbnails (T4). Small so the
/// decode and GPU upload are cheap and the thumbnail is cache-light; the byte
/// fetch is still the full page (a smaller fetch would need a server thumbnail API
/// we do not have).
const int kScrubberThumbWidth = 220;
