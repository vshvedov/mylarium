import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/data/komga/sse/komga_sse_decoder.dart';
import 'package:mylarium/data/source/models/live_event.dart';

void main() {
  group('komgaSseEventFrom (frame -> LiveEvent)', () {
    test('maps a read-progress change to its book id', () {
      expect(
        komgaSseEventFrom('ReadProgressChanged', '{"bookId":"b1","userId":"u"}'),
        const ReadProgressChanged('b1'),
      );
    });

    test('maps read-progress delete and series change', () {
      expect(
        komgaSseEventFrom('ReadProgressDeleted', '{"bookId":"b2"}'),
        const ReadProgressDeleted('b2'),
      );
      expect(
        komgaSseEventFrom(
            'ReadProgressSeriesChanged', '{"seriesId":"s9","userId":"u"}'),
        const ReadProgressSeriesChanged('s9'),
      );
    });

    test('book/series add/change/delete all collapse to a refresh event', () {
      for (final name in ['BookAdded', 'BookChanged', 'BookDeleted']) {
        expect(komgaSseEventFrom(name, '{"bookId":"b"}'), const BookChanged('b'));
      }
      for (final name in ['SeriesAdded', 'SeriesChanged', 'SeriesDeleted']) {
        expect(
          komgaSseEventFrom(name, '{"seriesId":"s"}'),
          const SeriesChanged('s'),
        );
      }
    });

    test('thumbnail and library events carry their ids', () {
      expect(
        komgaSseEventFrom(
            'ThumbnailBookAdded', '{"bookId":"b","seriesId":"s"}'),
        const ThumbnailChanged(bookId: 'b', seriesId: 's'),
      );
      expect(
        komgaSseEventFrom('LibraryChanged', '{"libraryId":"l"}'),
        const LibraryChanged('l'),
      );
    });

    test('session expiry maps to SessionExpired', () {
      expect(
        komgaSseEventFrom('SessionExpired', '{"userId":"u"}'),
        const SessionExpired(),
      );
    });

    test('an unknown event name becomes UnknownEvent (forward-compat)', () {
      expect(
        komgaSseEventFrom('TaskQueueStatus', '{"count":3}'),
        const UnknownEvent('TaskQueueStatus'),
      );
    });

    test('a missing required id falls back to UnknownEvent, never an empty id',
        () {
      expect(
        komgaSseEventFrom('ReadProgressChanged', '{"userId":"u"}'),
        const UnknownEvent('ReadProgressChanged'),
      );
    });

    test('malformed JSON does not throw; becomes UnknownEvent', () {
      expect(
        komgaSseEventFrom('BookChanged', 'not json'),
        const UnknownEvent('BookChanged'),
      );
    });
  });

  group('decodeKomgaSse (byte stream -> events)', () {
    Stream<List<int>> bytesOf(String s) =>
        Stream.value(utf8.encode(s));

    test('parses a multi-event stream split into frames by blank lines',
        () async {
      const wire =
          'event:ReadProgressChanged\n'
          'data:{"bookId":"b1"}\n'
          '\n'
          ':keep-alive\n'
          'event:SeriesChanged\n'
          'data:{"seriesId":"s1"}\n'
          '\n';
      final events = await decodeKomgaSse(bytesOf(wire)).toList();
      expect(events, const [
        ReadProgressChanged('b1'),
        SeriesChanged('s1'),
      ]);
    });

    test('strips a single leading space after the colon and ignores id lines',
        () async {
      const wire =
          'id: 42\n'
          'event: BookChanged\n'
          'data: {"bookId":"b7"}\n'
          '\n';
      final events = await decodeKomgaSse(bytesOf(wire)).toList();
      expect(events, const [BookChanged('b7')]);
    });

    test('joins multiple data lines in one frame', () async {
      const wire = 'event:SessionExpired\n'
          'data:{\n'
          'data:"userId":"u"}\n'
          '\n';
      final events = await decodeKomgaSse(bytesOf(wire)).toList();
      expect(events, const [SessionExpired()]);
    });

    test('a frame split across byte chunks still decodes', () async {
      Stream<List<int>> chunks() async* {
        yield utf8.encode('event:ReadProgressChanged\n');
        yield utf8.encode('data:{"bookId":');
        yield utf8.encode('"b9"}\n\n');
      }

      final events = await decodeKomgaSse(chunks()).toList();
      expect(events, const [ReadProgressChanged('b9')]);
    });
  });
}
