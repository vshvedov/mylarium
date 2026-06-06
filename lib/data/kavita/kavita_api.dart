import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../core/network/content_exception.dart';
import '../source/content_api.dart';
import '../source/models/book_dto.dart';
import '../source/models/collection_dto.dart';
import '../source/models/library_dto.dart';
import '../source/models/page.dart';
import '../source/models/page_dto.dart';
import '../source/models/readlist_dto.dart';
import '../source/models/series_dto.dart';
import '../source/models/series_search.dart';
import '../source/models/server_info.dart';
import 'auth/kavita_auth.dart';
import 'models/kavita_mappers.dart';
import 'models/kavita_pagination.dart';

/// Resolved owning ids for a Kavita chapter, cached so a progress write does not
/// re-resolve on every call.
class KavitaChapterCtx {
  const KavitaChapterCtx({
    required this.libraryId,
    required this.seriesId,
    required this.volumeId,
    required this.pages,
  });
  final int libraryId;
  final int seriesId;
  final int volumeId;
  final int pages;
}

/// Typed client for one Kavita server, implementing the shared [ContentApi].
///
/// Maps Kavita's library -> series -> volume -> chapter hierarchy onto the flat
/// library -> series -> book DTO contract: a "book" is a Kavita volume, and the
/// volume's sentinel chapter id is used to fetch pages and write progress.
/// Capabilities Kavita does not surface this phase (collections, read lists,
/// referential filters, recently-added books, keep-reading) return empty for
/// reads and throw for mutations, so the shared UI degrades gracefully.
class KavitaApi implements ContentApi {
  KavitaApi(this._dio, this._auth, this._apiKey);

  final Dio _dio;
  final KavitaAuth _auth;
  final String _apiKey;

  Map<int, int>? _libraryTypes;
  final Map<String, KavitaChapterCtx> _chapterCtx = {};

  Future<T> _guard<T>(Future<T> Function() run) async {
    try {
      return await run();
    } on DioException catch (e) {
      throw ContentException.fromDio(e);
    }
  }

  Future<void> _ensureLibraryTypes() async {
    if (_libraryTypes != null) return;
    final res = await _dio.get<Object?>('/api/Library/libraries');
    final map = <int, int>{};
    for (final l in (res.data as List?) ?? const []) {
      if (l is Map && l['id'] is num) {
        map[(l['id'] as num).toInt()] = (l['type'] as num?)?.toInt() ?? -1;
      }
    }
    _libraryTypes = map;
  }

  int? _libraryTypeFor(String libraryId) =>
      _libraryTypes?[int.tryParse(libraryId)];

  Future<KavitaChapterCtx> _chapterContext(String chapterId) async {
    final cached = _chapterCtx[chapterId];
    if (cached != null) return cached;
    final res = await _dio.get<Object?>('/api/Reader/chapter-info',
        queryParameters: {'chapterId': chapterId});
    final d = (res.data as Map?) ?? const {};
    final ctx = KavitaChapterCtx(
      libraryId: (d['libraryId'] as num?)?.toInt() ?? 0,
      seriesId: (d['seriesId'] as num?)?.toInt() ?? 0,
      volumeId: (d['volumeId'] as num?)?.toInt() ?? 0,
      pages: (d['pages'] as num?)?.toInt() ?? 0,
    );
    _chapterCtx[chapterId] = ctx;
    return ctx;
  }

  // --- Server / auth ---------------------------------------------------------

  @override
  Future<String?> fetchVersion() async {
    try {
      final res = await _dio.get<Object?>('/api/Server/server-info-slim');
      final data = res.data;
      if (data is Map) return data['kavitaVersion'] as String?;
    } on DioException {
      // Best-effort; the authed call surfaces real connectivity errors.
    }
    return null;
  }

  @override
  Future<bool> ping() async {
    try {
      await _dio.get<Object?>('/api/Health');
      return true;
    } on DioException catch (e) {
      // Any HTTP response means the server is reachable; a transport error
      // (no response) counts as offline.
      return e.response != null;
    }
  }

