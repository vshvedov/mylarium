import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/theme/theme_controller.dart'
    show appDatabaseProvider, initialSettingsProvider;

part 'image_quality.g.dart';

/// Ceiling (physical px) the reader decodes to in Smart mode. The reader takes
/// `min(viewport, ceiling)` and never upscales, so this only bites on large
/// hi-DPI screens (phones decode native); it is the tuned default. Left as a
/// fixed value for now, with room to make Smart device/memory-aware later
/// without any UI change.
const int kSmartDecodeCeiling = 2048;

/// A "no practical cap" sentinel for the sharpest manual stop: far above any
/// viewport, so `min(viewport, ceiling)` resolves to the viewport (native).
const int kNativeDecodeCeiling = 1 << 20;

/// Manual quality stops, smoothest (smallest decode) to sharpest (native).
/// Indexed by [ImageQuality.manualLevel].
const List<int> kManualDecodeCeilings = [
  1280,
  1600,
  2048,
  2560,
  kNativeDecodeCeiling,
];

/// Default manual stop (the middle, ~matches Smart) used before the user moves
/// the slider.
const int kDefaultManualLevel = 2;

/// The global reader image-quality preference. [smart] true means Mylarium
/// picks the decode ceiling; when false, [manualLevel] indexes
/// [kManualDecodeCeilings].
class ImageQuality {
  const ImageQuality({required this.smart, required this.manualLevel});

  final bool smart;
  final int manualLevel;

  /// The decode-width ceiling implied by this preference. Pure; unit-tested.
  int get ceiling {
    if (smart) return kSmartDecodeCeiling;
    final i = manualLevel.clamp(0, kManualDecodeCeilings.length - 1);
    return kManualDecodeCeilings[i];
  }

  ImageQuality copyWith({bool? smart, int? manualLevel}) => ImageQuality(
        smart: smart ?? this.smart,
        manualLevel: manualLevel ?? this.manualLevel,
      );

  @override
  bool operator ==(Object other) =>
      other is ImageQuality &&
      other.smart == smart &&
      other.manualLevel == manualLevel;

  @override
  int get hashCode => Object.hash(smart, manualLevel);
}

/// Holds the global image-quality preference, seeded from the boot settings and
/// written back to `app_settings`. The reader watches this to size its decodes.
@riverpod
class ImageQualityController extends _$ImageQualityController {
  @override
  ImageQuality build() {
    final s = ref.read(initialSettingsProvider);
    return ImageQuality(
      smart: s.imageQualitySmart,
      manualLevel: s.imageQualityManualLevel,
    );
  }

  Future<void> setSmart(bool v) async {
    await ref.read(appDatabaseProvider).updateImageQualitySmart(v);
    state = state.copyWith(smart: v);
  }

  Future<void> setManualLevel(int level) async {
    final clamped = level.clamp(0, kManualDecodeCeilings.length - 1);
    await ref.read(appDatabaseProvider).updateImageQualityManualLevel(clamped);
    state = state.copyWith(manualLevel: clamped);
  }
}
