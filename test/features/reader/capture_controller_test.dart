import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/features/reader/capture_controller.dart';

void main() {
  group('capture mode transitions', () {
    test('start raises capture mode, cancel lowers it', () {
      final c = CaptureController();
      expect(c.capturing, isFalse);
      c.start();
      expect(c.capturing, isTrue);
      expect(c.saving, isFalse);
      c.cancel();
      expect(c.capturing, isFalse);
    });
  });

  group('save pipeline', () {
    test('success crops, then persists, then ends capture mode', () async {
      final c = CaptureController();
      c.start();
      final calls = <String>[];
      final outcome = await c.save<String>(
        crop: () async {
          calls.add('crop');
          return 'shot';
        },
        persist: (shot) async => calls.add('persist:$shot'),
      );
      expect(outcome, CaptureSaveOutcome.saved);
      expect(calls, ['crop', 'persist:shot']);
      expect(c.capturing, isFalse);
      expect(c.saving, isFalse);
    });

    test('a crop failure reports captureFailed and never persists', () async {
      final c = CaptureController();
      c.start();
      var persisted = false;
      final outcome = await c.save<String>(
        crop: () async => throw StateError('boundary gone'),
        persist: (_) async => persisted = true,
      );
      expect(outcome, CaptureSaveOutcome.captureFailed);
      expect(persisted, isFalse);
      expect(c.capturing, isFalse);
      expect(c.saving, isFalse);
    });

    test('a persist failure reports saveFailed', () async {
      final c = CaptureController();
      c.start();
      final outcome = await c.save<String>(
        crop: () async => 'shot',
        persist: (_) async => throw StateError('disk full'),
      );
      expect(outcome, CaptureSaveOutcome.saveFailed);
      expect(c.capturing, isFalse);
      expect(c.saving, isFalse);
    });

    test('a second Save while one is in flight is ignored', () async {
      final c = CaptureController();
      c.start();
      final gate = Completer<String>();
      var persists = 0;
      var secondCropRan = false;

      final first = c.save<String>(
        crop: () => gate.future,
        persist: (_) async => persists++,
      );
      expect(c.saving, isTrue);

      final second = await c.save<String>(
        crop: () async {
          secondCropRan = true;
          return 'dup';
        },
        persist: (_) async => persists++,
      );
      // The double-Save guard: no outcome, no work started.
      expect(second, isNull);
      expect(secondCropRan, isFalse);

      gate.complete('shot');
      expect(await first, CaptureSaveOutcome.saved);
      expect(persists, 1);
      expect(c.saving, isFalse);
      expect(c.capturing, isFalse);
    });
  });
}
