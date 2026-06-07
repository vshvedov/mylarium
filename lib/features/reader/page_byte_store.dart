import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/fs/app_paths.dart';

part 'page_byte_store.g.dart';

/// Default on-disk budget for the online page-byte cache. Separate from the
/// archive auto-cache cap (`AppSettings.cacheCapBytes`): this pool stores the
/// raw page images the reader streams so decoding a page at any width, or
/// re-visiting / zooming it, never re-hits the network.
const int kPageCacheCapBytes = 256 << 20; // 256 MB

/// One cached page file's disk facts, for pure LRU selection.
class PageCacheEntry {
  const PageCacheEntry({
    required this.path,
    required this.sizeBytes,
    required this.lastAccessedAt,
  });

  final String path;
  final int sizeBytes;
  final int lastAccessedAt;
}

/// Pure LRU selection for the page-byte cache: the relative or absolute paths
/// to delete (least-recently-accessed first) so the total fits [capBytes].
/// Mirrors `selectEvictions` for the archive pool.
List<String> selectPageEvictions(List<PageCacheEntry> entries, int capBytes) {
  final sorted = [...entries]
    ..sort((a, b) => a.lastAccessedAt.compareTo(b.lastAccessedAt));
  var total = sorted.fold<int>(0, (s, e) => s + e.sizeBytes);
  if (total <= capBytes) return const [];
  final victims = <String>[];
  for (final e in sorted) {
    if (total <= capBytes) break;
    victims.add(e.path);
    total -= e.sizeBytes;
  }
  return victims;
}

/// Fetch-once byte cache for online page images, keyed by
/// `(sourceId, bookId, pageNumber)` (width-independent). Concurrent requests
/// for the same page share a single [fetch] (single-flight). Files live under
/// applicationSupport (never temp/cache) and are LRU-evicted to
/// [kPageCacheCapBytes]. Every disk operation is best-effort: a cache failure
/// must never break reading.
class PageByteStore {
  PageByteStore({int capBytes = kPageCacheCapBytes, int Function()? nowMillis})
    : _cap = capBytes,
      _now = nowMillis ?? (() => DateTime.now().millisecondsSinceEpoch);

  final int _cap;
  final int Function() _now;
  final Map<String, Future<Uint8List>> _inFlight = {};
  int _writtenSinceSweep = 0;

  static const _pagesDir = 'media/pages';
  static const _sweepThreshold = 32 << 20; // sweep after ~32 MB of new writes

  static String _safe(String s) =>
      s.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');

  /// Relative path (under applicationSupport) for a cached page.
  String relativePath(String sourceId, String bookId, int pageNumber) =>
      p.join(_pagesDir, _safe(sourceId), _safe(bookId), '$pageNumber');

  /// Bytes for a page: a disk hit when present, else [fetch] (whose result is
  /// written to disk). Concurrent callers for the same page share one [fetch].
  Future<Uint8List> bytes(
    String sourceId,
    String bookId,
    int pageNumber,
    Future<Uint8List> Function() fetch,
  ) {
    final rel = relativePath(sourceId, bookId, pageNumber);
    final existing = _inFlight[rel];
    if (existing != null) return existing;
    final future = _load(rel, fetch);
    _inFlight[rel] = future;
    return future.whenComplete(() => _inFlight.remove(rel));
  }

  Future<Uint8List> _load(
    String rel,
    Future<Uint8List> Function() fetch,
  ) async {
    final abs = await AppPaths.resolve(rel);
    final file = File(abs);
    if (file.existsSync()) {
      try {
        final cached = await file.readAsBytes();
        if (cached.isNotEmpty) {
          // Touch for LRU (best-effort).
          try {
            file.setLastModifiedSync(
              DateTime.fromMillisecondsSinceEpoch(_now()),
            );
          } catch (_) {}
          return cached;
        }
      } catch (_) {
        // Unreadable cache file: fall through to a fresh fetch.
      }
    }
    final fetched = await fetch();
    await _write(rel, fetched);
    return fetched;
  }

  Future<void> _write(String rel, Uint8List bytes) async {
    if (bytes.isEmpty) return;
    try {
      final file = await AppPaths.prepareFile(rel);
      final tmp = File('${file.path}.tmp');
      await tmp.writeAsBytes(bytes, flush: true);
      await tmp.rename(file.path);
      _writtenSinceSweep += bytes.length;
      if (_writtenSinceSweep >= _sweepThreshold) {
        _writtenSinceSweep = 0;
        await _sweep();
      }
    } catch (_) {
      // A cache write failure must never break reading.
    }
  }

  Future<void> _sweep() async {
    try {
      final root = Directory(await AppPaths.resolve(_pagesDir));
      if (!root.existsSync()) return;
      final entries = <PageCacheEntry>[];
      for (final e in root.listSync(recursive: true)) {
        if (e is File && !e.path.endsWith('.tmp')) {
          final stat = e.statSync();
          entries.add(
            PageCacheEntry(
              path: e.path,
              sizeBytes: stat.size,
              lastAccessedAt: stat.modified.millisecondsSinceEpoch,
            ),
          );
        }
      }
      for (final victim in selectPageEvictions(entries, _cap)) {
        try {
          File(victim).deleteSync();
        } catch (_) {}
      }
    } catch (_) {}
  }
}

/// App-lifetime page-byte cache shared by every online reader source.
@Riverpod(keepAlive: true)
PageByteStore pageByteStore(Ref ref) => PageByteStore();
