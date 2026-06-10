import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'l10n.dart';
import '../features/home/home_screen.dart';
import '../features/library/book_detail.dart';
import '../features/library/collections_screen.dart';
import '../features/library/libraries_screen.dart';
import '../features/library/search.dart';
import '../features/library/series_detail.dart';
import '../features/library/series_grid.dart';
import '../features/gallery/capture_viewer_screen.dart';
import '../features/gallery/gallery_screen.dart';
import '../features/integrations/comic_vine/comic_vine_settings_screen.dart';
import '../features/offline/storage_screen.dart';
import '../features/onboarding/kavita_connect_screen.dart';
import '../features/onboarding/komga_connect_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/reader/reader_screen.dart';
import '../features/settings/diagnostics_screen.dart';
import '../features/settings/library_lock.dart';
import '../features/settings/settings_screen.dart';
import '../features/sources/local/local_book_detail.dart';
import '../features/sources/local/local_browse.dart';
import '../features/stats/stats_screen.dart';

/// The route the app boots to. Overridden in main() to `/onboarding` when no
/// source exists yet, else `/`. Throws until overridden so a missing override
/// fails loudly rather than silently defaulting.
final initialLocationProvider = Provider<String>(
  (_) => throw UnimplementedError('override initialLocationProvider in main'),
);

final appRouterProvider = Provider<GoRouter>(
  (ref) => GoRouter(
    initialLocation: ref.watch(initialLocationProvider),
    routes: [
      GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (_, _) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/onboarding/komga',
        builder: (_, state) =>
            KomgaConnectScreen(initialUrl: state.uri.queryParameters['url']),
      ),
      GoRoute(
        path: '/onboarding/kavita',
        builder: (_, state) =>
            KavitaConnectScreen(initialUrl: state.uri.queryParameters['url']),
      ),
      GoRoute(
        path: '/browse/:sourceId',
        builder: (_, state) =>
            BrowseShell(sourceId: state.pathParameters['sourceId']!),
      ),
      GoRoute(
        path: '/libraries/:sourceId',
        builder: (_, state) =>
            LibrariesScreen(sourceId: state.pathParameters['sourceId']!),
      ),
      GoRoute(
        path: '/library/:sourceId/:libraryId',
        builder: (_, state) => LibraryGridScreen(
          sourceId: state.pathParameters['sourceId']!,
          libraryId: state.pathParameters['libraryId']!,
        ),
      ),
      GoRoute(
        path: '/series/:sourceId/:seriesId',
        builder: (_, state) => SeriesDetailScreen(
          sourceId: state.pathParameters['sourceId']!,
          seriesId: state.pathParameters['seriesId']!,
        ),
      ),
      GoRoute(
        path: '/book/:sourceId/:bookId',
        builder: (_, state) => BookDetailScreen(
          sourceId: state.pathParameters['sourceId']!,
          bookId: state.pathParameters['bookId']!,
        ),
      ),
      GoRoute(
        path: '/local-browse/:sourceId',
        builder: (_, state) =>
            LocalBrowseShell(sourceId: state.pathParameters['sourceId']!),
      ),
      GoRoute(
        path: '/local-series/:sourceId',
        builder: (_, state) => LocalSeriesDetailScreen(
          sourceId: state.pathParameters['sourceId']!,
          series: state.uri.queryParameters['series'] ?? '',
        ),
      ),
      GoRoute(
        path: '/local-book/:sourceId/:comicId',
        builder: (_, state) => LocalBookDetailScreen(
          sourceId: state.pathParameters['sourceId']!,
          comicId: state.pathParameters['comicId']!,
        ),
      ),
      GoRoute(path: '/search', builder: (_, _) => const SearchScreen()),
      GoRoute(path: '/stats', builder: (_, _) => const StatsScreen()),
      GoRoute(path: '/gallery', builder: (_, _) => const GalleryScreen()),
      GoRoute(
        path: '/capture/:id',
        builder: (_, state) =>
            CaptureViewerScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/collections/:sourceId',
        builder: (_, state) =>
            CollectionsScreen(sourceId: state.pathParameters['sourceId']!),
      ),
      GoRoute(
        path: '/collection/:sourceId/:collectionId',
        builder: (_, state) => CollectionDetailScreen(
          sourceId: state.pathParameters['sourceId']!,
          collectionId: state.pathParameters['collectionId']!,
        ),
      ),
      GoRoute(
        path: '/readlist/:sourceId/:readListId',
        builder: (_, state) => ReadListDetailScreen(
          sourceId: state.pathParameters['sourceId']!,
          readListId: state.pathParameters['readListId']!,
        ),
      ),
      GoRoute(
        path: '/settings',
        builder: (_, _) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/settings/library-lock',
        builder: (_, _) => const LibraryLockScreen(),
      ),
      GoRoute(
        path: '/settings/diagnostics',
        builder: (_, _) => const DiagnosticsScreen(),
      ),
      GoRoute(
        path: '/settings/storage',
        builder: (_, _) => const StorageScreen(),
      ),
      GoRoute(
        path: '/settings/comic-vine',
        builder: (_, _) => const ComicVineSettingsScreen(),
      ),
      GoRoute(
        path: '/reader/:sourceId/:bookId',
        builder: (_, state) => ReaderScreen(
          sourceId: state.pathParameters['sourceId']!,
          bookId: state.pathParameters['bookId']!,
          preview: state.uri.queryParameters['preview'] == 'true',
          initialPage: int.tryParse(state.uri.queryParameters['page'] ?? ''),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text(context.l10n.routeNotFound(state.uri.toString()))),
    ),
  ),
);