  @override
  Future<ServerInfo> validate() => _guard(() async {
        // Performing the handshake validates the API key; roles come from the
        // JWT claim (the authenticate body returns an empty roles array).
        final token = await _auth.token();
        final roles = KavitaAuth.rolesFromJwt(token);
        final version = await fetchVersion();
        return ServerInfo(version: version, roles: roles);
      });

  // --- Libraries / series ----------------------------------------------------

  @override
  Future<List<LibraryDto>> listLibraries() => _guard(() async {
        await _ensureLibraryTypes();
        final res = await _dio.get<Object?>('/api/Library/libraries');
        return ((res.data as List?) ?? const [])
            .whereType<Map<String, Object?>>()
            .map(kavitaLibraryToDto)
            .toList(growable: false);
      });

  @override
  Future<Page<SeriesDto>> listSeries({
    required int page,
    int size = 50,
    String? sort,
    SeriesSearch? search,
  }) =>
      _guard(() async {
        await _ensureLibraryTypes();
        // Full-text search routes to the dedicated endpoint.
        final fullText = search?.fullTextSearch;
        if (fullText != null) {
          final res = await _dio.get<Object?>('/api/Search/search',
              queryParameters: {'queryString': fullText});
          final hits = ((res.data as Map?)?['series'] as List?) ?? const [];
          final dtos = hits
              .whereType<Map<String, Object?>>()
              .map(kavitaSearchHitToDto)
              .toList(growable: false);
          return kavitaPage(null, dtos, requestedSize: size);
        }
        // Library-scoped browse uses the v2 library endpoint; otherwise all-v2.
        final libraryIds = search?.libraryIds;
        final query = {'PageNumber': page + 1, 'PageSize': size};
        final Response<Object?> res;
        if (libraryIds != null && libraryIds.length == 1) {
          res = await _dio.post<Object?>('/api/Series/v2',
              queryParameters: {...query, 'libraryId': libraryIds.first},
              data: const {});
        } else {
          res = await _dio.post<Object?>('/api/Series/all-v2',
              queryParameters: query, data: const {});
        }
        return _pagedSeries(res, size);
      });

  Page<SeriesDto> _pagedSeries(Response<Object?> res, int size) {
    final list = (res.data as List?) ?? const [];
    final dtos = list.whereType<Map<String, Object?>>().map((j) {
      return kavitaSeriesToDto(j, libraryType: _libraryTypeFor('${j['libraryId']}'));
    }).toList(growable: false);
    return kavitaPage(res.headers.value('Pagination'), dtos, requestedSize: size);
  }

  @override
  Future<Page<SeriesDto>> listSeriesNew({int page = 0, int size = 20}) =>
      _guard(() async {
        await _ensureLibraryTypes();
        final res = await _dio.post<Object?>('/api/Series/recently-added-v2',
            queryParameters: {'PageNumber': page + 1, 'PageSize': size},
            data: const {});
        return _pagedSeries(res, size);
      });

  @override
  Future<Page<SeriesDto>> listSeriesUpdated({int page = 0, int size = 20}) =>
      _guard(() async {
        await _ensureLibraryTypes();
        final res = await _dio.post<Object?>(
            '/api/Series/recently-updated-series',
            data: const {});
        // This endpoint returns a plain (unpaged) list; guard the shape.
        final list = (res.data as List?) ?? const [];
        final dtos = list
            .whereType<Map<String, Object?>>()
            .where((j) => j['seriesId'] != null || j['id'] != null)
            .map((j) => j['seriesId'] != null
                ? kavitaSearchHitToDto({...j, 'name': j['seriesName'] ?? j['name']})
                : kavitaSeriesToDto(j, libraryType: _libraryTypeFor('${j['libraryId']}')))
            .toList(growable: false);
        return kavitaPage(null, dtos, requestedSize: size);
      });

