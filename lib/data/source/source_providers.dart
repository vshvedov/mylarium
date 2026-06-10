import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/theme/theme_controller.dart' show appDatabaseProvider;
import '../../core/db/database.dart';
import '../kavita/kavita_providers.dart';
import '../komga/komga_providers.dart';
import '../repositories/book_repository.dart';
import '../repositories/collection_repository.dart';
import '../repositories/library_repository.dart';
import '../repositories/readlist_repository.dart';
import '../repositories/search_repository.dart';
import '../repositories/series_repository.dart';
import 'content_api.dart';
import 'content_source.dart';

part 'source_providers.g.dart';

/// All connected sources, reactive. Drives source-aware UI and invalidation:
/// deleting a source rebuilds [contentApiFor].
@riverpod
Stream<List<Source>> sourcesStream(Ref ref) =>
    ref.watch(appDatabaseProvider).watchSources();

/// The currently selected source id. With one source, `build` deterministically
/// picks the lowest source id (sorted); [select] switches the active source
/// (used by the sources screen). Remembering the last-active source across
/// restarts is a follow-up.
@Riverpod(keepAlive: true)
class ActiveSourceId extends _$ActiveSourceId {
  @override
  Future<String?> build() async {
    final sources = await ref.watch(appDatabaseProvider).allSources();
    if (sources.isEmpty) return null;
    final ids = sources.map((s) => s.id).toList()..sort();
    return ids.first;
  }

  void select(String sourceId) => state = AsyncData(sourceId);
}

/// Builds an authenticated [ContentApi] for [sourceId], dispatching on the
/// source `kind` to the matching backend (Komga or Kavita), or null when the
/// source row is missing, has no baseUrl, has no stored credential, or is a kind
/// without a remote client (graceful degradation). Watches [sourcesStream] so a
/// deleted source invalidates the cached client.
@riverpod
Future<ContentApi?> contentApiFor(Ref ref, String sourceId) async {
  // Rebuild when the set of sources changes (e.g. deletion).
  ref.watch(sourcesStreamProvider);
  final db = ref.watch(appDatabaseProvider);
  final source = await db.getSource(sourceId);
  if (source == null) return null;
  final baseUrl = source.baseUrl;
  if (baseUrl == null) return null;

  if (source.kind == SourceKind.komga.name) {
    final credential =
        await ref.watch(komgaCredentialStoreProvider).read(sourceId);
    if (credential == null) return null;
    return ref.watch(komgaApiFactoryProvider)(
      baseUrl: baseUrl,
      auth: credential.toAuth(),
    );
  }

  if (source.kind == SourceKind.kavita.name) {
    final credential =
        await ref.watch(kavitaCredentialStoreProvider).read(sourceId);
    if (credential == null) return null;
    return ref.watch(kavitaApiFactoryProvider)(
      baseUrl: baseUrl,
      apiKey: credential.apiKey,
    );
  }

  return null;
}

/// The full Sources row of the active source (id, kind, label), or null when
/// no source exists. Lets UI branch by source kind (a local source renders
/// local home/browse; server sources render the cache-backed surfaces).
@riverpod
Future<Source?> activeSource(Ref ref) async {
  final id = await ref.watch(activeSourceIdProvider.future);
  if (id == null) return null;
  final sources = await ref.watch(sourcesStreamProvider.future);
  for (final s in sources) {
    if (s.id == id) return s;
  }
  return null;
}

/// The [ContentApi] for the active source, or null when there is no active
/// source.
@riverpod
Future<ContentApi?> activeContentApi(Ref ref) async {
  final sourceId = await ref.watch(activeSourceIdProvider.future);
  if (sourceId == null) return null;
  return ref.watch(contentApiForProvider(sourceId).future);
}

// --- Repository providers (resolved against the active source) -------------

@riverpod
Future<SeriesRepository?> seriesRepository(Ref ref) async {
  final api = await ref.watch(activeContentApiProvider.future);
  if (api == null) return null;
  return SeriesRepository(ref.watch(appDatabaseProvider), api);
}

@riverpod
Future<BookRepository?> bookRepository(Ref ref) async {
  final api = await ref.watch(activeContentApiProvider.future);
  if (api == null) return null;
  return BookRepository(ref.watch(appDatabaseProvider), api);
}

@riverpod
Future<LibraryRepository?> libraryRepository(Ref ref) async {
  final api = await ref.watch(activeContentApiProvider.future);
  if (api == null) return null;
  return LibraryRepository(ref.watch(appDatabaseProvider), api);
}

@riverpod
Future<SearchRepository?> searchRepository(Ref ref) async {
  final api = await ref.watch(activeContentApiProvider.future);
  if (api == null) return null;
  return SearchRepository(api);
}

@riverpod
Future<CollectionRepository?> collectionRepository(Ref ref) async {
  final api = await ref.watch(activeContentApiProvider.future);
  if (api == null) return null;
  final sourceId = await ref.watch(activeSourceIdProvider.future);
  if (sourceId == null) return null;
  return CollectionRepository(api, ref.watch(appDatabaseProvider), sourceId);
}

@riverpod
Future<ReadListRepository?> readListRepository(Ref ref) async {
  final api = await ref.watch(activeContentApiProvider.future);
  if (api == null) return null;
  final sourceId = await ref.watch(activeSourceIdProvider.future);
  if (sourceId == null) return null;
  return ReadListRepository(api, ref.watch(appDatabaseProvider), sourceId);
}
