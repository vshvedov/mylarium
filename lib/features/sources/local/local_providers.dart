import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/theme/theme_controller.dart' show appDatabaseProvider;
import '../../../core/db/database.dart';
import '../../../data/local/import_service.dart';
import '../../../data/local/local_comics_repository.dart';

part 'local_providers.g.dart';

/// The import pipeline for the Local files source (copy-on-import).
@riverpod
ImportService importService(Ref ref) =>
    ImportService(ref.watch(appDatabaseProvider));

/// Read-side access to local comics (series grouping, books, single book).
@riverpod
LocalComicsRepository localComicsRepository(Ref ref) =>
    LocalComicsRepository(ref.watch(appDatabaseProvider));

/// The local series grid for one source.
@riverpod
Stream<List<LocalSeriesRaw>> localSeries(Ref ref, String sourceId) =>
    ref.watch(localComicsRepositoryProvider).watchSeries(sourceId);

/// Books of one local series (numberSort order, specials last).
@riverpod
Stream<List<LocalComic>> localBooks(
  Ref ref,
  String sourceId,
  String series,
) =>
    ref.watch(localComicsRepositoryProvider).watchBooks(sourceId, series);

/// One local comic by id (null when deleted).
@riverpod
Future<LocalComic?> localComic(Ref ref, String comicId) =>
    ref.watch(localComicsRepositoryProvider).book(comicId);

/// Keep-reading rail: in-progress local books, newest first.
@riverpod
Stream<List<LocalComic>> localKeepReading(Ref ref, String sourceId) =>
    ref.watch(appDatabaseProvider).watchLocalKeepReading(sourceId);

/// Recently-imported rail: newest imports first.
@riverpod
Stream<List<LocalComic>> localRecentlyImported(Ref ref, String sourceId) =>
    ref.watch(appDatabaseProvider).watchRecentlyImported(sourceId);
