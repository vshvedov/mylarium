import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/core/fs/app_paths.dart';
import 'package:mylarium/core/storage/secure_store.dart';
import 'package:mylarium/data/kavita/auth/kavita_credential.dart';
import 'package:mylarium/data/komga/auth/komga_credential.dart';
import 'package:mylarium/features/offline/download_manager.dart';
import 'package:mylarium/features/offline/downloader.dart';
import 'package:path/path.dart' as p;

class _InMemorySecureStore extends SecureStore {
  final Map<String, String> _v = {};
  @override
  Future<void> write(String key, String value) async => _v[key] = value;
  @override
  Future<String?> read(String key) async => _v[key];
  @override
  Future<void> delete(String key) async => _v.remove(key);
}

/// Fake downloader that writes [bytes] to the destination on enqueue and emits
/// a complete event on the global updates stream.
class _FakeDownloader implements Downloader {
  _FakeDownloader(this.bytes);
  final List<int> bytes;
  int calls = 0;
  String? lastUrl;
  final _controller = StreamController<DownloadUpdate>.broadcast();

  @override
  Stream<DownloadUpdate> get updates => _controller.stream;

  @override
  Future<void> enqueue({
    required String taskId,
    required String url,
    required Map<String, String> headers,
    required String relativeDirectory,
    required String filename,
    required bool requiresWifi,
  }) async {
    calls++;
    lastUrl = url;
    final abs = await AppPaths.resolve(p.join(relativeDirectory, filename));
    await Directory(p.dirname(abs)).create(recursive: true);
    await File(abs).writeAsBytes(bytes);
    _controller.add(DownloadUpdate(taskId, DownloadEventKind.complete));
  }

  @override
  Future<void> cancel(String taskId) async {}

  void close() => _controller.close();
}

