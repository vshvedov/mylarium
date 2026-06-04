import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../core/archive/archive_extractor.dart';
import 'page_source.dart';

/// Reads pages from a downloaded archive on disk via [ArchiveExtractor] (in an
/// isolate). Entries are listed once by the caller and passed in. Implements the
/// same [PageSource] contract as the online source so the reader is unchanged.
class OfflinePageSource implements PageSource {
  OfflinePageSource({
    required this.extractor,
    required this.sourceId,
    required this.bookId,
    required this.archivePath,
    required this.entries,
    this.cacheWidth,
  });

  final ArchiveExtractor extractor;
  final String sourceId;
  final String bookId;
  final String archivePath;
  final List<String> entries;
  final int? cacheWidth;

  @override
  int get pageCount => entries.length;

  @override
  ImageProvider imageProvider(int i) => OfflinePageImageProvider(
        extractor: extractor,
        sourceId: sourceId,
        bookId: bookId,
        archivePath: archivePath,
        entry: entries[i],
        entryIndex: i,
        cacheWidth: cacheWidth,
      );

  @override
  Future<ImageProvider> page(int i) async => imageProvider(i);

  // Page dimensions are unknown offline without decoding; webtoon uses the
  // default aspect and double-page shows no wide pages.
  @override
  double? aspectRatio(int i) => null;

  @override
  Set<int> get widePages => const {};
}

/// An [ImageProvider] for one archive entry, keyed by
/// `(sourceId, bookId, entryIndex, cacheWidth)` so it dedupes in the global
/// [ImageCache] without colliding across sources. Bytes are extracted in the
/// isolate; the decode is sized with `cacheWidth`.
@immutable
class OfflinePageImageProvider
    extends ImageProvider<OfflinePageImageProvider> {
  const OfflinePageImageProvider({
    required this.extractor,
    required this.sourceId,
    required this.bookId,
    required this.archivePath,
    required this.entry,
    required this.entryIndex,
    this.cacheWidth,
  });

  final ArchiveExtractor extractor;
  final String sourceId;
  final String bookId;
  final String archivePath;
  final String entry;
  final int entryIndex;
  final int? cacheWidth;

  @override
  Future<OfflinePageImageProvider> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture<OfflinePageImageProvider>(this);

  @override
  ImageStreamCompleter loadImage(
    OfflinePageImageProvider key,
    ImageDecoderCallback decode,
  ) =>
      MultiFrameImageStreamCompleter(
        codec: _load(decode),
        scale: 1.0,
        debugLabel: 'offline:$sourceId:$bookId:$entryIndex',
      );

  Future<ui.Codec> _load(ImageDecoderCallback decode) async {
    final bytes = await extractor.page(archivePath, entry);
    if (bytes.isEmpty) {
      throw StateError('Empty page bytes for $bookId/$entry');
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
      other is OfflinePageImageProvider &&
          other.sourceId == sourceId &&
          other.bookId == bookId &&
          other.entryIndex == entryIndex &&
          other.cacheWidth == cacheWidth;

  @override
  int get hashCode => Object.hash(sourceId, bookId, entryIndex, cacheWidth);
}
