import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:background_downloader/background_downloader.dart' as bd;
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:path/path.dart' as p;
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

/// Hard size cap for a URL import (500 MB). Enforced twice: against the HEAD
/// content-length before the download starts, and against the real file size
/// after the download lands (a server may omit or understate the length, so
/// the post-download check is the one that always holds).
const int kUrlImportMaxBytes = 500 * 1024 * 1024;

/// Content types accepted by [ImportService.importUrl]. `octet-stream` is
/// allowed because many file hosts serve archives as a generic byte stream;
/// the magic-byte sniff after download still decides for real. Anything else
/// (text/html and friends: a landing or error page) is rejected before any
/// bytes are downloaded.
const Set<String> kUrlImportAcceptedContentTypes = {
  'application/zip',
  'application/x-cbz',
  'application/x-cbr',
  'application/vnd.comicbook+zip',
  'application/vnd.comicbook-rar',
  'application/octet-stream',
};

/// What a pre-download HEAD probe learned about a URL. Either field may be
/// null (servers are not required to send them); null never rejects, the
/// post-download checks decide for real.
class UrlHeadInfo {
  const UrlHeadInfo({this.contentType, this.contentLength});
  final String? contentType;
  final int? contentLength;
}

/// Pre-download URL probe (production default: a Dio HEAD request).
typedef UrlHeadCheck = Future<UrlHeadInfo> Function(Uri url);

/// Downloads [url] to the absolute [destPath], throwing on failure
/// (production default: `background_downloader`, so the transfer survives app
/// backgrounding like offline downloads do).
typedef UrlDownload = Future<void> Function(Uri url, String destPath);

