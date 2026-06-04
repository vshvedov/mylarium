import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../core/network/komga_exception.dart';
import 'models/book_dto.dart';
import 'models/collection_dto.dart';
import 'models/library_dto.dart';
import 'models/page.dart';
import 'models/page_dto.dart';
import 'models/readlist_dto.dart';
import 'models/series_dto.dart';
import 'models/series_search.dart';
import 'models/server_info.dart';

/// Typed client for one Komga server. [_dio] is configured by `buildKomgaDio`
/// with `baseUrl` = the server origin (no `/api/v1`); this client appends the
/// versioned path per call. Every method maps `DioException` to
/// [KomgaException] so callers never see raw transport errors.
class KomgaApi {
  KomgaApi(this._dio);

  final Dio _dio;

  static const _v1 = '/api/v1';
  static const _v2 = '/api/v2';

  Future<T> _guard<T>(Future<T> Function() run) async {
    try {
      return await run();
    } on DioException catch (e) {
      throw KomgaException.fromDio(e);
    }
  }

  /// Probes the server: build version (best-effort; null if the actuator is
  /// unavailable or secured) plus the authenticated account's roles. A non-JSON
  /// 2xx on `users/me` (e.g. a reverse-proxy login page) is treated as a 401.
  /// Reads the server build version from the actuator. Returns null on any
  /// error (the endpoint may be disabled or require admin); never throws, so it
  /// can be used as a pre-auth probe without masking connectivity errors that
  /// the subsequent authed call will surface.
  Future<String?> fetchVersion() async {
    try {
      final info = await _dio.get<Object?>('$_v1/actuator/info');
      final data = info.data;
      if (data is Map) {
        final build = data['build'];
        if (build is Map) return build['version'] as String?;
      }
    } on DioException {
      // Swallowed by design (see doc comment).
    }
    return null;
  }

  Future<KomgaServerInfo> validate() => _guard(() async {
        final version = await fetchVersion();
        final me = await _dio.get<Object?>('$_v2/users/me');
        final data = me.data;
        if (data is! Map) {
          throw const KomgaException(
              KomgaErrorKind.unauthorized, 'Authentication failed.');
        }
        final roles = ((data['roles'] as List?) ?? const [])
            .map((e) => e as String)
            .toSet();
        return KomgaServerInfo(version: version, roles: roles);
      });

  /// Libraries are returned as a plain (unpaged) array by Komga.
  Future<List<LibraryDto>> listLibraries() => _guard(() async {
        final res = await _dio.get<Object?>('$_v1/libraries');
        return ((res.data as List?) ?? const [])
            .map((e) => LibraryDto.fromJson(e as Map<String, Object?>))
            .toList(growable: false);
      });

  Future<Page<CollectionDto>> listCollections({
    int page = 0,
    int size = 50,
  }) =>
      _guard(() async {
        final res = await _dio.get<Object?>('$_v1/collections',
            queryParameters: {'page': page, 'size': size});
        return Page.fromJson(
            res.data! as Map<String, Object?>, CollectionDto.fromJson);
      });

  Future<Page<ReadListDto>> listReadLists({
    int page = 0,
    int size = 50,
  }) =>
      _guard(() async {
        final res = await _dio.get<Object?>('$_v1/readlists',
            queryParameters: {'page': page, 'size': size});
        return Page.fromJson(
            res.data! as Map<String, Object?>, ReadListDto.fromJson);
      });

  Future<Page<SeriesDto>> listSeries({
    required int page,
    int size = 50,
    String? sort,
    SeriesSearch? search,
  }) =>
      _guard(() async {
        final query = <String, Object?>{
          'page': page,
          'size': size,
          'sort': ?sort,
        };
        final Response<Object?> res;
        if (search == null) {
          // Fast path: legacy GET listing.
          res = await _dio.get('$_v1/series', queryParameters: query);
        } else {
          final fts = search.fullTextSearch;
          res = await _dio.post(
            '$_v1/series/list',
            queryParameters: {
              ...query,
              'full_text_search': ?fts,
            },
            data: search.toRequestBody(),
          );
        }
        return Page.fromJson(
            res.data! as Map<String, Object?>, SeriesDto.fromJson);
      });

  Future<Page<BookDto>> listBooks({
    required int page,
    int size = 50,
    String? sort,
    String? seriesId,
    SeriesSearch? search,
  }) =>
      _guard(() async {
        final query = <String, Object?>{
          'page': page,
          'size': size,
          'sort': ?sort,
        };
        final Response<Object?> res;
        if (search == null) {
          // Komga scopes books to a series via a nested path, not a query param.
          final path =
              seriesId == null ? '$_v1/books' : '$_v1/series/$seriesId/books';
          res = await _dio.get(path, queryParameters: query);
        } else {
          final fts = search.fullTextSearch;
          res = await _dio.post(
            '$_v1/books/list',
            queryParameters: {
              ...query,
              'full_text_search': ?fts,
            },
            data: search.toRequestBody(),
          );
        }
        return Page.fromJson(
            res.data! as Map<String, Object?>, BookDto.fromJson);
      });

