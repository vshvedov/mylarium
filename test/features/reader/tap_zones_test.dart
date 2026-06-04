import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/features/reader/gestures/tap_zones.dart';
import 'package:mylarium/features/reader/reader_models.dart';

void main() {
  TapAction at(double x, double y, TapZonePreset preset,
          {bool invert = false, bool rtl = false}) =>
      resolveTapZone(
        normalized: Offset(x, y),
        preset: preset,
        invert: invert,
        rtl: rtl,
      );

  test('center box always toggles chrome', () {
    for (final p in TapZonePreset.values) {
      expect(at(0.5, 0.5, p), TapAction.toggleChrome, reason: '$p');
    }
  });

  test('lrEdges: left=prev, right=next, middle=toggle', () {
    expect(at(0.1, 0.5, TapZonePreset.lrEdges), TapAction.prev);
    expect(at(0.9, 0.5, TapZonePreset.lrEdges), TapAction.next);
    expect(at(0.5, 0.1, TapZonePreset.lrEdges), TapAction.toggleChrome);
  });

  test('lmr: thirds map prev/toggle/next', () {
    expect(at(0.1, 0.5, TapZonePreset.lmr), TapAction.prev);
    expect(at(0.5, 0.1, TapZonePreset.lmr), TapAction.toggleChrome);
    expect(at(0.9, 0.5, TapZonePreset.lmr), TapAction.next);
  });

  test('kindleStyle: small left edge prev, rest next', () {
    expect(at(0.1, 0.5, TapZonePreset.kindleStyle), TapAction.prev);
    expect(at(0.9, 0.2, TapZonePreset.kindleStyle), TapAction.next);
  });

  test('edgeTopBottom: top=prev, bottom=next', () {
    expect(at(0.1, 0.1, TapZonePreset.edgeTopBottom), TapAction.prev);
    expect(at(0.1, 0.9, TapZonePreset.edgeTopBottom), TapAction.next);
  });

  test('halves: left=prev, right=next', () {
    expect(at(0.1, 0.8, TapZonePreset.halves), TapAction.prev);
    expect(at(0.9, 0.2, TapZonePreset.halves), TapAction.next);
  });

  test('invert swaps prev and next', () {
    expect(at(0.1, 0.5, TapZonePreset.lrEdges, invert: true), TapAction.next);
    expect(at(0.9, 0.5, TapZonePreset.lrEdges, invert: true), TapAction.prev);
  });

  test('RTL flips horizontal presets but not edgeTopBottom', () {
    expect(at(0.1, 0.5, TapZonePreset.lrEdges, rtl: true), TapAction.next);
    expect(at(0.9, 0.5, TapZonePreset.lrEdges, rtl: true), TapAction.prev);
    // Vertical preset is unaffected by RTL.
    expect(at(0.1, 0.1, TapZonePreset.edgeTopBottom, rtl: true), TapAction.prev);
    expect(at(0.1, 0.9, TapZonePreset.edgeTopBottom, rtl: true), TapAction.next);
  });
}
