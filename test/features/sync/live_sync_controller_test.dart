import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/core/network/content_exception.dart';
import 'package:mylarium/data/source/models/live_event.dart';
import 'package:mylarium/features/sync/live_sync_controller.dart';

/// Lets a microtask-driven loop run to quiescence.
Future<void> settle([int turns = 8]) async {
  for (var i = 0; i < turns; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  test('routes read-progress to onReadProgress and other events to onInvalidate',
      () async {
    final progress = <String>[];
    final invalidated = <LiveEvent>[];
    final stream = StreamController<LiveEvent>();
    final c = LiveSyncController(
      connect: () => stream.stream,
      onReadProgress: (id) async => progress.add(id),
      onInvalidate: invalidated.add,
      onSessionExpired: () {},
      delay: (_) async {},
      random: () => 0,
    );

    c.start();
    stream
      ..add(const ReadProgressChanged('b1'))
      ..add(const ReadProgressDeleted('b2'))
      ..add(const SeriesChanged('s1'))
      ..add(const ThumbnailChanged(bookId: 'b3'));
    await settle();

    expect(progress, ['b1', 'b2']);
    expect(invalidated, const [
      SeriesChanged('s1'),
      ThumbnailChanged(bookId: 'b3'),
    ]);
    await c.stop();
    await stream.close();
  });

  test('a session-expired event stops the loop and does not reconnect',
      () async {
    var connects = 0;
    var expired = 0;
    final c = LiveSyncController(
      connect: () {
        connects++;
        return Stream.value(const SessionExpired());
      },
      onReadProgress: (_) async {},
      onInvalidate: (_) {},
      onSessionExpired: () => expired++,
      delay: (_) async {},
      random: () => 0,
    );

    c.start();
    await settle();

    expect(c.isSessionExpired, isTrue);
    expect(expired, 1);
    expect(connects, 1, reason: 'no reconnect after session expiry');
  });

  test('a 401 on connect expires the session, no reconnect', () async {
    var connects = 0;
    var expired = 0;
    final c = LiveSyncController(
      connect: () {
        connects++;
        return Stream<LiveEvent>.error(
          const ContentException(ContentErrorKind.unauthorized, 'nope'),
        );
      },
      onReadProgress: (_) async {},
      onInvalidate: (_) {},
      onSessionExpired: () => expired++,
      delay: (_) async {},
      random: () => 0,
    );

    c.start();
    await settle();

    expect(c.isSessionExpired, isTrue);
    expect(expired, 1);
    expect(connects, 1);
  });

  test('a dropped stream reconnects with growing capped backoff', () async {
    final delays = <Duration>[];
    var connects = 0;
    final parked = StreamController<LiveEvent>();
    final c = LiveSyncController(
      connect: () {
        connects++;
        // First two connections close immediately (server dropped); the third
        // stays open so the loop parks instead of spinning.
        return connects <= 2 ? const Stream<LiveEvent>.empty() : parked.stream;
      },
      onReadProgress: (_) async {},
      onInvalidate: (_) {},
      onSessionExpired: () {},
      delay: (d) async => delays.add(d),
      random: () => 0, // full jitter floor -> deterministic cap/2
      baseBackoff: const Duration(seconds: 1),
    );

    c.start();
    // Wait until it parks on the open (third) connection.
    for (var i = 0; i < 50 && connects < 3; i++) {
      await Future<void>.delayed(Duration.zero);
    }

    expect(connects, 3);
    // attempt 1 -> cap 1000ms, *0.5 = 500ms; attempt 2 -> cap 2000ms -> 1000ms.
    expect(delays, const [
      Duration(milliseconds: 500),
      Duration(milliseconds: 1000),
    ]);

    await c.stop();
    await parked.close();
  });

  test('stop() ends the loop and cancels the subscription', () async {
    final stream = StreamController<LiveEvent>();
    var canceled = false;
    stream.onCancel = () => canceled = true;
    final c = LiveSyncController(
      connect: () => stream.stream,
      onReadProgress: (_) async {},
      onInvalidate: (_) {},
      onSessionExpired: () {},
      delay: (_) async {},
      random: () => 0,
    );

    c.start();
    await settle(2);
    await c.stop();

    expect(canceled, isTrue);
    await stream.close();
  });
}
