import 'dart:convert';

import 'package:flutter/widgets.dart';

import '../../app/l10n.dart';
import '../../app/theme/app_icons.dart';

/// The home-screen rows, in their default top-to-bottom order. The order of this
/// enum's values IS the default layout (see [defaultHomeLayout]); new rows append
/// at the bottom by default.
enum HomeRailKind {
  pinned,
  keepReading,
  recentlyAddedChapters,
  recentlyAddedSeries,
  recentlyUpdatedSeries,
  downloaded,
  recentlyRead,
}

extension HomeRailKindMeta on HomeRailKind {
  /// The localized row header title.
  String title(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      HomeRailKind.pinned => l10n.railPinned,
      HomeRailKind.keepReading => l10n.railKeepReading,
      HomeRailKind.recentlyAddedChapters => l10n.railRecentlyAddedChapters,
      HomeRailKind.recentlyAddedSeries => l10n.railRecentlyAddedSeries,
      HomeRailKind.recentlyUpdatedSeries => l10n.railRecentlyUpdatedSeries,
      HomeRailKind.downloaded => l10n.railDownloaded,
      HomeRailKind.recentlyRead => l10n.railRecentlyRead,
    };
  }

  /// The row header icon.
  IconData get icon => switch (this) {
        HomeRailKind.pinned => AppIcons.pin,
        HomeRailKind.keepReading => AppIcons.read,
        HomeRailKind.recentlyAddedChapters => AppIcons.recentlyAdded,
        HomeRailKind.recentlyAddedSeries => AppIcons.series,
        HomeRailKind.recentlyUpdatedSeries => AppIcons.refresh,
        HomeRailKind.downloaded => AppIcons.savedOffline,
        HomeRailKind.recentlyRead => AppIcons.recentlyRead,
      };
}

/// One row in the home layout: which row, and whether it is shown.
@immutable
class HomeRailItem {
  const HomeRailItem(this.kind, {this.visible = true});

  final HomeRailKind kind;
  final bool visible;

  HomeRailItem copyWith({bool? visible}) =>
      HomeRailItem(kind, visible: visible ?? this.visible);

  @override
  bool operator ==(Object other) =>
      other is HomeRailItem && other.kind == kind && other.visible == visible;

  @override
  int get hashCode => Object.hash(kind, visible);
}

/// The default layout: every row in enum order, all visible.
List<HomeRailItem> get defaultHomeLayout =>
    [for (final k in HomeRailKind.values) HomeRailItem(k)];

/// Parses a stored layout, reconciling it against the current set of rows so the
/// result is always complete and valid:
/// - unknown row names (a row removed in a later build) are dropped;
/// - rows missing from the stored config (a row added in a later build) are
///   appended at the bottom, visible, in enum order;
/// - a null / empty / malformed config falls back to [defaultHomeLayout].
List<HomeRailItem> decodeHomeLayout(String? json) {
  if (json == null || json.isEmpty) return defaultHomeLayout;
  final List<dynamic> raw;
  try {
    final decoded = jsonDecode(json);
    if (decoded is! List) return defaultHomeLayout;
    raw = decoded;
  } catch (_) {
    return defaultHomeLayout;
  }
  final byName = {for (final k in HomeRailKind.values) k.name: k};
  final seen = <HomeRailKind>{};
  final result = <HomeRailItem>[];
  for (final entry in raw) {
    if (entry is! Map) continue;
    final kind = byName[entry['kind']];
    if (kind == null || seen.contains(kind)) continue;
    seen.add(kind);
    result.add(HomeRailItem(kind, visible: entry['visible'] != false));
  }
  // Append any rows not present in the stored config (e.g. newly added rows).
  for (final k in HomeRailKind.values) {
    if (!seen.contains(k)) result.add(HomeRailItem(k));
  }
  return result;
}

/// Serializes a layout for persistence.
String encodeHomeLayout(List<HomeRailItem> items) => jsonEncode([
      for (final i in items) {'kind': i.kind.name, 'visible': i.visible},
    ]);