void main() {
  late AppDatabase db;
  late Directory tmp;
  late KomgaCredentialStore credentials;
  final kavitaCredentials = KavitaCredentialStore(_InMemorySecureStore());

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    tmp = await Directory.systemTemp.createTemp('dl_test');
    AppPaths.debugOverrideRoot = tmp.path;
    await db.upsertSource(const SourcesCompanion(
      id: Value('s1'),
      kind: Value('komga'),
      baseUrl: Value('https://komga.test'),
      label: Value('T'),
    ));
    credentials = KomgaCredentialStore(_InMemorySecureStore());
    await credentials.write('s1', const ApiKeyCredential('key'));
  });
  tearDown(() async {
    AppPaths.debugOverrideRoot = null;
    await db.close();
    if (tmp.existsSync()) await tmp.delete(recursive: true);
  });

  Future<void> waitForAsset(String bookId) async {
    for (var i = 0; i < 50; i++) {
      if (await db.getCachedAsset('s1', bookId) != null) return;
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
    fail('CachedAsset for $bookId never appeared');
  }

  DownloadManager manager(_FakeDownloader d) => DownloadManager(
        db: db,
        downloader: d,
        credentialStore: credentials,
        kavitaCredentialStore: kavitaCredentials,
        apiResolver: (_) async => null,
      );

  test('enqueue downloads, records a CachedAsset, and writes the file',
      () async {
    final dl = _FakeDownloader([7, 7, 7, 7]);
    await manager(dl).enqueueBook('s1', 'b1');
    await waitForAsset('b1');

    final asset = await db.getCachedAsset('s1', 'b1');
    expect(asset, isNotNull);
    expect(asset!.sizeBytes, 4);
    final task = await db.getDownloadTask('s1', 'b1');
    expect(task?.state, 'complete');
    final file = File(await AppPaths.resolve(asset.relativePath));
    expect(file.existsSync(), isTrue);
  });

  test('manual download stores in the permanent downloads pool', () async {
    final dl = _FakeDownloader([1, 2, 3]);
    await manager(dl).enqueueBook('s1', 'b1', manual: true);
    await waitForAsset('b1');

    final asset = await db.getCachedAsset('s1', 'b1');
    expect(asset!.permanent, isTrue);
    expect(asset.relativePath, startsWith('media/downloads/'));
  });

  test('auto-cache disabled skips auto, but manual still downloads', () async {
    await db.getOrCreateSettings();
    await db.updateAutoCacheEnabled(false);

    final auto = _FakeDownloader([1]);
    await manager(auto).enqueueBook('s1', 'b1'); // auto -> skipped
    await Future<void>.delayed(const Duration(milliseconds: 60));
    expect(auto.calls, 0);
    expect(await db.getCachedAsset('s1', 'b1'), isNull);

    final man = _FakeDownloader([1, 2]);
    await manager(man).enqueueBook('s1', 'b1', manual: true);
    await waitForAsset('b1');
    expect((await db.getCachedAsset('s1', 'b1'))!.permanent, isTrue);
  });

  test('manual download promotes an existing auto-cached copy', () async {
    final dl = _FakeDownloader([9, 9]);
    final m = manager(dl);
    await m.enqueueBook('s1', 'b1'); // auto first
    await waitForAsset('b1');
    expect((await db.getCachedAsset('s1', 'b1'))!.permanent, isFalse);

    await m.enqueueBook('s1', 'b1', manual: true); // promote
    final asset = await db.getCachedAsset('s1', 'b1');
    expect(asset!.permanent, isTrue);
    expect(asset.relativePath, startsWith('media/downloads/'));
    expect(File(await AppPaths.resolve(asset.relativePath)).existsSync(),
        isTrue);
  });

  test('resumeAll reconciles an already-downloaded file with no CachedAsset',
      () async {
    // Simulate: a manual download whose file finished on disk while the app was
    // dead, so only a stale "running" task row exists (the bug: it showed
    // "Downloading" forever and never offered Remove).
    final rel = AppPaths.downloadRelativePath('s1', 'b1');
    final file = await AppPaths.prepareFile(rel);
    await file.writeAsBytes([1, 2, 3, 4, 5]);
    await db.upsertDownloadTask(DownloadTasksCompanion(
      sourceId: const Value('s1'),
      bookId: const Value('b1'),
      taskId: const Value('s1|b1'),
      state: const Value('running'),
      permanent: const Value(true),
      updatedAt: const Value(1),
    ));

    final dl = _FakeDownloader([9]);
    await manager(dl).resumeAll();

    final asset = await db.getCachedAsset('s1', 'b1');
    expect(asset, isNotNull, reason: 'reconciled from the on-disk file');
    expect(asset!.permanent, isTrue);
    expect(asset.sizeBytes, 5);
    expect(dl.calls, 0, reason: 'no re-download needed; file was already there');
    expect((await db.getDownloadTask('s1', 'b1'))?.state, 'complete');
  });

  test('enqueueSeries downloads every book of the series as permanent',
      () async {
    await db.upsertBook(BooksCompanion.insert(
        sourceId: 's1',
        id: 'b1',
        seriesId: 'ser1',
        libraryId: 'l',
        title: 'B1',
        number: '1'));
    await db.upsertBook(BooksCompanion.insert(
        sourceId: 's1',
        id: 'b2',
        seriesId: 'ser1',
        libraryId: 'l',
        title: 'B2',
        number: '2'));

    final dl = _FakeDownloader([1, 2, 3]);
    await manager(dl).enqueueSeries('s1', 'ser1');
    await waitForAsset('b1');
    await waitForAsset('b2');

    expect((await db.getCachedAsset('s1', 'b1'))!.permanent, isTrue);
    expect((await db.getCachedAsset('s1', 'b2'))!.permanent, isTrue);
  });

  test('enqueue is idempotent once cached', () async {
    final dl = _FakeDownloader([1]);
    final m = manager(dl);
    await m.enqueueBook('s1', 'b1');
    await waitForAsset('b1');
    await m.enqueueBook('s1', 'b1'); // already cached -> no-op
    expect(dl.calls, 1);
  });

  test('no-op without a stored credential', () async {
    final empty = KomgaCredentialStore(_InMemorySecureStore());
    final dl = _FakeDownloader([1]);
    await DownloadManager(
      db: db,
      downloader: dl,
      credentialStore: empty,
      kavitaCredentialStore: kavitaCredentials,
      apiResolver: (_) async => null,
    ).enqueueBook('s1', 'b1');
    await Future<void>.delayed(const Duration(milliseconds: 60));
    expect(dl.calls, 0);
    expect(await db.getCachedAsset('s1', 'b1'), isNull);
  });

  test('a Kavita source downloads the chapter with the apiKey in the URL',
      () async {
    await db.upsertSource(const SourcesCompanion(
      id: Value('s2'),
      kind: Value('kavita'),
      baseUrl: Value('https://kavita.test'),
      label: Value('K'),
    ));
    await kavitaCredentials.write('s2', const KavitaCredential('SECRETKEY'));
    final dl = _FakeDownloader([9, 9, 9]);
    addTearDown(dl.close);
    await manager(dl).enqueueBook('s2', '163', manual: true);
    for (var i = 0; i < 50; i++) {
      if (await db.getCachedAsset('s2', '163') != null) break;
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
    expect(dl.lastUrl,
        'https://kavita.test/api/Download/chapter?chapterId=163&apiKey=SECRETKEY');
    expect(await db.getCachedAsset('s2', '163'), isNotNull);
  });
}