/// The display name for a URL import: the last path segment (decoded), or the
/// host when the URL has no path. Drives the filename heuristics and the
/// results sheet, mirroring [PickedFile.name].
String urlDisplayName(Uri url) {
  final segments = url.pathSegments.where((s) => s.isNotEmpty);
  return segments.isEmpty ? url.host : segments.last;
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
    UrlHeadCheck? headCheck,
    UrlDownload? downloadUrl,
  })  : _newId = newId ?? (() => const Uuid().v4()),
        _nowMs = nowMs ?? (() => DateTime.now().millisecondsSinceEpoch),
        _headCheck = headCheck ?? _dioHeadCheck,
        _downloadUrl = downloadUrl ?? _backgroundDownload;

  final AppDatabase _db;
  final ArchiveExtractor _extractor;
  final String Function() _newId;
  final int Function() _nowMs;
  final UrlHeadCheck _headCheck;
  final UrlDownload _downloadUrl;

  /// Matches the Thumbnails table contract: images at or under this size are
  /// stored inline as a BLOB; larger ones spill to disk.
  static const _inlineThumbnailCap = 256 * 1024;

  /// Returns the id of the device's single "Local files" source, creating its
  /// Sources row on first use. Callers that add the row select() it on the
  /// active-source notifier; never invalidate the keepAlive provider (its
  /// rebuild picks the lowest-sorted id and could switch sources).
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

  /// Imports the archive behind [url] into the Local files source (T5).
  ///
  /// Validates before downloading (https only, accepted content-type, size cap
  /// via a HEAD probe), downloads to a throwaway temp path, then runs the
  /// standard import pipeline recording `kind: urlDownload`. The temp file is
  /// always deleted, success or failure. Never throws; every failure surfaces
  /// as a [FileImportResult] with a clear reason.
  Future<ImportResult> importUrl(Uri url) async {
    final name = urlDisplayName(url);
    ImportResult fail(ImportOutcome outcome, String reason) =>
        ImportResult([FileImportResult(name, outcome, reason: reason)]);

    if (url.scheme != 'https') {
      return fail(ImportOutcome.failed, 'Only https URLs are supported');
    }
    final UrlHeadInfo head;
    try {
      head = await _headCheck(url);
    } on Object {
      return fail(ImportOutcome.failed, 'Could not reach the URL');
    }
    // Content-type parameters (e.g. "; charset=...") are irrelevant here.
    final type = head.contentType?.split(';').first.trim().toLowerCase();
    if (type != null &&
        type.isNotEmpty &&
        !kUrlImportAcceptedContentTypes.contains(type)) {
      return fail(ImportOutcome.notAnArchive, 'Not a comic archive URL');
    }
    final length = head.contentLength;
    if (length != null && length > kUrlImportMaxBytes) {
      return fail(ImportOutcome.failed, _oversizeReason);
    }

    // Scratch destination, never the permanent media store: only an archive
    // that passes the full import pipeline earns a managed copy.
    final temp = File(
        p.join(Directory.systemTemp.path, 'mylarium-url-${_newId()}.archive'));
    try {
      try {
        await _downloadUrl(url, temp.path);
      } on Object {
        return fail(ImportOutcome.failed, 'Download failed');
      }
      // The HEAD length is advisory (it can be missing or wrong); the cap is
      // re-enforced on the actual bytes before anything is imported.
      if (temp.existsSync() && temp.lengthSync() > kUrlImportMaxBytes) {
        return fail(ImportOutcome.failed, _oversizeReason);
      }
      final sourceId = await ensureLocalSource();
      final result = await _importOne(
        sourceId,
        PickedFile(path: temp.path, name: name),
        kind: SourceKind.urlDownload,
      );
      return ImportResult([result]);
    } finally {
      try {
        if (temp.existsSync()) temp.deleteSync();
      } on FileSystemException {
        // Best-effort cleanup; a stale file in temp is harmless.
      }
    }
  }

  static const _oversizeReason =
      'File is larger than ${kUrlImportMaxBytes ~/ (1024 * 1024)} MB';

  /// Production [UrlHeadCheck]: a short-lived bare Dio HEAD request (the
  /// Komga-configured client in core/network is server-bound; URL imports hit
  /// arbitrary hosts). A non-2xx response throws and surfaces as unreachable.
  static Future<UrlHeadInfo> _dioHeadCheck(Uri url) async {
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      followRedirects: true,
      maxRedirects: 5,
    ));
    try {
      final response = await dio.headUri<void>(url);
      return UrlHeadInfo(
        contentType: response.headers.value(Headers.contentTypeHeader),
        contentLength: int.tryParse(
            response.headers.value(Headers.contentLengthHeader) ?? ''),
      );
    } finally {
      dio.close();
    }
  }

  /// Production [UrlDownload]: `background_downloader`, so the transfer keeps
  /// running while the app is backgrounded (same engine as offline downloads).
  /// Downloads into the platform temp dir (the package's stable way to address
  /// it), then moves the file to [destPath] (also under temp, same volume).
  static Future<void> _backgroundDownload(Uri url, String destPath) async {
    final task = bd.DownloadTask(
      url: url.toString(),
      baseDirectory: bd.BaseDirectory.temporary,
      directory: 'mylarium-url-imports',
      filename: p.basename(destPath),
      updates: bd.Updates.status,
      retries: 3,
      allowPause: true,
    );
    final result = await bd.FileDownloader().download(task);
    if (result.status != bd.TaskStatus.complete) {
      final detail = result.exception?.description ?? result.status.name;
      throw StateError('Download did not complete: $detail');
    }
    final downloaded = File(await task.filePath());
    if (downloaded.path != destPath) {
      await downloaded.rename(destPath);
    }
  }

  Future<FileImportResult> _importOne(
    String sourceId,
    PickedFile f, {
    SourceKind kind = SourceKind.localCopy,
  }) async {
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
        kind: kind.name,
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

  /// Removes an imported comic: the managed copy, the cover thumbnail (row
  /// plus any spilled file), and the LocalComics row. [BookState] and
  /// [ReadingSessions] are kept deliberately so past reads still count in
  /// stats. File deletes are best-effort; the rows always go.
  Future<void> deleteImported(LocalComic comic) async {
    final rel = comic.managedPath;
    if (rel != null) {
      try {
        final file = File(await AppPaths.resolve(rel));
        if (await file.exists()) await file.delete();
      } on FileSystemException {
        // Best-effort: an undeletable file must not strand the rows.
      }
    }
    final thumb = await _db.getThumbnail(comic.sourceId, 'book', comic.id);
    final diskPath = thumb?.diskPath;
    if (diskPath != null) {
      try {
        final thumbFile = File(await AppPaths.resolve(diskPath));
        if (await thumbFile.exists()) await thumbFile.delete();
      } on FileSystemException {
        // Best-effort: an undeletable file must not strand the rows.
      }
    }
    await _db.deleteThumbnail(comic.sourceId, 'book', comic.id);
    await _db.deleteLocalComic(comic.id);
  }

  String _nameWithoutExtension(String name) {
    final dot = name.lastIndexOf('.');
    return dot > 0 ? name.substring(0, dot) : name;
  }
}
