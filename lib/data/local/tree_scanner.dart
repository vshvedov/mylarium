import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';

import '../../core/archive/archive_extractor.dart';
import '../../core/archive/magic_bytes.dart';
import '../../core/db/database.dart';
import '../../core/fs/app_paths.dart';
import '../source/content_source.dart';
import 'comicinfo_parser.dart';
import 'filename_heuristics.dart';
import 'tree_fs.dart';

/// Progress of one scan pass, for the folder source's progress UI.
class ScanProgress {
  const ScanProgress({
    required this.scanned,
    required this.added,
    required this.updated,
    this.currentName,
    this.done = false,
    this.cancelled = false,
  });

  /// Files inspected so far (archives and non-archives alike).
  final int scanned;
  final int added;
  final int updated;
  final String? currentName;
  final bool done;
  final bool cancelled;
}

/// Outcome of a rescan reconcile (PRD: added / updated / removed counts).
class RescanResult {
  const RescanResult({
    required this.added,
    required this.updated,
    required this.removed,
    this.cancelled = false,
  });

  final int added;
  final int updated;
  final int removed;
  final bool cancelled;
}

/// Walks an Android SAF folder source, sniffs archives, and reconciles
/// `LocalComics` rows by `(treeDocPath, lastModified)`:
///
/// - a new document inserts a row (subfolder name maps to the series;
///   ComicInfo.xml inside the archive overrides; loose root files fall back to
///   filename heuristics);
/// - a document whose mtime changed is re-enumerated IN PLACE (same row id,
///   so its [BookState] and sessions survive);
/// - a row whose document disappeared is removed (its [BookState] is kept,
///   per the PRD: reading history survives removal). Removal only runs after
///   a COMPLETE walk: a cancelled pass must never purge unvisited files.
///
/// Metadata extraction needs random access into the archive, so each candidate
/// is staged to a throwaway temp file and the temp is deleted right after; the
/// scan never accumulates copies (reading stages on demand via ScratchStore).
class TreeScanner {
  TreeScanner(
    this._db,
    this._fs, {
    this.extractor = const ArchiveExtractor(),
    String Function()? newId,
    int Function()? nowMs,
  })  : _newId = newId ?? (() => const Uuid().v4()),
        _nowMs = nowMs ?? (() => DateTime.now().millisecondsSinceEpoch);

  final AppDatabase _db;
  final TreeFs _fs;
  final ArchiveExtractor extractor;
  final String Function() _newId;
  final int Function() _nowMs;

  static const _inlineThumbnailCap = 256 * 1024;

  /// Folders deeper than this are not descended into (cycle/pathology guard).
  static const _maxDepth = 12;

  /// Scans [source] (kind safTree; `handle` = tree root URI), reconciling rows
  /// and emitting progress. [isCancelled] is polled between files; a cancelled
  /// pass keeps everything reconciled so far and skips the removal sweep.
  Stream<ScanProgress> scan(
    Source source, {
    bool Function()? isCancelled,
  }) async* {
    final root = source.handle;
    if (root == null) {
      yield const ScanProgress(scanned: 0, added: 0, updated: 0, done: true);
      return;
    }
    final cancelled = isCancelled ?? () => false;

    final existing = await _db.localComicsForSource(source.id);
    final byPath = {
      for (final row in existing)
        if (row.treeDocPath != null) row.treeDocPath!: row,
    };

    var scanned = 0, added = 0, updated = 0;
    final seenPaths = <String>{};
    var walkComplete = true;

    // BFS over (dirUri, dirName); the IMMEDIATE parent folder names a series.
    final queue = <(String, String, int)>[(root, source.label, 0)];
    while (queue.isNotEmpty) {
      if (cancelled()) {
        walkComplete = false;
        break;
      }
      final (dirUri, dirName, depth) = queue.removeAt(0);
      final List<TreeEntry> children;
      try {
        children = await _fs.list(dirUri);
      } catch (_) {
        // One unreadable folder must not abort the pass, but the removal
        // sweep is unsafe now: its files would read as "missing".
        walkComplete = false;
        continue;
      }
      for (final child in children) {
        if (cancelled()) {
          walkComplete = false;
          break;
        }
        if (child.isDir) {
          if (depth < _maxDepth) {
            queue.add((child.uri, child.name, depth + 1));
          }
          continue;
        }
        scanned++;
        yield ScanProgress(
          scanned: scanned,
          added: added,
          updated: updated,
          currentName: child.name,
        );
        seenPaths.add(child.uri);
        final known = byPath[child.uri];
        if (known != null &&
            known.lastModified == child.lastModified &&
            child.lastModified != 0) {
          continue; // unchanged
        }
        final isRootLevel = dirUri == root;
        final outcome = await _importOrUpdate(
          source.id,
          child,
          seriesFolder: isRootLevel ? null : dirName,
          existing: known,
        );
        switch (outcome) {
          case _FileOutcome.added:
            added++;
          case _FileOutcome.updated:
            updated++;
          case _FileOutcome.skipped:
            // Not an archive (or malformed): if a previously-good row exists
            // for this path it stays; the file may be mid-write on the card.
            break;
        }
      }
    }

    var removed = 0;
    if (walkComplete) {
      for (final row in existing) {
        final path = row.treeDocPath;
        if (path == null || seenPaths.contains(path)) continue;
        await _removeRow(row);
        removed++;
      }
    }

    yield ScanProgress(
      scanned: scanned,
      added: added,
      updated: updated,
      done: true,
      cancelled: !walkComplete,
    );
    _lastRemoved = removed;
  }

