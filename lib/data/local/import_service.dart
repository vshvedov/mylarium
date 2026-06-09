import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';

import '../../core/archive/archive_extractor.dart';
import '../../core/archive/magic_bytes.dart';
import '../../core/db/database.dart';
import '../../core/fs/app_paths.dart';
import '../../core/fs/backup_exclusion.dart';
import '../source/content_source.dart';
import 'comicinfo_parser.dart';
import 'filename_heuristics.dart';

/// A file handed over by the picker UI (T2): an absolute readable [path] plus
/// the user-facing [name] (pickers may return cache copies whose path basename
/// is mangled, so the display name travels separately and drives heuristics).
class PickedFile {
  const PickedFile({required this.path, required this.name});
  final String path;
  final String name;
}

/// Per-file import outcome. [malformed] is the quarantine case: the file
/// looked like an archive but failed to decode or held no page images; it is
/// skipped with a reason and the batch continues (imports never crash).
enum ImportOutcome { imported, duplicate, notAnArchive, malformed, failed }

/// The outcome for one picked file, for the T2 results sheet.
class FileImportResult {
  const FileImportResult(this.name, this.outcome, {this.reason, this.comicId});
  final String name;
  final ImportOutcome outcome;

  /// Human-readable skip/failure reason; null when [outcome] is imported.
  final String? reason;

  /// The new `LocalComics.id`; non-null only when [outcome] is imported.
  final String? comicId;
}

/// The outcome of one import batch.
class ImportResult {
  const ImportResult(this.files);
  final List<FileImportResult> files;

  int get importedCount =>
      files.where((f) => f.outcome == ImportOutcome.imported).length;
}

/// Copy-mode importer for the Local files source (T1). Per file: sniff magic
/// bytes (extension filters are UX-only), dedupe by size + sha256, copy into
/// the permanent media store (backup-excluded, relative path), read metadata
/// (ComicInfo.xml inside the archive overrides filename heuristics), write a
/// first-page cover thumbnail, and insert the LocalComics row.
class ImportService {
  ImportService(
    this._db, {
    this._extractor = const ArchiveExtractor(),
    String Function()? newId,
    int Function()? nowMs,
  })  : _newId = newId ?? (() => const Uuid().v4()),
        _nowMs = nowMs ?? (() => DateTime.now().millisecondsSinceEpoch);

  final AppDatabase _db;
  final ArchiveExtractor _extractor;
  final String Function() _newId;
  final int Function() _nowMs;

  /// Matches the Thumbnails table contract: images at or under this size are
  /// stored inline as a BLOB; larger ones spill to disk.
  static const _inlineThumbnailCap = 256 * 1024;

  /// Returns the id of the device's single "Local files" source, creating its
  /// Sources row on first use. Callers that add the row must invalidate the
  /// active-source provider (a T2 concern; see the keepAlive gotcha).
  Future<String> ensureLocalSource() => _db.transaction(() async {
        final existing = await _db.localFilesSource();
        if (existing != null) return existing.id;
        final id = _newId();
        await _db.upsertSource(SourcesCompanion.insert(
          id: id,
          kind: SourceKind.local.name,
          label: 'Local files',
        ));
        return id;
      });

  /// Imports [files] one at a time (archive decode is IO-bound and the UI
  /// wants ordered per-file progress); a failure in one file never aborts the
  /// batch.
  Future<ImportResult> importFiles(List<PickedFile> files) async {
    final sourceId = await ensureLocalSource();
    final results = <FileImportResult>[];
    for (final f in files) {
      results.add(await _importOne(sourceId, f));
    }
    return ImportResult(results);
  }

  Future<FileImportResult> _importOne(String sourceId, PickedFile f) async {
    try {
      final src = File(f.path);
      if (!src.existsSync()) {
        return FileImportResult(f.name, ImportOutcome.failed,
            reason: 'File not found');
      }

      // 1. Magic-byte sniff: a renamed non-archive never reaches the decoder.
      final raf = src.openSync();
      final Uint8List head;
      try {
        head = raf.readSync(8);
      } finally {
        raf.closeSync();
      }
      if (sniffArchiveFormat(head) == ArchiveFormat.unknown) {
        return FileImportResult(f.name, ImportOutcome.notAnArchive,
            reason: 'Not a comic archive');
      }

      // 2. Enumerate pages; a decode failure or an image-less archive is
      // quarantined (skipped with a reason), never a crash.
      final List<String> entries;
      try {
        entries = await _extractor.entries(f.path);
      } on ArchiveException catch (e) {
        return FileImportResult(f.name, ImportOutcome.malformed,
            reason: e.message);
      }

      // 3. Duplicate probe (PRD OQ3): same size + sha256 = same file.
      final sizeBytes = src.lengthSync();
      final hash = (await sha256.bind(src.openRead()).first).toString();
      final existing =
          await _db.findLocalComicByHash(sourceId, sizeBytes, hash);
      if (existing != null) {
        return FileImportResult(f.name, ImportOutcome.duplicate,
            reason: 'Already imported', comicId: existing.id);
      }

      // 4. Metadata: ComicInfo.xml inside the archive wins; the filename
      // fills the gaps.
      Uint8List? infoBytes;
      try {
        infoBytes = await _extractor.tryReadEntry(f.path, 'ComicInfo.xml');
      } on ArchiveException {
        // An unreadable ComicInfo entry degrades to filename heuristics; it
        // must not fail an import whose pages decoded fine.
      }
      final info = infoBytes == null ? null : parseComicInfo(infoBytes);
      final fromName = deriveFromFilename(f.name);
      final series = info?.series ?? fromName.series;
      final number = info?.number ?? fromName.number ?? '1';
      final title = info?.title ?? _nameWithoutExtension(f.name);

      // 5. Copy into the permanent media store (relative path recorded,
      // excluded from backup, never LRU-evicted).
      final id = _newId();
      final rel = AppPaths.localRelativePath(sourceId, id);
      final dest = await AppPaths.prepareFile(rel);
      await src.copy(dest.path);
      await BackupExclusion.exclude(dest.path);

      // 6. Cover thumbnail from the first page (best-effort: a cover failure
      // must not lose the import).
      try {
        final cover = await _extractor.page(dest.path, entries.first);
        await _writeCover(sourceId, id, cover);
      } on Object {
        // No cover; the grid shows the placeholder tile.
      }

      // 7. The row itself.
      await _db.insertLocalComic(LocalComicsCompanion.insert(
        id: id,
        sourceId: sourceId,
        kind: SourceKind.localCopy.name,
        managedPath: Value(rel),
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
        sizeBytes: Value(sizeBytes),
        contentHash: Value(hash),
        importedAt: _nowMs(),
      ));
      return FileImportResult(f.name, ImportOutcome.imported, comicId: id);
    } on Object catch (e) {
      return FileImportResult(f.name, ImportOutcome.failed,
          reason: e.toString());
    }
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
