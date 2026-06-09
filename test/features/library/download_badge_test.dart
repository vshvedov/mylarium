import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/theme/app_icons.dart';
import 'package:mylarium/app/theme/app_theme.dart';
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/features/library/widgets/library_tiles.dart';
import 'package:mylarium/features/offline/download_manager.dart';
import 'package:mylarium/features/offline/offline_providers.dart';

void main() {
  Widget host(List<Override> overrides) => ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          theme: darkTheme,
          home: const Scaffold(body: DownloadBadge(sourceId: 's', bookId: 'b')),
        ),
      );

  testWidgets('shows a progress ring while a download is running', (
    tester,
  ) async {
    await tester.pumpWidget(host([
      downloadProgressProvider('s', 'b').overrideWith(
        (ref) => Stream.value(const DownloadProgress(
            state: 'running', bytesDownloaded: 50, totalBytes: 100)),
      ),
      cachedAssetProvider('s', 'b').overrideWith((ref) => Stream.value(null)),
    ]));
    // Let the stream emit and the fill tween settle (determinate, not infinite).
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows the down-arrow badge (no ring) when downloaded', (
    tester,
  ) async {
    await tester.pumpWidget(host([
      downloadProgressProvider('s', 'b').overrideWith(
        (ref) => Stream.value(const DownloadProgress(
            state: 'complete', bytesDownloaded: 100, totalBytes: 100)),
      ),
      cachedAssetProvider('s', 'b').overrideWith(
        (ref) => Stream.value(const CachedAsset(
          sourceId: 's',
          bookId: 'b',
          kind: 'archive',
          relativePath: 'p',
          sizeBytes: 0,
          sha: null,
          lastAccessedAt: 0,
          pinned: false,
          permanent: false,
        )),
      ),
    ]));
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byIcon(AppIcons.downloaded), findsOneWidget);
  });

  testWidgets('shows nothing when neither downloading nor downloaded', (
    tester,
  ) async {
    await tester.pumpWidget(host([
      downloadProgressProvider('s', 'b').overrideWith(
        (ref) => Stream.value(
            const DownloadProgress(state: 'none', bytesDownloaded: 0)),
      ),
      cachedAssetProvider('s', 'b').overrideWith((ref) => Stream.value(null)),
    ]));
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byIcon(AppIcons.downloaded), findsNothing);
  });
}
