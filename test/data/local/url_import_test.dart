import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/core/fs/app_paths.dart';
import 'package:mylarium/data/local/import_service.dart';

void main() {
  late AppDatabase db;
  late Directory tmp;
  var idCounter = 0;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    tmp = await Directory.systemTemp.createTemp('url_import_test');
    AppPaths.debugOverrideRoot = tmp.path;
    idCounter = 0;
  });

  tearDown(() async {
    AppPaths.debugOverrideRoot = null;
    await db.close();
    if (tmp.existsSync()) await tmp.delete(recursive: true);
  });

  List<int> cbzBytes(Map<String, List<int>> entries) {
    final archive = Archive();
    entries.forEach((n, data) => archive.add(ArchiveFile.bytes(n, data)));
    return ZipEncoder().encodeBytes(archive);
  }

  ImportService serviceWith({
    UrlHeadInfo head = const UrlHeadInfo(),
    UrlHeadCheck? headCheck,
    UrlDownload? download,
  }) =>
      ImportService(
        db,
        newId: () => 'id-${idCounter++}',
        nowMs: () => 1700000000000,
        headCheck: headCheck ?? (_) async => head,
        downloadUrl: download ??
            (_, _) async => fail('download must not be called'),
      );

  test('imports a valid CBZ URL end-to-end with kind urlDownload', () async {
    final bytes = cbzBytes({
      'page1.jpg': [1],
      'page2.jpg': [2],
    });
    String? downloadedTo;
    final service = serviceWith(
      head: UrlHeadInfo(
        contentType: 'application/zip',
        contentLength: bytes.length,
      ),
      download: (url, destPath) async {
        downloadedTo = destPath;
        await File(destPath).writeAsBytes(bytes);
      },
    );

    final result = await service
        .importUrl(Uri.parse('https://example.com/comics/Naruto%20c12.cbz'));

    final file = result.files.single;
    expect(file.outcome, ImportOutcome.imported);
    expect(file.name, 'Naruto c12.cbz'); // decoded last path segment

    final comic = (await db.getLocalComic(file.comicId!))!;
    expect(comic.kind, 'urlDownload');
    expect(comic.series, 'Naruto');
    expect(comic.pagesCount, 2);
    expect(comic.sizeBytes, bytes.length);

    // The managed copy landed in the permanent media store.
    final abs = await AppPaths.resolve(comic.managedPath!);
    expect(File(abs).existsSync(), isTrue);

    // The scratch download was cleaned up.
    expect(downloadedTo, isNotNull);
    expect(File(downloadedTo!).existsSync(), isFalse);
  });

  test('rejects http before any HEAD or download', () async {
    var headCalled = false;
    var downloadCalled = false;
    final service = serviceWith(
      headCheck: (_) async {
        headCalled = true;
        return const UrlHeadInfo();
      },
      download: (_, _) async => downloadCalled = true,
    );

    final result =
        await service.importUrl(Uri.parse('http://example.com/book.cbz'));

    expect(result.files.single.outcome, ImportOutcome.failed);
    expect(result.files.single.reason, contains('https'));
    expect(headCalled, isFalse);
    expect(downloadCalled, isFalse);
  });

  test('rejects an oversize content-length before downloading', () async {
    var downloadCalled = false;
    final service = serviceWith(
      head: const UrlHeadInfo(
        contentType: 'application/zip',
        contentLength: kUrlImportMaxBytes + 1,
      ),
      download: (_, _) async => downloadCalled = true,
    );

    final result =
        await service.importUrl(Uri.parse('https://example.com/huge.cbz'));

    expect(result.files.single.outcome, ImportOutcome.failed);
    expect(result.files.single.reason, contains('500 MB'));
    expect(downloadCalled, isFalse);
  });

  test('rejects text/html before downloading', () async {
    var downloadCalled = false;
    final service = serviceWith(
      head: const UrlHeadInfo(contentType: 'text/html; charset=utf-8'),
      download: (_, _) async => downloadCalled = true,
    );

    final result =
        await service.importUrl(Uri.parse('https://example.com/page'));

    expect(result.files.single.outcome, ImportOutcome.notAnArchive);
    expect(result.files.single.reason, 'Not a comic archive URL');
    expect(downloadCalled, isFalse);
  });

  test('a dropped connection fails cleanly: no temp orphan, no row', () async {
    String? destPath;
    final service = serviceWith(
      head: const UrlHeadInfo(contentType: 'application/zip'),
      download: (url, dest) async {
        destPath = dest;
        // Simulate a connection dropped mid-transfer: partial bytes on disk,
        // then the downloader throws.
        await File(dest).writeAsBytes([1, 2, 3]);
        throw const SocketException('connection reset');
      },
    );

    final result =
        await service.importUrl(Uri.parse('https://example.com/book.cbz'));

    expect(result.files.single.outcome, ImportOutcome.failed);
    expect(result.files.single.reason, contains('Download failed'));
    // The partial temp file was deleted.
    expect(destPath, isNotNull);
    expect(File(destPath!).existsSync(), isFalse);
    // The import never reached the pipeline: no source row, no comic rows.
    expect(await db.localFilesSource(), isNull);
  });

  test('an unreachable URL (HEAD throws) reports failed', () async {
    final service = serviceWith(
      headCheck: (_) async => throw const SocketException('no route'),
    );

    final result =
        await service.importUrl(Uri.parse('https://example.com/book.cbz'));

    expect(result.files.single.outcome, ImportOutcome.failed);
    expect(result.files.single.reason, contains('Could not reach'));
  });

  test('a downloaded non-archive is rejected by magic bytes', () async {
    // octet-stream passes the HEAD gate; the sniff catches the lie.
    final service = serviceWith(
      head: const UrlHeadInfo(contentType: 'application/octet-stream'),
      download: (url, dest) async =>
          File(dest).writeAsString('<html>not a comic</html>'),
    );

    final result =
        await service.importUrl(Uri.parse('https://example.com/fake.cbz'));

    expect(result.files.single.outcome, ImportOutcome.notAnArchive);
  });

  test('urlDisplayName falls back to the host for a bare URL', () {
    expect(urlDisplayName(Uri.parse('https://example.com')), 'example.com');
    expect(urlDisplayName(Uri.parse('https://example.com/a/b.cbz')), 'b.cbz');
  });
}
