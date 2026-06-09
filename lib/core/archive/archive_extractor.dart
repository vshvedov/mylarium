import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:unrar/unrar.dart';

import 'magic_bytes.dart';
import 'natural_sort.dart';

/// Thrown when an archive is missing, of an unknown format, fails to decode, or
/// has no image entries (a valid-but-empty archive is treated as malformed so
/// the caller quarantines it).
class ArchiveException implements Exception {
  ArchiveException(this.message, {this.path});
  final String message;
  final String? path;

  @override
  String toString() =>
      'ArchiveException: $message${path != null ? ' ($path)' : ''}';
}

/// Decodes comic archives (CBZ via `archive`, CBR via the `unrar` FFI library)
/// off the UI isolate. Pure Dart (no Flutter import) so `dart test` can build
/// the native UnRAR hook. The decoder is chosen by magic bytes, not extension;
/// image entries are returned natural-sorted.
class ArchiveExtractor {
  const ArchiveExtractor();

  /// Natural-sorted image entry names inside [archivePath].
  Future<List<String>> entries(String archivePath) =>
      Isolate.run(() => _entries(archivePath));

  /// Decompressed bytes of [entry] inside [archivePath] (one-shot, in a throwaway
  /// isolate). The reader pages through [ArchiveReader] instead, which keeps a
  /// single worker isolate alive across reads; this remains for one-off extracts.
  Future<Uint8List> page(String archivePath, String entry) =>
      Isolate.run(() => readArchiveEntrySync(archivePath, entry));

  /// Bytes of the entry whose basename case-insensitively equals [entryName]
  /// (shallowest match wins), or null when no such entry exists. Used to pull
  /// ComicInfo.xml out of an imported archive without listing it as a page.
  Future<Uint8List?> tryReadEntry(String archivePath, String entryName) =>
      Isolate.run(() => _tryReadEntrySync(archivePath, entryName));
}

// --- isolate bodies (top-level so they are sendable) -----------------------

ArchiveFormat _sniff(String path) {
  final file = File(path);
  if (!file.existsSync()) {
    throw ArchiveException('Archive file missing', path: path);
  }
  final raf = file.openSync();
  try {
    final head = raf.readSync(8);
    return sniffArchiveFormat(Uint8List.fromList(head));
  } finally {
    raf.closeSync();
  }
}

List<String> _entries(String path) {
  final names = <String>[];
  switch (_sniff(path)) {
    case ArchiveFormat.zip:
      // Random-access: decode only the central directory (read from the end of
      // the file) rather than loading the whole archive into memory.
      final input = InputFileStream(path);
      try {
        final archive = ZipDecoder().decodeStream(input);
        for (final f in archive.files) {
          if (f.isFile && isImageEntry(f.name)) names.add(f.name);
        }
      } finally {
        input.closeSync();
      }
    case ArchiveFormat.rar:
      for (final e in UnrarExtractor().listFiles(path)) {
        if (!e.isDirectory && isImageEntry(e.name)) names.add(e.name);
      }
    case ArchiveFormat.unknown:
      throw ArchiveException('Unknown archive format', path: path);
  }
  if (names.isEmpty) {
    throw ArchiveException('No image entries in archive', path: path);
  }
  names.sort(naturalCompare);
  return names;
}

/// Synchronously decodes the bytes of [entry] inside the archive at [path] via a
/// random-access read (decode the central directory, then inflate only the
/// requested entry). Top-level + public so the same decode runs both in
/// [ArchiveExtractor]'s one-shot isolate and in the persistent [ArchiveReader]
/// worker.
Uint8List readArchiveEntrySync(String path, String entry) {
  switch (_sniff(path)) {
    case ArchiveFormat.zip:
      // Random-access read of a single entry: decode the central directory,
      // then inflate ONLY the requested entry by seeking to its local header.
      // Avoids reading and re-parsing the whole archive on every page turn (the
      // previous `decodeBytes(readAsBytesSync())` was O(archive size) per page).
      final input = InputFileStream(path);
      try {
        final archive = ZipDecoder().decodeStream(input);
        final file = archive.findFile(entry);
        if (file == null) {
          throw ArchiveException('Entry not found: $entry', path: path);
        }
        final bytes = file.readBytes();
        if (bytes == null) {
          throw ArchiveException('Could not read entry: $entry', path: path);
        }
        return bytes;
      } finally {
        input.closeSync();
      }
    case ArchiveFormat.rar:
      return UnrarExtractor().extractFile(path, entry);
    case ArchiveFormat.unknown:
      throw ArchiveException('Unknown archive format', path: path);
  }
}

/// Case-insensitive basename lookup of [entryName] inside the archive at
/// [path]; the shallowest match wins (a root-level ComicInfo.xml beats a
/// nested one). Returns null when absent.
Uint8List? _tryReadEntrySync(String path, String entryName) {
  final wanted = entryName.toLowerCase();
  int depth(String name) => name.replaceAll('\\', '/').split('/').length;
  bool matches(String name) =>
      name.replaceAll('\\', '/').split('/').last.toLowerCase() == wanted;

  String? best;
  switch (_sniff(path)) {
    case ArchiveFormat.zip:
      final input = InputFileStream(path);
      try {
        final archive = ZipDecoder().decodeStream(input);
        for (final f in archive.files) {
          if (!f.isFile || !matches(f.name)) continue;
          final current = best;
          if (current == null || depth(f.name) < depth(current)) best = f.name;
        }
        final found = best;
        if (found == null) return null;
        final bytes = archive.findFile(found)?.readBytes();
        if (bytes == null) {
          throw ArchiveException('Could not read entry: $found', path: path);
        }
        return bytes;
      } finally {
        input.closeSync();
      }
    case ArchiveFormat.rar:
      final unrar = UnrarExtractor();
      for (final e in unrar.listFiles(path)) {
        if (e.isDirectory || !matches(e.name)) continue;
        final current = best;
        if (current == null || depth(e.name) < depth(current)) best = e.name;
      }
      final found = best;
      return found == null ? null : unrar.extractFile(path, found);
    case ArchiveFormat.unknown:
      throw ArchiveException('Unknown archive format', path: path);
  }
}
