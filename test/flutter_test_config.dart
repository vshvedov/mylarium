import 'dart:async';

import 'package:flutter/rendering.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // Deterministic goldens: no shadow rasterization.
  debugDisableShadows = true;
  await testMain();
}
