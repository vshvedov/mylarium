import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/theme/theme_controller.dart'
    show appDatabaseProvider, initialSettingsProvider;

part 'image_quality.g.dart';

/// A "no practical cap" sentinel for the sharpest manual stop: far above any
/// viewport or texture cap, so the reader's `min(...)` resolves to the hardware
/// cap (effectively native).
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

/// The global reader image-quality preference. [smart] true means Mylarium
/// picks the decode ceiling; when false, [manualLevel] indexes
/// [kManualDecodeCeilings].
class ImageQuality {
  const ImageQuality({required this.smart, required this.manualLevel});

  final bool smart;
  final int manualLevel;

  /// The focused-page decode ceiling. In Smart mode this is [deviceCap] (the
  /// reader passes the probed GPU max-texture cap, so capable devices decode
  /// sharper while weak GPUs stay within their limit); in manual mode it is the
  /// chosen stop, independent of the device. Pure; unit-tested.
  int focusCeiling(int deviceCap) {
    if (smart) return deviceCap;
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
