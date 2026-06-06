import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/features/home/home_layout.dart';

void main() {
  test('default layout is every row in enum order, all visible', () {
    final d = defaultHomeLayout;
    expect(d.map((i) => i.kind), HomeRailKind.values);
    expect(d.every((i) => i.visible), isTrue);
  });

  test('null / empty / malformed config falls back to default', () {
    expect(decodeHomeLayout(null), defaultHomeLayout);
    expect(decodeHomeLayout(''), defaultHomeLayout);
    expect(decodeHomeLayout('not json'), defaultHomeLayout);
    expect(decodeHomeLayout('{"kind":"pinned"}'), defaultHomeLayout); // not a list
  });

  test('round-trips order and visibility', () {
    final custom = [
      const HomeRailItem(HomeRailKind.downloaded),
      const HomeRailItem(HomeRailKind.pinned, visible: false),
      const HomeRailItem(HomeRailKind.keepReading),
      const HomeRailItem(HomeRailKind.recentlyAddedChapters),
      const HomeRailItem(HomeRailKind.recentlyAddedSeries),
      const HomeRailItem(HomeRailKind.recentlyUpdatedSeries),
      const HomeRailItem(HomeRailKind.recentlyRead, visible: false),
    ];
    final decoded = decodeHomeLayout(encodeHomeLayout(custom));
    expect(decoded, custom);
  });

  test('unknown row names are dropped', () {
    final json = '[{"kind":"ghost","visible":true},'
        '{"kind":"pinned","visible":false}]';
    final decoded = decodeHomeLayout(json);
    // ghost dropped; pinned kept (hidden); the rest appended visible in order.
    expect(decoded.first.kind, HomeRailKind.pinned);
    expect(decoded.first.visible, isFalse);
    expect(decoded.map((i) => i.kind).toSet(), HomeRailKind.values.toSet());
    expect(decoded.length, HomeRailKind.values.length);
  });

  test('rows missing from a stored config are appended at the end, visible', () {
    // Simulate an older config saved before "recentlyRead" existed.
    final json = encodeHomeLayout([
      for (final k in HomeRailKind.values)
        if (k != HomeRailKind.recentlyRead) HomeRailItem(k),
    ]);
    final decoded = decodeHomeLayout(json);
    expect(decoded.last.kind, HomeRailKind.recentlyRead);
    expect(decoded.last.visible, isTrue);
    expect(decoded.length, HomeRailKind.values.length);
  });

  test('a duplicated row name is only taken once', () {
    final json = '[{"kind":"pinned"},{"kind":"pinned","visible":false}]';
    final decoded = decodeHomeLayout(json);
    expect(decoded.where((i) => i.kind == HomeRailKind.pinned).length, 1);
    expect(decoded.first.visible, isTrue, reason: 'first occurrence wins');
  });
}