  Future<List<PageDto>> bookPages(String bookId) => _guard(() async {
        final res = await _dio.get<Object?>('$_v1/books/$bookId/pages');
        return ((res.data as List?) ?? const [])
            .map((e) => PageDto.fromJson(e as Map<String, Object?>))
            .toList(growable: false);
      });

  /// Page image bytes. [n] is 1-based (Komga's addressing). [zeroBased] flips to
  /// 0-based via `?zero_based=true`; [convert] requests a format; [raw] returns
  /// original bytes (no `convert`).
  Future<Uint8List> getPage(
    String bookId,
    int n, {
    bool zeroBased = false,
    String? convert,
    bool raw = false,
  }) =>
      _guard(() async {
        final res = await _dio.get<List<int>>(
          '$_v1/books/$bookId/pages/$n',
          queryParameters: {
            if (zeroBased) 'zero_based': true,
            if (!raw && convert != null) 'convert': convert,
          },
          options: Options(responseType: ResponseType.bytes),
        );
        return Uint8List.fromList(res.data ?? const []);
      });

  Future<Stream<List<int>>> downloadBookFile(String bookId) => _guard(() async {
        final res = await _dio.get<ResponseBody>(
          '$_v1/books/$bookId/file',
          options: Options(responseType: ResponseType.stream),
        );
        return res.data!.stream;
      });

  Future<void> patchReadProgress(
    String bookId, {
    required int page,
    required bool completed,
  }) =>
      _guard(() async {
        await _dio.patch('$_v1/books/$bookId/read-progress',
            data: {'page': page, 'completed': completed});
      });

  /// One book by id (used by the reader to resolve a book's `seriesId` when the
  /// book was opened without a cached row, e.g. from an On-Deck card).
  Future<BookDto> getBook(String bookId) => _guard(() async {
        final res = await _dio.get<Object?>('$_v1/books/$bookId');
        return BookDto.fromJson(res.data! as Map<String, Object?>);
      });

  /// Recently added series (Komga `series/new`). Returns the same `Page<Series>`
  /// envelope as the list endpoints; consumed online by the home rails.
  Future<Page<SeriesDto>> listSeriesNew({int page = 0, int size = 20}) =>
      _guard(() async {
        final res = await _dio.get<Object?>('$_v1/series/new',
            queryParameters: {'page': page, 'size': size});
        return Page.fromJson(
            res.data! as Map<String, Object?>, SeriesDto.fromJson);
      });

  /// Recently updated series (Komga `series/updated`).
  Future<Page<SeriesDto>> listSeriesUpdated({int page = 0, int size = 20}) =>
      _guard(() async {
        final res = await _dio.get<Object?>('$_v1/series/updated',
            queryParameters: {'page': page, 'size': size});
        return Page.fromJson(
            res.data! as Map<String, Object?>, SeriesDto.fromJson);
      });

  /// Cover thumbnail bytes for a series, plus the response ETag when present.
  Future<(Uint8List, String?)> seriesThumbnail(String seriesId) =>
      _thumbnail('$_v1/series/$seriesId/thumbnail');

  /// Cover thumbnail bytes for a book, plus the response ETag when present.
  Future<(Uint8List, String?)> bookThumbnail(String bookId) =>
      _thumbnail('$_v1/books/$bookId/thumbnail');

  Future<(Uint8List, String?)> _thumbnail(String path) => _guard(() async {
        final res = await _dio.get<List<int>>(
          path,
          options: Options(responseType: ResponseType.bytes),
        );
        final etag = res.headers.value('etag');
        return (Uint8List.fromList(res.data ?? const []), etag);
      });

  Future<Page<BookDto>> onDeck({int page = 0, int size = 20}) =>
      _guard(() async {
        final res = await _dio.get<Object?>('$_v1/books/ondeck',
            queryParameters: {'page': page, 'size': size});
        return Page.fromJson(
            res.data! as Map<String, Object?>, BookDto.fromJson);
      });
}

/// Whether [version] is new enough for Komga API keys (>= 1.20.0). A null or
/// unparseable version returns true: the auth attempt is then authoritative.
bool versionSupportsApiKeys(String? version) {
  final parsed = parseKomgaVersion(version);
  if (parsed == null) return true;
  final (major, minor, _) = parsed;
  return major > 1 || (major == 1 && minor >= 20);
}

/// Parses a Komga build version into (major, minor, patch), ignoring any
/// `-qualifier` / `+build` suffix. Returns null when unparseable.
(int, int, int)? parseKomgaVersion(String? version) {
  if (version == null || version.isEmpty) return null;
  final head = version.split(RegExp(r'[-+]')).first;
  final parts = head.split('.');
  if (parts.isEmpty || int.tryParse(parts[0]) == null) return null;
  int at(int i) => i < parts.length ? (int.tryParse(parts[i]) ?? 0) : 0;
  return (at(0), at(1), at(2));
}
