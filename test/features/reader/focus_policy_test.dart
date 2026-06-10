import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/core/platform/render_capabilities.dart';
import 'package:mylarium/features/reader/focus_policy.dart';
import 'package:mylarium/features/reader/reader_models.dart';

void main() {
  group('settle-delay promotion', () {
    testWidgets('promotes only after the page has been quiet', (tester) async {
      var page = 0;
      var promotions = 0;
      final policy = FocusUpgradePolicy(
        currentPage: () => page,
        onPromoted: () => promotions++,
      );
      policy.settleImmediately();
      expect(policy.settledPage, 0);

      page = 1;
      policy.onPageTurned();
      // Mid-flight: the settled page still lags (no mid-slide re-decode).
      expect(policy.settledPage, 0);
      await tester.pump(kFocusUpgradeDelay ~/ 2);
      expect(policy.settledPage, 0);

      // Another turn before the settle resets the timer: a fast flip-through
      // never promotes until it stops.
      page = 2;
      policy.onPageTurned();
      await tester.pump(kFocusUpgradeDelay * 3 ~/ 4);
      expect(policy.settledPage, 0);
      expect(promotions, 0);

      await tester.pump(kFocusUpgradeDelay);
      expect(policy.settledPage, 2);
      expect(promotions, 1);
      policy.dispose();
    });

    testWidgets('a zoom gesture promotes immediately', (tester) async {
      var page = 0;
      var promotions = 0;
      final zoomed = ValueNotifier<bool>(false);
      final policy = FocusUpgradePolicy(
        currentPage: () => page,
        onPromoted: () => promotions++,
      );
      policy.attachZoom(zoomed);

      page = 1;
      policy.onPageTurned();
      zoomed.value = true;
      // No settle wait: the pinch needs the full-resolution decode now.
      expect(policy.settledPage, 1);
      expect(promotions, 1);

      // The pending settle timer was cancelled; no double promotion later.
      await tester.pump(kFocusUpgradeDelay * 2);
      expect(promotions, 1);

      // Un-zooming promotes nothing.
      zoomed.value = false;
      expect(promotions, 1);

      policy.dispose();
      // Detached: a zoom after dispose no longer reaches the policy.
      page = 5;
      zoomed.value = true;
      expect(policy.settledPage, 1);
      zoomed.dispose();
    });

    testWidgets('promoteNow is a no-op when already settled', (tester) async {
      var promotions = 0;
      final policy = FocusUpgradePolicy(
        currentPage: () => 0,
        onPromoted: () => promotions++,
      );
      policy.settleImmediately();
      policy.promoteNow();
      expect(promotions, 0);
      policy.dispose();
    });
  });

  group('focus indices', () {
    FocusUpgradePolicy settledAt(int page) {
      final policy = FocusUpgradePolicy(
        currentPage: () => page,
        onPromoted: () {},
      );
      policy.settleImmediately();
      return policy;
    }

    const pairs = [
      [0],
      [1, 2],
      [3, 4],
    ];

    test('double-page focuses both pages of the settled spread', () {
      final policy = settledAt(2);
      expect(policy.indicesFor(ReadingMode.doublePage, pairs), {1, 2});
      policy.dispose();
    });

    test('paged and webtoon modes focus the settled page alone', () {
      final policy = settledAt(2);
      expect(policy.indicesFor(ReadingMode.pagedLtr, pairs), {2});
      expect(policy.indicesFor(ReadingMode.webtoon, pairs), {2});
      policy.dispose();
    });
  });

  group('decode widths', () {
    test('neighbor gets display headroom, focus gets zoom headroom', () {
      final policy = FocusUpgradePolicy(currentPage: () => 0, onPromoted: () {});
      policy.recomputeWidths(
        viewportWidth: 400,
        devicePixelRatio: 2,
        hardwareCap: 4096,
        focusCeiling: 4096,
      );
      // 400 * 2 * 1.5 and 400 * 2 * kReaderZoomHeadroom (4x), under the caps.
      expect(policy.neighborWidth, 1200);
      expect(policy.focusWidth, 3200);
      policy.dispose();
    });

    test('focus clamps to the lower of the quality ceiling and hardware cap',
        () {
      final policy = FocusUpgradePolicy(currentPage: () => 0, onPromoted: () {});
      policy.recomputeWidths(
        viewportWidth: 800,
        devicePixelRatio: 3,
        hardwareCap: 4096,
        focusCeiling: 2048,
      );
      // 800 * 3 * 4 = 9600, clamped to the manual quality ceiling.
      expect(policy.focusWidth, 2048);
      // The neighbor width is bounded by the cross-platform texture floor.
      expect(policy.neighborWidth, (800 * 3 * 1.5).round());

      policy.recomputeWidths(
        viewportWidth: 4000,
        devicePixelRatio: 2,
        hardwareCap: 4096,
        focusCeiling: 1 << 20,
      );
      // A "native" ceiling resolves to the hardware cap; the neighbor width
      // never exceeds the safe fallback texture dimension.
      expect(policy.focusWidth, 4096);
      expect(policy.neighborWidth, kFallbackMaxTextureDim);
      policy.dispose();
    });
  });
}
