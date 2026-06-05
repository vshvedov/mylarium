import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/theme_controller.dart' show appDatabaseProvider;
import '../../../core/db/database.dart';
import '../../../core/network/connectivity.dart';
import '../../../core/network/komga_exception.dart';
import '../../../data/comicvine/comic_vine_api.dart';
import '../../../data/comicvine/comic_vine_models.dart';
import '../../../data/komga/komga_providers.dart' show secureStoreProvider;
import '../../../data/komga/models/mappers.dart';
import '../../../data/source/source_providers.dart';

const _kComicVineApiKey = 'comicvine.apiKey';
const _kComicVineDismissed = 'comicvine.dismissed';

/// Whether the user has hidden the Comic Vine section ("Never show again"). When
/// true the section is omitted from detail screens entirely; re-enabled from the
/// Comic Vine settings screen.
final comicVineDismissedProvider = FutureProvider<bool>((ref) async {
  return await ref.watch(secureStoreProvider).read(_kComicVineDismissed) == '1';
});

/// The stored Comic Vine API key, or null when Comic Vine is not connected.
///
/// Comic Vine is OFF by default. Nothing about what the user reads is sent to
/// Comic Vine until a key is set: this opt-in is the privacy boundary (CLAUDE.md
/// hard rule 3). The key itself lives in the platform Keychain/Keystore, never
/// in the database or logs.
final comicVineApiKeyProvider = FutureProvider<String?>((ref) async {
  final key = await ref.watch(secureStoreProvider).read(_kComicVineApiKey);
  return (key == null || key.isEmpty) ? null : key;
});

/// Saves or clears the Comic Vine API key, refreshing [comicVineApiKeyProvider].
class ComicVineKeyController {
  ComicVineKeyController(this._ref);

  final Ref _ref;

  Future<void> save(String key) async {
    await _ref.read(secureStoreProvider).write(_kComicVineApiKey, key.trim());
    _ref.invalidate(comicVineApiKeyProvider);
  }

  Future<void> clear() async {
    await _ref.read(secureStoreProvider).delete(_kComicVineApiKey);
    _ref.invalidate(comicVineApiKeyProvider);
  }

  /// Hides ([dismissed] true) or restores the Comic Vine section on detail
  /// screens.
  Future<void> setDismissed(bool dismissed) async {
    final store = _ref.read(secureStoreProvider);
    if (dismissed) {
      await store.write(_kComicVineDismissed, '1');
    } else {
      await store.delete(_kComicVineDismissed);
    }
    _ref.invalidate(comicVineDismissedProvider);
  }
}

final comicVineKeyControllerProvider = Provider<ComicVineKeyController>(
  (ref) => ComicVineKeyController(ref),
);

// --- Data layer ------------------------------------------------------------

/// Thrown when there is no network and no cached Comic Vine data to fall back
/// on. The panel maps this to the offline placeholder.
class ComicVineOffline implements Exception {
  const ComicVineOffline();
}

const int _positiveTtlMs = 30 * 24 * 60 * 60 * 1000;
const int _negativeTtlMs = 7 * 24 * 60 * 60 * 1000;

/// A Comic Vine client built from the stored key, or null when no key is set.
/// Rebuilds when the key changes (the controller invalidates the key provider);
/// the old Dio is closed on dispose.
final comicVineApiProvider = FutureProvider<ComicVineApi?>((ref) async {
  final key = await ref.watch(comicVineApiKeyProvider.future);
  if (key == null) return null;
  final dio = buildComicVineDio(key);
  ref.onDispose(dio.close);
  return ComicVineApi(dio);
});

bool _isFresh(int fetchedAt, bool online, {required bool negative}) {
  if (!online) return true; // offline: always serve whatever is cached.
  final age = DateTime.now().millisecondsSinceEpoch - fetchedAt;
  // A backward clock skew yields a negative age; treat that as fresh (clamp).
  if (age < 0) return true;
  return age < (negative ? _negativeTtlMs : _positiveTtlMs);
}

