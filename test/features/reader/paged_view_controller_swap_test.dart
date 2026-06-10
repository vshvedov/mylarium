import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/features/reader/paged_view.dart';
import 'package:mylarium/features/reader/reader_models.dart';

/// Regression probe for the RTL direction-toggle tap dead-zone: flipping
/// direction recreates the PageController; if the gallery does not attach the
/// NEW controller, every tap-zone _step() silently no-ops on
/// `controller.hasClients == false` while swipes (driven by the old, disposed
/// controller still attached to the PageView) keep working.
void main() {
  Widget host({
    required PageController controller,
    required bool rtl,
    required ValueNotifier<bool> zoomed,
    required void Function(Offset) onTap,
  }) =>
      MaterialApp(
        home: Scaffold(
          body: PagedView(
            pageController: controller,
            pageCount: 5,
            imageBuilder: (i) => MemoryImage(kTransparentImage),
            aspectRatioOf: (_) => 0.7,
            fit: FitMode.screen,
            viewportAspect: 0.7,
            rtl: rtl,
            doubleTapZoom: false,
            filterQuality: FilterQuality.high,
            zoomed: zoomed,
            onPageChanged: (_) {},
            onTap: onTap,
          ),
        ),
      );

  testWidgets('a swapped-in PageController attaches to the gallery',
      (tester) async {
    final zoomed = ValueNotifier(false);
    addTearDown(zoomed.dispose);
    final a = PageController();
    final taps = <Offset>[];

    await tester.pumpWidget(host(
      controller: a,
      rtl: false,
      zoomed: zoomed,
      onTap: taps.add,
    ));
    await tester.pump();
    expect(a.hasClients, isTrue);

    // Direction flip: the screen disposes the old controller and swaps in a
    // new instance at the same page (what _resetControllerForMode does).
    final b = PageController(initialPage: 0);
    a.dispose();
    await tester.pumpWidget(host(
      controller: b,
      rtl: true,
      zoomed: zoomed,
      onTap: taps.add,
    ));
    await tester.pump();

    // The new controller must drive the view, or every tap-zone page turn
    // dies on `hasClients == false`.
    expect(b.hasClients, isTrue,
        reason: 'gallery did not attach the swapped-in controller');

    b.dispose();
  });
}

/// 1x1 transparent PNG.
final kTransparentImage = Uri.parse(
        'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==')
    .data!
    .contentAsBytes();
