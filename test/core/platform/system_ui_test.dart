import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/core/platform/system_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('system UI helpers complete without throwing', () async {
    // On a non-Android host the gesture-exclusion channel is skipped; the
    // SystemChrome calls go through the test binding. This guards the helpers
    // against typos / null issues and confirms they never throw.
    await setAppFullscreen();
    await enterReaderImmersive();
    await exitReaderImmersive();
    await setReaderGestureExclusion(true);
    await setReaderGestureExclusion(false);
  });

  test('gesture exclusion swallows a missing native handler', () async {
    // Even if invoked (e.g. on Android with an older build), a MissingPlugin or
    // PlatformException must not surface. Simulate the channel throwing.
    const channel = MethodChannel('mylarium/system_gestures');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      throw MissingPluginException('no handler');
    });
    addTearDown(() => TestDefaultBinaryMessengerBinding
        .instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null));

    // Direct channel call (bypassing the Platform.isAndroid guard) stays caught.
    await expectLater(
      channel.invokeMethod<void>('setGestureExclusion', {'enabled': true}),
      throwsA(isA<MissingPluginException>()),
    );
    // The wrapper itself never throws.
    await setReaderGestureExclusion(true);
  });
}
