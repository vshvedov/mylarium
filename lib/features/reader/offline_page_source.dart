import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../core/archive/archive_reader.dart';
import 'page_source.dart';

/// Reads pages from a downloaded archive on disk via a persistent [ArchiveReader]
/// (one worker isolate kept alive for the open book, so a page read costs only
/// the decode - no per-page isolate spawn). Entries are listed once by the caller
/// and passed in. Implements the same [PageSource] contract as the online source
/// so the reader is unchanged.
class OfflinePageSource implements PageSource {
  OfflinePageSource({
    required this.reader,
    required this.sourceId,
    required this.bookId,
    required this.entries,
    this.cacheWidth,
  });

  final ArchiveReader reader;
  final String sourceId;
  final String bookId;
  final List<String> entries;
  final int? cacheWidth;

  @override
  int get pageCount => entries.length;

  @override
  ImageProvider imageProvider(int i) => imageProviderAt(i, cacheWidth);

  @override
  ImageProvider imageProviderAt(int i, int? cacheWidth) =>
      OfflinePageImageProvider(
        reader: reader,
        sourceId: sourceId,
        bookId: bookId,
        entry: entries[i],
        entryIndex: i,
        cacheWidth: cacheWidth,
      );

  @override
  ImageProvider thumbnail(int i) => OfflinePageImageProvider(
        reader: reader,
        sourceId: sourceId,
        bookId: bookId,
        entry: entries[i],
        entryIndex: i,
        cacheWidth: kScrubberThumbWidth,
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
/// [ImageCache] without colliding across sources. Bytes come from the persistent
/// [ArchiveReader] (shared, so not part of `==`); the decode is sized with
/// `cacheWidth`.
@immutable
class OfflinePageImageProvider
    extends ImageProvider<OfflinePageImageProvider> {
  const OfflinePageImageProvider({
    required this.reader,
    required this.sourceId,
    required this.bookId,
    required this.entry,
    required this.entryIndex,
    this.cacheWidth,
  });

  final ArchiveReader reader;
  final String sourceId;
  final String bookId;
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
    final bytes = await reader.page(entry);
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
