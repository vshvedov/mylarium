import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/data/komga/komga_api.dart';
import 'package:mylarium/features/library/thumbnail_cache.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class _FakePathProvider extends PathProviderPlatform {
  _FakePathProvider(this.dir);
  final String dir;

  @override
  Future<String?> getApplicationSupportPath() async => dir;
}

/// Returns raw image bytes for any request (http_mock_adapter JSON-encodes the
/// body, so it cannot serve a binary response; this serves the bytes verbatim).
class _BytesAdapter implements HttpClientAdapter {
  _BytesAdapter(this.bytes);
  final List<int> bytes;

  @override
  Future<ResponseBody> fetch(RequestOptions options,
          Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async =>
      ResponseBody.fromBytes(Uint8List.fromList(bytes), 200, headers: {
        Headers.contentTypeHeader: ['image/jpeg'],
        'etag': ['"abc"'],
      });

  @override
  void close({bool force = false}) {}
}

/// An adapter that fails any request (proves a cache hit makes no network call).
class _FailingAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(RequestOptions options,
          Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async =>
      throw StateError('network should not be called on a cache hit');

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late Directory tempDir;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    tempDir = await Directory.systemTemp.createTemp('thumb_test');
    PathProviderPlatform.instance = _FakePathProvider(tempDir.path);
  });
  tearDown(() async {
    await db.close();
    if (tempDir.existsSync()) await tempDir.delete(recursive: true);
  });

  KomgaApi apiReturning(List<int> bytes) {
    final dio = Dio(BaseOptions(baseUrl: 'https://komga.test'))
      ..httpClientAdapter = _BytesAdapter(bytes);
    return KomgaApi(dio);
  }

  test('small image is stored inline as a BLOB and reused from cache', () async {
    final small = List<int>.filled(1024, 7);
    final cache = ThumbnailCache(db, apiReturning(small), 's1');

    final provider = await cache.provider('series', 'ser1');
    expect(provider, isA<MemoryImage>());

    final row = await db.getThumbnail('s1', 'series', 'ser1');
    expect(row?.bytes, isNotNull);
    expect(row?.diskPath, isNull);

    // A second cache whose network FAILS must still resolve (cache hit).
    final failing = Dio(BaseOptions(baseUrl: 'https://x'))
      ..httpClientAdapter = _FailingAdapter();
    final noNetwork = ThumbnailCache(db, KomgaApi(failing), 's1');
    final cached = await noNetwork.provider('series', 'ser1');
    expect(cached, isA<MemoryImage>());
  });

  test('large image spills to disk with a relative path', () async {
    final large = List<int>.filled(300 * 1024, 9);
    final cache = ThumbnailCache(db, apiReturning(large), 's1');

    final provider = await cache.provider('series', 'ser1');
    expect(provider, isA<FileImage>());

    final row = await db.getThumbnail('s1', 'series', 'ser1');
    expect(row?.bytes, isNull);
    expect(row?.diskPath, isNotNull);
    // Stored path is RELATIVE (no leading temp dir absolute path).
    expect(row!.diskPath!.startsWith('thumbnails/'), isTrue);

    final file = File('${tempDir.path}/${row.diskPath}');
    expect(file.existsSync(), isTrue);
    expect(file.lengthSync(), 300 * 1024);
  });
}