  @override
  Future<SeriesDto> getSeries(String seriesId) => _guard(() async {
        await _ensureLibraryTypes();
        final core = await _dio.get<Object?>('/api/Series/$seriesId');
        final meta = await _dio.get<Object?>('/api/Series/metadata',
            queryParameters: {'seriesId': seriesId});
        // Count books (flattened chapters) for the series detail count chip.
        final volumes = await _dio.get<Object?>('/api/Series/volumes',
            queryParameters: {'seriesId': seriesId});
        var booksCount = 0;
        for (final v in (volumes.data as List?) ?? const []) {
          if (v is Map) booksCount += ((v['chapters'] as List?) ?? const []).length;
        }
        final json = (core.data as Map?)?.cast<String, Object?>() ?? const {};
        return kavitaSeriesToDto(
          json,
          metadata: (meta.data as Map?)?.cast<String, Object?>(),
          libraryType: _libraryTypeFor('${json['libraryId']}'),
          booksCount: booksCount,
        );
      });

  // --- Books / chapters ------------------------------------------------------

  @override
  Future<Page<BookDto>> listBooks({
    required int page,
    int size = 50,
    String? sort,
    String? seriesId,
    SeriesSearch? search,
  }) =>
      _guard(() async {
        // Only the series-scoped book list is meaningful for Kavita. A
        // no-seriesId / search-only call (e.g. keep-reading) returns empty; the
        // home rails are backstopped by other feeds.
        if (seriesId == null) {
          return Page<BookDto>(
              content: const [], totalElements: 0, number: 0, last: true);
        }
        final res = await _dio.get<Object?>('/api/Series/volumes',
            queryParameters: {'seriesId': seriesId});
        final volumes = (res.data as List?) ?? const [];
        final libraryId =
            await _seriesLibraryId(seriesId, volumesResponse: volumes);
        final books = kavitaVolumesToBooks(volumes,
            seriesId: seriesId, libraryId: libraryId);
        return Page<BookDto>(
          content: books,
          totalElements: books.length,
          number: 0,
          last: true,
          empty: books.isEmpty,
        );
      });

  /// The owning library id for a series (needed on book rows). Resolved from the
  /// first volume's first chapter via chapter-info; falls back to ''.
  Future<String> _seriesLibraryId(String seriesId,
      {required List<Object?> volumesResponse}) async {
    for (final v in volumesResponse) {
      if (v is! Map) continue;
      final chapters = (v['chapters'] as List?) ?? const [];
      if (chapters.isEmpty) continue;
      final first = chapters.first;
      if (first is Map && first['id'] != null) {
        final ctx = await _chapterContext('${first['id']}');
        return '${ctx.libraryId}';
      }
    }
    return '';
  }

  @override
  Future<BookDto> getBook(String bookId) => _guard(() async {
        final ctx = await _chapterContext(bookId);
        final res = await _dio.get<Object?>('/api/Series/chapter',
            queryParameters: {'chapterId': bookId});
        final chap = (res.data as Map?)?.cast<String, Object?>() ?? const {};
        return kavitaChapterToBook(
          chap,
          null,
          seriesId: '${ctx.seriesId}',
          libraryId: '${ctx.libraryId}',
        );
      });

  @override
  Future<List<PageDto>> bookPages(String bookId) => _guard(() async {
        final ctx = await _chapterContext(bookId);
        return kavitaPages(ctx.pages);
      });

  @override
  Future<Uint8List> getPage(
    String bookId,
    int n, {
    bool zeroBased = false,
    String? convert,
    bool raw = false,
  }) =>
      _guard(() async {
        // Kavita pages are 0-based; [n] arrives 1-based (PageDto.number).
        final res = await _dio.get<List<int>>(
          '/api/Reader/image',
          queryParameters: {
            'chapterId': bookId,
            'page': n - 1,
            'apiKey': _apiKey,
          },
          options: Options(responseType: ResponseType.bytes),
        );
        return Uint8List.fromList(res.data ?? const []);
      });

