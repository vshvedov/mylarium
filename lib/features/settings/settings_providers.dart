import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/theme/theme_controller.dart' show appDatabaseProvider;

part 'settings_providers.g.dart';

/// Whether reaching the last page auto-loads the next book in the series (T2).
/// Global, reactive: the reader reads it to decide whether to count down at the
/// end-of-book seam, and the settings screen toggles it.
@riverpod
Stream<bool> autoAdvanceEnabled(Ref ref) =>
    ref.watch(appDatabaseProvider).watchSettings().map((s) => s.autoAdvance);
