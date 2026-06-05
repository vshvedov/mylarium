import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../data/komga/komga_api.dart';
import '../../data/komga/models/page_dto.dart';
import 'page_source.dart';

/// Online page source: serves Komga page images through the authenticated Dio
/// client. Page dimensions (when Komga supplies them) drive webtoon extents and
/// wide-page detection.
class KomgaPageSource implements PageSource {
  KomgaPageSource({
    required this.api,
    required this.sourceId,
    required this.bookId,
    required this.pages,
    this.cacheWidth,
  });

  final KomgaApi api;
  final String sourceId;
  final String bookId;
  final List<PageDto> pages;
  final int? cacheWidth;

  @override
  int get pageCount => pages.length;

  @override
  Future<ImageProvider> page(int i) async => imageProvider(i);

  /// Synchronous provider for the views (the provider itself defers the byte
  /// load to the image pipeline).
  @override
  ImageProvider imageProvider(int i) => KomgaPageImageProvider(
        api: api,
        sourceId: sourceId,
        bookId: bookId,
        pageNumber: pages[i].number,
        cacheWidth: cacheWidth,
      );

  @override
  ImageProvider thumbnail(int i) => KomgaPageImageProvider(
        api: api,
        sourceId: sourceId,
        bookId: bookId,
        pageNumber: pages[i].number,
        cacheWidth: kScrubberThumbWidth,
      );

  @override
  double? aspectRatio(int i) {
    final p = pages[i];
    final w = p.width, h = p.height;
    if (w != null && h != null && h > 0) return w / h;
    return null;
  }

  /// Landscape pages (width > height), shown solo in double-page mode.
  @override
  Set<int> get widePages => {
        for (var i = 0; i < pages.length; i++)
          if (_isWide(i)) i,
      };

  bool _isWide(int i) {
    final p = pages[i];
    final w = p.width, h = p.height;
    return w != null && h != null && h > 0 && w / h > 1.0;
  }
}

/// An [ImageProvider] for a single Komga page, keyed by
/// `(sourceId, bookId, pageNumber, cacheWidth)` so two servers sharing a bookId
/// never collide in the global [ImageCache]. Bytes load through the authed Dio
/// client; `cacheWidth` sizes the decode to the viewport.
@immutable
class KomgaPageImageProvider extends ImageProvider<KomgaPageImageProvider> {
  const KomgaPageImageProvider({
    required this.api,
    required this.sourceId,
    required this.bookId,
    required this.pageNumber,
    this.cacheWidth,
  });

  final KomgaApi api;
  final String sourceId;
  final String bookId;

  /// 1-based (Komga's page addressing).
  final int pageNumber;
  final int? cacheWidth;

  @override
  Future<KomgaPageImageProvider> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture<KomgaPageImageProvider>(this);

  @override
  ImageStreamCompleter loadImage(
    KomgaPageImageProvider key,
    ImageDecoderCallback decode,
  ) =>
      MultiFrameImageStreamCompleter(
        codec: _load(decode),
        scale: 1.0,
        debugLabel: 'komga:$sourceId:$bookId:$pageNumber',
      );

  Future<ui.Codec> _load(ImageDecoderCallback decode) async {
    final bytes = await api.getPage(bookId, pageNumber);
    if (bytes.isEmpty) {
      throw StateError('Empty page bytes for $bookId/$pageNumber');
    }
    final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
    final width = cacheWidth;
    return decode(
      buffer,
      // Size the decode to the viewport, but never UPSCALE: clamp to the
      // source's intrinsic width so a small scan is not blown up into a huge
      // (and softer) bitmap.
      getTargetSize: width == null
          ? null
          : (intrinsicWidth, intrinsicHeight) => ui.TargetImageSize(
                width: width < intrinsicWidth ? width : intrinsicWidth,
              ),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KomgaPageImageProvider &&
          other.sourceId == sourceId &&
          other.bookId == bookId &&
          other.pageNumber == pageNumber &&
          other.cacheWidth == cacheWidth;

  @override
  int get hashCode => Object.hash(sourceId, bookId, pageNumber, cacheWidth);
}