  @override
  Future<Stream<List<int>>> downloadBookFile(String bookId) => _guard(() async {
        final res = await _dio.get<ResponseBody>(
          '/api/Download/chapter',
          queryParameters: {'chapterId': bookId},
          options: Options(responseType: ResponseType.stream),
        );
        return res.data!.stream;
      });

  // --- Progress --------------------------------------------------------------

  @override
  Future<void> patchReadProgress(
    String bookId, {
    required int page,
    required bool completed,
  }) =>
      _guard(() async {
        final ctx = await _chapterContext(bookId);
        // The ContentApi contract passes a 1-based page (Komga's convention);
        // Kavita's pageNum is 0-based, so subtract one. A completed chapter
        // reports every page read.
        final pageNum = completed ? ctx.pages : (page - 1).clamp(0, 1 << 31);
        await _dio.post<void>('/api/Reader/progress', data: {
          'libraryId': ctx.libraryId,
          'seriesId': ctx.seriesId,
          'volumeId': ctx.volumeId,
          'chapterId': int.tryParse(bookId) ?? bookId,
          'pageNum': pageNum,
        });
      });

  @override
  Future<void> deleteReadProgress(String bookId) => _guard(() async {
        final ctx = await _chapterContext(bookId);
        await _dio.post<void>('/api/Reader/progress', data: {
          'libraryId': ctx.libraryId,
          'seriesId': ctx.seriesId,
          'volumeId': ctx.volumeId,
          'chapterId': int.tryParse(bookId) ?? bookId,
          'pageNum': 0,
        });
      });

  @override
  Future<void> markSeriesRead(String seriesId) => _guard(() async {
        await _dio.post<void>('/api/Reader/mark-read',
            data: {'seriesId': int.tryParse(seriesId) ?? seriesId});
      });

  @override
  Future<void> markSeriesUnread(String seriesId) => _guard(() async {
        await _dio.post<void>('/api/Reader/mark-unread',
            data: {'seriesId': int.tryParse(seriesId) ?? seriesId});
      });

  // --- Thumbnails ------------------------------------------------------------

  @override
  Future<(Uint8List, String?)> seriesThumbnail(String seriesId) =>
      _image('/api/Image/series-cover', {'seriesId': seriesId});

  @override
  Future<(Uint8List, String?)> bookThumbnail(String bookId) =>
      _image('/api/Image/chapter-cover', {'chapterId': bookId});

  Future<(Uint8List, String?)> _image(
          String path, Map<String, Object?> query) =>
      _guard(() async {
        final res = await _dio.get<List<int>>(
          path,
          queryParameters: {...query, 'apiKey': _apiKey},
          options: Options(responseType: ResponseType.bytes),
        );
        return (Uint8List.fromList(res.data ?? const []), res.headers.value('etag'));
      });

  // --- Capability gaps (Kavita does not surface these this phase) ------------

  Page<T> _emptyPage<T>() =>
      Page<T>(content: const [], totalElements: 0, number: 0, last: true, empty: true);

  Never _unsupported() => throw const ContentException(
      ContentErrorKind.unknown, 'Not supported for Kavita.');

  @override
  Future<Page<BookDto>> onDeck({int page = 0, int size = 20}) async =>
      _emptyPage();

  @override
  Future<Page<BookDto>> listBooksLatest({int page = 0, int size = 20}) async =>
      _emptyPage();

  @override
  Future<Page<CollectionDto>> listCollections(
          {int page = 0, int size = 50}) =>
      _guard(() async {
        final res = await _dio.get<Object?>('/api/Collection');
        final dtos = ((res.data as List?) ?? const [])
            .whereType<Map<String, Object?>>()
            .map(kavitaCollectionToDto)
            .toList(growable: false);
        return kavitaPage(null, dtos, requestedSize: size);
      });

