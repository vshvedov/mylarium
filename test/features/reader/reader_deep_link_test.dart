import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/router.dart';
import 'package:mylarium/app/theme/app_theme.dart';
import 'package:mylarium/features/reader/reader_controller.dart';
import 'package:mylarium/features/reader/reader_screen.dart';

/// Keeps the reader in its loading state (no network, no source lookups) so the
/// test can inspect the ReaderScreen the router built without driving the body.
class _StubReader extends ReaderController {
  @override
  Future<ReaderData> build(String sourceId, String bookId,
          [bool preview = false]) =>
      Completer<ReaderData>().future;
}

void main() {
  testWidgets('reader route parses ?page= and &preview into the screen',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          initialLocationProvider
              .overrideWithValue('/reader/s/b?page=5&preview=true'),
          readerControllerProvider('s', 'b', true)
              .overrideWith(_StubReader.new),
        ],
        child: Consumer(
          builder: (context, ref, _) => MaterialApp.router(
            theme: darkTheme,
            routerConfig: ref.watch(appRouterProvider),
          ),
        ),
      ),
    );
    await tester.pump();

    final screen = tester.widget<ReaderScreen>(find.byType(ReaderScreen));
    expect(screen.sourceId, 's');
    expect(screen.bookId, 'b');
    expect(screen.preview, isTrue);
    expect(screen.initialPage, 5);
  });

  testWidgets('reader route without ?page= leaves initialPage null',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          initialLocationProvider.overrideWithValue('/reader/s/b'),
          readerControllerProvider('s', 'b', false)
              .overrideWith(_StubReader.new),
        ],
        child: Consumer(
          builder: (context, ref, _) => MaterialApp.router(
            theme: darkTheme,
            routerConfig: ref.watch(appRouterProvider),
          ),
        ),
      ),
    );
    await tester.pump();

    final screen = tester.widget<ReaderScreen>(find.byType(ReaderScreen));
    expect(screen.initialPage, isNull);
    expect(screen.preview, isFalse);
  });
}
