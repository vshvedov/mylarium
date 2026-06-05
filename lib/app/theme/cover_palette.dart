import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/image/resolve_image.dart';
import '../../features/library/thumbnail_cache.dart';
import 'design_tokens.dart';

part 'cover_palette.g.dart';

/// Physical width the cover is downsampled to before quantizing. Small enough
/// that the pixel crunch is trivial; large enough to be representative.
const int kPaletteSampleWidth = 48;

/// Two cover-derived colors used to paint dynamic backgrounds: [dominant] (the
/// most common hue in the cover) and [muted] (the cover's darkened average).
@immutable
class CoverPalette {
  const CoverPalette({required this.dominant, required this.muted});

  final Color dominant;
  final Color muted;

  /// Used when there is no cover or extraction fails: a calm dark neutral.
  static const neutral = CoverPalette(
    dominant: Color(0xFF2A2730),
    muted: Color(0xFF15131A),
  );

  @override
  bool operator ==(Object other) =>
      other is CoverPalette &&
      other.dominant == dominant &&
      other.muted == muted;

  @override
  int get hashCode => Object.hash(dominant, muted);

  /// Resolves [cover] to a small [ui.Image] on the UI isolate, then quantizes
  /// its raw RGBA off the UI isolate via [Isolate.run]. Best-effort: any failure
  /// (decode error, empty bytes) resolves to [neutral] rather than throwing.
  static Future<CoverPalette> fromImage(ImageProvider cover) async {
    try {
      final image = await resolveImageProvider(
        ResizeImage(cover, width: kPaletteSampleWidth),
      );
      final w = image.width;
      final h = image.height;
      final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      image.dispose();
      if (data == null) return neutral;
      // Compact contiguous copy so the isolate receives clean, sendable bytes.
      final px = Uint8List.fromList(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
      final (dom, mut) = await Isolate.run(() => _quantize(px, w, h));
      return CoverPalette(dominant: Color(dom), muted: Color(mut));
    } catch (_) {
      return neutral;
    }
  }
}

/// Quantizes raw RGBA [px] (w x h, row-major) into a (dominant, muted) pair of
/// 0xFFRRGGBB ints. Runs in a background isolate. Pure and deterministic for a
/// given buffer, so it is unit-testable directly.
(int, int) _quantize(Uint8List px, int w, int h) {
  final counts = <int, int>{};
  var sr = 0, sg = 0, sb = 0, n = 0;
  for (var i = 0; i + 3 < px.length; i += 4) {
    if (px[i + 3] < 128) continue; // skip near-transparent pixels
    final r = px[i], g = px[i + 1], b = px[i + 2];
    sr += r;
    sg += g;
    sb += b;
    n++;
    final key = ((r >> 4) << 8) | ((g >> 4) << 4) | (b >> 4); // 4 bits/channel
    counts[key] = (counts[key] ?? 0) + 1;
  }
  if (n == 0) return (0xFF2A2730, 0xFF15131A); // all transparent: neutral
  var bestKey = counts.keys.first;
  var bestCount = -1;
  counts.forEach((k, c) {
    if (c > bestCount) {
      bestCount = c;
      bestKey = k;
    }
  });
  // Dominant: the center color of the most-populated bucket (+8 centers the cell).
  final dr = (((bestKey >> 8) & 0xF) << 4) | 0x8;
  final dg = (((bestKey >> 4) & 0xF) << 4) | 0x8;
  final db = ((bestKey & 0xF) << 4) | 0x8;
  final dominant = 0xFF000000 | (dr << 16) | (dg << 8) | db;
  // Muted: the overall average darkened toward the background.
  final mr = ((sr / n) * 0.6).round().clamp(0, 255);
  final mg = ((sg / n) * 0.6).round().clamp(0, 255);
  final mb = ((sb / n) * 0.6).round().clamp(0, 255);
  final muted = 0xFF000000 | (mr << 16) | (mg << 8) | mb;
  return (dominant, muted);
}

/// The cover palette for an owner, cached for the app lifetime (keepAlive) and
/// keyed per owner id. Null when the owner has no cover.
@Riverpod(keepAlive: true)
Future<CoverPalette?> coverPalette(
  Ref ref,
  String sourceId,
  String ownerType,
  String ownerId,
) async {
  // ref.read (not watch): a one-shot pull so this keepAlive provider does not
  // pin the autoDispose coverImageProvider alive (which would defeat the
  // phase-1 image-cache eviction). The palette itself is two cheap colors.
  final provider = await ref.read(
    coverImageProvider(sourceId, ownerType, ownerId).future,
  );
  if (provider == null) return null;
  return CoverPalette.fromImage(provider); // never throws (neutral on failure)
}

/// A full-bleed cover-derived background: a palette gradient (dominant to muted)
/// under a legibility scrim, with a graceful theme-gradient fallback when no
/// cover/palette exists. Imposes no intrinsic size: it fills its parent (callers
/// wrap it in Positioned.fill behind their header content).
class CoverBackground extends ConsumerWidget {
  const CoverBackground({
    super.key,
    required this.sourceId,
    required this.ownerType,
    required this.ownerId,
    this.child,
    this.showBlurredCover = false,
    this.showScrim = true,
  });

  final String sourceId;
  final String ownerType;
  final String ownerId;
  final Widget? child;

  /// Optional blurred cover layer under the scrim. Off by default (cheaper and
  /// deterministic for goldens); on-device tuning may enable it.
  final bool showBlurredCover;

  /// The top-to-bottom legibility scrim (darkens toward the bottom). On by
  /// default for callers that place text over the art. Turn off where the art
  /// must instead fade cleanly into the page (e.g. the detail hero leak), since
  /// the scrim otherwise leaves a dark band below the page background.
  final bool showScrim;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<DesignTokens>()!;
    final palette = ref
        .watch(coverPaletteProvider(sourceId, ownerType, ownerId))
        .valueOrNull;
    // Fallback-first: render immediately, swap in the palette when it resolves.
    final Decoration base = palette == null
        ? BoxDecoration(gradient: tokens.gradients.coverFallback)
        : BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [palette.dominant, palette.muted],
            ),
          );
    final cover = showBlurredCover
        ? ref
              .watch(coverImageProvider(sourceId, ownerType, ownerId))
              .valueOrNull
        : null;
    final blurred = cover == null
        ? null
        : Positioned.fill(
            child: Opacity(
              opacity: 0.25,
              child: ImageFiltered(
                imageFilter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Image(image: cover, fit: BoxFit.cover),
              ),
            ),
          );
    return Stack(
      fit: StackFit.passthrough,
      children: [
        Positioned.fill(child: DecoratedBox(decoration: base)),
        ?blurred,
        if (showScrim)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: tokens.gradients.scrim),
            ),
          ),
        ?child,
      ],
    );
  }
}
