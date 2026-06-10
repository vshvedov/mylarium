import 'dart:io';

import 'package:path/path.dart' as p;

import 'app_paths.dart';
import 'backup_exclusion.dart';

/// Disk budget for staged tree archives. Generous enough that a reading
/// session's current and recent books stay staged (no re-copy when flipping
/// between chapters), small enough that an SD-card library never meaningfully
/// duplicates onto internal storage.
const int kScratchCapBytes = 768 << 20; // 768 MB

/// The staging area for in-place (SAF tree) archives: a tree book is copied
/// here before reading, because archive decoding needs random file access the
/// SAF content stream cannot provide. Staged copies are SCRATCH: keyed by
/// comic id, validated against the source file's mtime, LRU-evicted past
/// [kScratchCapBytes], and never part of the permanent media store.
class ScratchStore {
  const ScratchStore();

  static const scratchDir = 'media/scratch';

  static String _relPath(String comicId) =>
      p.join(scratchDir, '${_safe(comicId)}.archive');

  static String _safe(String segment) =>
      segment.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');

  /// The staged file for [comicId] if it exists and matches [lastModified]
  /// (epoch ms; null skips the freshness check), else null. A hit touches the
  /// file's mtime so eviction stays LRU.
  Future<File?> staged(String comicId, {int? lastModified}) async {
    final file = File(await AppPaths.resolve(_relPath(comicId)));
    if (!await file.exists()) return null;
    if (lastModified != null) {
      final stampFile = File('${file.path}.src');
      final stamp = await _readStamp(stampFile);
      if (stamp != lastModified) {
        // The source file changed on the card; the staging is stale.
        await _delete(file);
        return null;
      }
    }
    try {
      await file.setLastModified(DateTime.now());
    } on FileSystemException {
      // Touch is best-effort; eviction order degrades gracefully.
    }
    return file;
  }

  /// Prepares the destination file for staging [comicId] and records the
  /// source [lastModified] stamp. The caller writes the bytes (e.g. via
  /// saf_stream's copyToLocalFile), then the copy participates in the LRU.
  Future<File> prepare(String comicId, {int? lastModified}) async {
    final file = await AppPaths.prepareFile(_relPath(comicId));
    await BackupExclusion.exclude(file.parent.path);
    if (lastModified != null) {
      await File('${file.path}.src').writeAsString('$lastModified');
    }
    return file;
  }

  /// Deletes the staged copy for [comicId] if present.
  Future<void> evict(String comicId) async {
    final file = File(await AppPaths.resolve(_relPath(comicId)));
    await _delete(file);
  }

  /// Evicts least-recently-used staged archives until the store fits the cap.
  /// Never evicts [keepComicId] (the book being read right now).
  Future<void> enforceCap({String? keepComicId}) async {
    final dir = Directory(await AppPaths.resolve(scratchDir));
    if (!await dir.exists()) return;
    final keepPath =
        keepComicId == null ? null : '${_safe(keepComicId)}.archive';
    final files = <File>[];
    var total = 0;
    await for (final entity in dir.list()) {
      if (entity is! File || entity.path.endsWith('.src')) continue;
      files.add(entity);
      total += await entity.length();
    }
    if (total <= kScratchCapBytes) return;
    final stats = <(File, DateTime)>[
      for (final f in files) (f, (await f.stat()).modified),
    ]..sort((a, b) => a.$2.compareTo(b.$2));
    for (final (file, _) in stats) {
      if (total <= kScratchCapBytes) break;
      if (keepPath != null && p.basename(file.path) == keepPath) continue;
      total -= await file.length();
      await _delete(file);
    }
  }

  Future<int?> _readStamp(File stampFile) async {
    try {
      return int.tryParse(await stampFile.readAsString());
    } on FileSystemException {
      return null;
    }
  }

  Future<void> _delete(File file) async {
    try {
      if (await file.exists()) await file.delete();
      final stamp = File('${file.path}.src');
      if (await stamp.exists()) await stamp.delete();
    } on FileSystemException {
      // Best-effort cleanup; a stuck file is reclaimed on a later pass.
    }
  }
}