  // scan() cannot return a value alongside its stream; rescan() reads this
  // immediately after draining the stream (single-isolate sequencing).
  int _lastRemoved = 0;

  /// Runs a full reconcile pass and returns the added/updated/removed counts.
  Future<RescanResult> rescan(
    Source source, {
    bool Function()? isCancelled,
  }) async {
    ScanProgress last =
        const ScanProgress(scanned: 0, added: 0, updated: 0, done: true);
    await for (final p in scan(source, isCancelled: isCancelled)) {
      last = p;
    }
    return RescanResult(
      added: last.added,
      updated: last.updated,
      removed: _lastRemoved,
      cancelled: last.cancelled,
    );
  }

  Future<_FileOutcome> _importOrUpdate(
    String sourceId,
    TreeEntry file, {
    required String? seriesFolder,
    required LocalComic? existing,
  }) async {
    try {
      // 1. Magic-byte sniff (extension is never trusted): 8 bytes via SAF.
      final Uint8List head;
      try {
        head = await _fs.readBytes(file.uri, start: 0, count: 8);
      } catch (_) {
        return _FileOutcome.skipped;
      }
      if (sniffArchiveFormat(head) == ArchiveFormat.unknown) {
        return _FileOutcome.skipped;
      }

      // 2. Stage to a throwaway temp for random-access decode, then extract
      // page order + ComicInfo; malformed archives are quarantined (skipped).
      final tmp = await AppPaths.prepareFile(
        '${ScratchTmp.dir}/scan-${_newId()}.tmp',
      );
      try {
        await _fs.copyToLocal(file.uri, tmp.path);
        final List<String> entries;
        try {
          entries = await extractor.entries(tmp.path);
        } on ArchiveException {
          return _FileOutcome.skipped;
        }

        Uint8List? infoBytes;
        try {
          infoBytes = await extractor.tryReadEntry(tmp.path, 'ComicInfo.xml');
        } on ArchiveException {
          // Degrade to folder/filename metadata.
        }
        final info = infoBytes == null ? null : parseComicInfo(infoBytes);
        final fromName = deriveFromFilename(file.name);
        final series = info?.series ?? seriesFolder ?? fromName.series;
        final number = info?.number ?? fromName.number ?? '1';
        final title = info?.title ?? _nameWithoutExtension(file.name);

        final id = existing?.id ?? _newId();
        final companion = LocalComicsCompanion.insert(
          id: id,
          sourceId: sourceId,
          kind: SourceKind.safTree.name,
          treeDocPath: Value(file.uri),
          series: series,
          seriesSort: sortKey(series),
          number: number,
          numberSort: Value(double.tryParse(number)),
          volume: Value(info?.volume ?? fromName.volume),
          title: title,
          ageRating: Value(info?.ageRating),
          readingDirection: Value(
              info?.direction == ComicReadingDirection.rtl ? 'rtl' : 'ltr'),
          pageOrder: jsonEncode(entries),
          pagesCount: entries.length,
          sizeBytes: Value(file.length),
          lastModified:
              Value(file.lastModified == 0 ? null : file.lastModified),
          importedAt: existing?.importedAt ?? _nowMs(),
        );
        if (existing == null) {
          await _db.insertLocalComic(companion);
        } else {
          // Same row id: BookState/sessions keep pointing at this book.
          await _db.replaceLocalComic(id, companion);
        }

        // 3. Cover from the first page (best-effort).
        try {
          final cover = await extractor.page(tmp.path, entries.first);
          await _writeCover(sourceId, id, cover);
        } on Object {
          // Placeholder tile.
        }
        return existing == null ? _FileOutcome.added : _FileOutcome.updated;
      } finally {
        try {
          if (await tmp.exists()) await tmp.delete();
        } on FileSystemException {
          // A stuck temp is reclaimed by a later scratch sweep.
        }
      }
    } on Object {
      // A single bad file never aborts the scan.
      return _FileOutcome.skipped;
    }
  }

  Future<void> _removeRow(LocalComic row) async {
    final thumb = await _db.getThumbnail(row.sourceId, 'book', row.id);
    final diskPath = thumb?.diskPath;
    if (diskPath != null) {
      try {
        final f = File(await AppPaths.resolve(diskPath));
        if (await f.exists()) await f.delete();
      } on FileSystemException {
        // Best-effort.
      }
    }
    await _db.deleteThumbnail(row.sourceId, 'book', row.id);
    await _db.deleteLocalComic(row.id);
  }

  Future<void> _writeCover(
    String sourceId,
    String comicId,
    Uint8List bytes,
  ) async {
    Uint8List? inline;
    String? diskPath;
    if (bytes.length <= _inlineThumbnailCap) {
      inline = bytes;
    } else {
      final rel = AppPaths.thumbnailRelativePath(sourceId, 'book', comicId);
      final file = await AppPaths.prepareFile(rel);
      await file.writeAsBytes(bytes);
      diskPath = rel;
    }
    await _db.upsertThumbnail(ThumbnailsCompanion.insert(
      sourceId: sourceId,
      ownerType: 'book',
      ownerId: comicId,
      bytes: Value(inline),
      diskPath: Value(diskPath),
      fetchedAt: _nowMs(),
    ));
  }

  String _nameWithoutExtension(String name) {
    final dot = name.lastIndexOf('.');
    return dot > 0 ? name.substring(0, dot) : name;
  }
}

enum _FileOutcome { added, updated, skipped }

/// Scan-time temp staging location (inside the scratch area so any orphan is
/// swept with it).
class ScratchTmp {
  const ScratchTmp._();
  static const dir = 'media/scratch';
}
