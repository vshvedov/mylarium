import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/core/fs/app_paths.dart';
import 'package:mylarium/core/storage/secure_store.dart';
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

/// Fake downloader that writes [bytes] to the destination and completes.
class _FakeDownloader implements Downloader {
  _FakeDownloader(this.bytes);
  final List<int> bytes;
  int calls = 0;

  @override
  Stream<DownloadEvent> download({
    required String taskId,
    required String url,
    required Map<String, String> headers,
    required String relativeDirectory,
    required String filename,
    required bool requiresWifi,
  }) async* {
    calls++;
    final abs = await AppPaths.resolve(p.join(relativeDirectory, filename));
    await Directory(p.dirname(abs)).create(recursive: true);
    await File(abs).writeAsBytes(bytes);
    yield const DownloadEvent(DownloadEventKind.progress, progress: 1);
    yield const DownloadEvent(DownloadEventKind.complete);
  }

  @override
  Future<void> cancel(String taskId) async {}
}

void main() {
  late AppDatabase db;
  late Directory tmp;
  late KomgaCredentialStore credentials;

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
      apiResolver: (_) async => null,
    ).enqueueBook('s1', 'b1');
    await Future<void>.delayed(const Duration(milliseconds: 60));
    expect(dl.calls, 0);
    expect(await db.getCachedAsset('s1', 'b1'), isNull);
  });
}