/// Comic Vine details for a Komga series (matched to a CV volume). Returns null
/// for no match. Serves cache when offline or fresh; on a fetch error falls back
/// to a positive cache, else throws [ComicVineOffline] when offline.
final comicVineVolumeProvider =
    FutureProvider.family<ComicVineVolumeData?, (String, String)>((
      ref,
      args,
    ) async {
      final (sourceId, seriesId) = args;
      final db = ref.watch(appDatabaseProvider);
      // Await the settled connectivity value (not the loading state) so the
      // provider runs once and writes the cache before any rebuild, instead of
      // firing two fetches per open and hammering the Comic Vine API.
      final online = await ref.watch(isOnlineProvider.future);

      final cachedRow = await db.getCachedMetadata(
        sourceId,
        'comicvine.volume',
        seriesId,
      );
      Map<String, Object?>? cached;
      if (cachedRow != null) {
        cached = jsonDecode(cachedRow.json) as Map<String, Object?>;
        final negative = comicVineIsNoMatch(cached);
        if (_isFresh(cachedRow.fetchedAt, online, negative: negative)) {
          return negative ? null : volumeFromCache(cached);
        }
      }

      final api = await ref.watch(comicVineApiProvider.future);
      if (api == null) return null;

      try {
        // Resolve the series row, fetching + caching it when it is not in the
        // local cache yet (the common case when a detail is opened from a home
        // rail, and every case on a fresh install). Reading the local row
        // directly would lose the race against the detail screen's own fetch
        // and return "no match" without ever querying Comic Vine.
        var series = await db.getSeries(sourceId, seriesId);
        if (series == null) {
          final repo = await ref.watch(seriesRepositoryProvider.future);
          if (repo == null) return null;
          try {
            series = await repo.fetchSeries(sourceId, seriesId);
          } on KomgaException {
            return null;
          }
        }
        if (series == null) return null;
        final matches = await api.searchVolumes(
          comicVineSearchQuery(series.title),
        );
        final match = bestVolumeMatch(
          matches,
          title: series.title,
          booksCount: series.booksCount,
        );
        if (match == null) {
          await _writeCache(db, sourceId, 'comicvine.volume', seriesId,
              comicVineNoMatchPayload());
          return null;
        }
        final data = ComicVineVolumeData.fromVolume(await api.getVolume(match.id));
        await _writeCache(
            db, sourceId, 'comicvine.volume', seriesId, volumeToCache(data));
        return data;
      } catch (_) {
        if (cached != null && !comicVineIsNoMatch(cached)) {
          return volumeFromCache(cached);
        }
        if (!online) throw const ComicVineOffline();
        rethrow;
      }
    });

/// Comic Vine details for a Komga book (matched to a CV issue). Resolves the
/// parent volume first; if the volume has no match, returns null WITHOUT writing
/// an issue negative row (so a later volume re-match re-drives the issue).
final comicVineIssueProvider =
    FutureProvider.family<ComicVineIssueData?, (String, String)>((
      ref,
      args,
    ) async {
      final (sourceId, bookId) = args;
      final db = ref.watch(appDatabaseProvider);
      // Await the settled connectivity value (not the loading state) so the
      // provider runs once and writes the cache before any rebuild, instead of
      // firing two fetches per open and hammering the Comic Vine API.
      final online = await ref.watch(isOnlineProvider.future);

      final cachedRow = await db.getCachedMetadata(
        sourceId,
        'comicvine.issue',
        bookId,
      );
      Map<String, Object?>? cached;
      if (cachedRow != null) {
        cached = jsonDecode(cachedRow.json) as Map<String, Object?>;
        final negative = comicVineIsNoMatch(cached);
        if (_isFresh(cachedRow.fetchedAt, online, negative: negative)) {
          return negative ? null : issueFromCache(cached);
        }
      }

      final api = await ref.watch(comicVineApiProvider.future);
      if (api == null) return null;

      try {
        // Resolve the book row, fetching + caching it when it is not cached yet
        // (e.g. opened straight from On-Deck), for the same race reason as the
        // volume provider above.
        var book = await db.getBook(sourceId, bookId);
        if (book == null) {
          final komgaApi = await ref.watch(komgaApiForProvider(sourceId).future);
          if (komgaApi == null) return null;
          try {
            await db.upsertBook(bookToRow(sourceId, await komgaApi.getBook(bookId)));
            book = await db.getBook(sourceId, bookId);
          } on KomgaException {
            return null;
          }
        }
        if (book == null) return null;
        final volume = await ref.watch(
          comicVineVolumeProvider((sourceId, book.seriesId)).future,
        );
        if (volume == null) return null; // derived from the volume; not cached.

        final number = book.number.trim();
        if (!RegExp(r'^\d+(\.\d+)?$').hasMatch(number)) {
          await _writeCache(db, sourceId, 'comicvine.issue', bookId,
              comicVineNoMatchPayload());
          return null;
        }
        final issueRef = await api.findIssue(volume.matchedId, number);
        if (issueRef == null) {
          await _writeCache(db, sourceId, 'comicvine.issue', bookId,
              comicVineNoMatchPayload());
          return null;
        }
        final data = ComicVineIssueData.fromIssue(await api.getIssue(issueRef.id));
        await _writeCache(
            db, sourceId, 'comicvine.issue', bookId, issueToCache(data));
        return data;
      } catch (_) {
        if (cached != null && !comicVineIsNoMatch(cached)) {
          return issueFromCache(cached);
        }
        if (!online) throw const ComicVineOffline();
        rethrow;
      }
    });

Future<void> _writeCache(
  AppDatabase db,
  String sourceId,
  String ownerType,
  String ownerId,
  Map<String, Object?> payload,
) =>
    db.upsertCachedMetadata(
      CachedMetadataCompanion(
        sourceId: Value(sourceId),
        ownerType: Value(ownerType),
        ownerId: Value(ownerId),
        json: Value(jsonEncode(payload)),
        fetchedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
