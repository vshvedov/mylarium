import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'comic_vine_models.dart';

const String kComicVineBaseUrl = 'https://comicvine.gamespot.com/api/';

/// Comic Vine rejects requests with a default/empty User-Agent (HTTP 403), so a
/// concrete identifier is required.
const String kComicVineUserAgent = 'Mylarium/1.0';

/// A Comic Vine body-level error. Comic Vine returns HTTP 200 with a
/// `status_code` in the body: 1 = OK, 100 = invalid key, 107 = rate limited.
class ComicVineApiError implements Exception {
  const ComicVineApiError(this.code, this.message);
  final int code;
  final String message;

  bool get isInvalidKey => code == 100;
  bool get isRateLimited => code == 107;

  @override
  String toString() => 'ComicVineApiError($code, $message)';
}

/// Builds a Dio for Comic Vine. A FRESH client (never via `buildKomgaDio`): it
/// injects the `api_key` + `format=json` query params and the required
/// User-Agent, and redacts the key in its own log line (the Komga redacting
/// logger masks `x-api-key`, not `api_key`, so it must not be reused here).
Dio buildComicVineDio(String apiKey, {void Function(String)? log}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: kComicVineBaseUrl,
      headers: const {'User-Agent': kComicVineUserAgent},
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      responseType: ResponseType.json,
    ),
  );
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        options.queryParameters['api_key'] = apiKey;
        options.queryParameters['format'] = 'json';
        handler.next(options);
      },
    ),
  );
  dio.interceptors.add(
    _ComicVineRedactingLog(log ?? (kDebugMode ? debugPrint : _noLog)),
  );
  return dio;
}

void _noLog(Object? _) {}

/// Logs a compact request line with the `api_key` value masked, so the secret
/// never reaches any log channel.
class _ComicVineRedactingLog extends Interceptor {
  _ComicVineRedactingLog(this.log);
  final void Function(String) log;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final params = {
      for (final e in options.queryParameters.entries)
        e.key: e.key == 'api_key' ? '***' : e.value,
    };
    log('CV ${options.method} ${options.path} $params');
    handler.next(options);
  }
}

/// Typed Comic Vine client over a [buildComicVineDio] Dio.
class ComicVineApi {
  ComicVineApi(this._dio);

  final Dio _dio;

  Future<List<CvVolumeMatch>> searchVolumes(String query) async {
    final body = await _get('search/', {
      'query': query,
      'resources': 'volume',
      'field_list': 'id,name,start_year,count_of_issues,publisher,deck',
      'limit': '10',
    });
    final results = body['results'];
    return results is List
        ? [
            for (final r in results)
              if (r is Map) CvVolumeMatch.fromJson(r.cast<String, Object?>()),
          ]
        : const [];
  }

  Future<CvVolume> getVolume(int id) async {
    final body = await _get('volume/4050-$id/', {
      'field_list':
          'id,name,deck,description,start_year,count_of_issues,publisher,'
          'characters,people,site_detail_url',
    });
    final results = body['results'];
    if (results is! Map) {
      throw const ComicVineApiError(-1, 'Comic Vine volume not found');
    }
    return CvVolume.fromJson(results.cast<String, Object?>());
  }

  Future<CvIssueRef?> findIssue(int volumeId, String issueNumber) async {
    final body = await _get('issues/', {
      'filter': 'volume:$volumeId,issue_number:$issueNumber',
      'field_list': 'id',
      'limit': '1',
    });
    final results = body['results'];
    if (results is! List || results.isEmpty) return null;
    final first = results.first;
    final id = first is Map ? first['id'] : null;
    return id is num ? CvIssueRef(id.toInt()) : null;
  }

  Future<CvIssue> getIssue(int id) async {
    final body = await _get('issue/4000-$id/', {
      'field_list':
          'id,name,deck,description,cover_date,issue_number,person_credits,'
          'character_credits,story_arc_credits,site_detail_url',
    });
    final results = body['results'];
    if (results is! Map) {
      throw const ComicVineApiError(-1, 'Comic Vine issue not found');
    }
    return CvIssue.fromJson(results.cast<String, Object?>());
  }

  /// Performs the GET and enforces Comic Vine's body-level `status_code`.
  Future<Map<String, Object?>> _get(
    String path,
    Map<String, Object?> query,
  ) async {
    final res = await _dio.get<Object?>(path, queryParameters: query);
    final data = res.data;
    if (data is! Map) {
      throw const ComicVineApiError(-1, 'Unexpected Comic Vine response');
    }
    final body = data.cast<String, Object?>();
    final status = (body['status_code'] as num?)?.toInt() ?? -1;
    if (status != 1) {
      throw ComicVineApiError(
        status,
        (body['error'] as String?) ?? 'Comic Vine error',
      );
    }
    return body;
  }
}