  @override
  Future<CollectionDto> getCollection(String id) async => _unsupported();

  @override
  Future<CollectionDto> createCollection(
          {required String name, required List<String> seriesIds}) async =>
      _unsupported();

  @override
  Future<void> updateCollection(String id,
          {required String name,
          required bool ordered,
          required List<String> seriesIds}) async =>
      _unsupported();

  @override
  Future<void> deleteCollection(String id) async => _unsupported();

  @override
  Future<Page<SeriesDto>> collectionSeries(String collectionId,
          {int page = 0, int size = 100}) =>
      _guard(() async {
        await _ensureLibraryTypes();
        final res = await _dio.get<Object?>('/api/Collection/all-series',
            queryParameters: {'collectionId': collectionId});
        final dtos = ((res.data as List?) ?? const [])
            .whereType<Map<String, Object?>>()
            .map((j) =>
                kavitaSeriesToDto(j, libraryType: _libraryTypeFor('${j['libraryId']}')))
            .toList(growable: false);
        return kavitaPage(null, dtos, requestedSize: size);
      });

  @override
  Future<Page<ReadListDto>> listReadLists({int page = 0, int size = 50}) =>
      _guard(() async {
        final res = await _dio.post<Object?>('/api/ReadingList/lists',
            queryParameters: {'pageNumber': page + 1, 'pageSize': size},
            data: const {});
        final dtos = ((res.data as List?) ?? const [])
            .whereType<Map<String, Object?>>()
            .map(kavitaReadListToDto)
            .toList(growable: false);
        return kavitaPage(res.headers.value('Pagination'), dtos,
            requestedSize: size);
      });

  @override
  Future<ReadListDto> getReadList(String id) async => _unsupported();

  @override
  Future<ReadListDto> createReadList(
          {required String name, required List<String> bookIds}) async =>
      _unsupported();

  @override
  Future<void> updateReadList(String id,
          {required String name,
          required bool ordered,
          required List<String> bookIds}) async =>
      _unsupported();

  @override
  Future<void> deleteReadList(String id) async => _unsupported();

  @override
  Future<Page<BookDto>> readListBooks(String readListId,
          {int page = 0, int size = 100}) =>
      _guard(() async {
        final res = await _dio.get<Object?>('/api/ReadingList/items',
            queryParameters: {'readingListId': readListId});
        final books = ((res.data as List?) ?? const [])
            .whereType<Map<String, Object?>>()
            .map(kavitaReadListItemToBook)
            .toList(growable: false);
        return Page<BookDto>(
          content: books,
          totalElements: books.length,
          number: 0,
          last: true,
          empty: books.isEmpty,
        );
      });

  @override
  Future<List<String>> listGenres() => _metadataNames('/api/Metadata/genres');

  @override
  Future<List<String>> listTags() => _metadataNames('/api/Metadata/tags');

  // Kavita exposes no publishers list endpoint; publishers come only as people
  // on series metadata, so the filter list stays empty.
  @override
  Future<List<String>> listPublishers() async => const [];

  @override
  Future<List<int>> listAgeRatings() => _guard(() async {
        final res = await _dio.get<Object?>('/api/Metadata/age-ratings');
        return ((res.data as List?) ?? const [])
            .whereType<Map>()
            .map((e) => (e['value'] as num?)?.toInt())
            .whereType<int>()
            .where((v) => v > 0) // 0 = "Unknown"; not a real rating
            .toList(growable: false);
      });

  /// Reads a Kavita metadata referential list (`{id, title}` objects) as titles.
  Future<List<String>> _metadataNames(String path) => _guard(() async {
        final res = await _dio.get<Object?>(path);
        return ((res.data as List?) ?? const [])
            .whereType<Map>()
            .map((e) => e['title'] as String?)
            .whereType<String>()
            .where((s) => s.isNotEmpty)
            .toList(growable: false);
      });
}
