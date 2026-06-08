import 'dart:async';
import 'dart:convert';

import '../../source/models/live_event.dart';

/// Decodes a Komga Server-Sent-Events byte stream (`GET /sse/v1/events`) into
/// typed [LiveEvent]s. Pure and transport-agnostic: it takes the raw response
/// byte stream and yields events, so it is unit-testable without a network.
///
/// SSE wire format: UTF-8 text, one event per blank-line-terminated frame. Each
/// frame has an `event:` line (the Komga event name) and one or more `data:`
/// lines (a JSON object); `:`-comment lines are keep-alives and `id:`/`retry:`
/// are ignored. See https://html.spec.whatwg.org/multipage/server-sent-events.
Stream<LiveEvent> decodeKomgaSse(Stream<List<int>> bytes) async* {
  var event = '';
  final data = <String>[];
  await for (final line
      in bytes.transform(utf8.decoder).transform(const LineSplitter())) {
    if (line.isEmpty) {
      // Frame boundary: dispatch what we have, then reset.
      if (event.isNotEmpty || data.isNotEmpty) {
        yield komgaSseEventFrom(event, data.join('\n'));
      }
      event = '';
      data.clear();
      continue;
    }
    if (line.startsWith(':')) continue; // keep-alive comment
    final colon = line.indexOf(':');
    final field = colon == -1 ? line : line.substring(0, colon);
    // A single leading space after the colon is part of the format, not data.
    var value = colon == -1 ? '' : line.substring(colon + 1);
    if (value.startsWith(' ')) value = value.substring(1);
    switch (field) {
      case 'event':
        event = value;
      case 'data':
        data.add(value);
      // 'id' / 'retry' / anything else: ignored.
    }
  }
}

/// Maps one Komga SSE frame (event name + JSON `data` payload) to a [LiveEvent].
/// Total and forward-compatible: an unrecognised or unusable frame (missing id,
/// malformed JSON, or an event the app does not act on) becomes [UnknownEvent]
/// so the decoder never throws on the wire.
LiveEvent komgaSseEventFrom(String event, String data) {
  Map<String, dynamic> json;
  try {
    json = data.isEmpty
        ? const <String, dynamic>{}
        : (jsonDecode(data) as Map<String, dynamic>);
  } catch (_) {
    return UnknownEvent(event);
  }
  String? str(String key) {
    final v = json[key];
    return v is String && v.isNotEmpty ? v : null;
  }

  // Helpers that fall back to UnknownEvent when the required id is absent, so a
  // malformed payload can never produce an event with an empty id.
  LiveEvent needBook(LiveEvent Function(String) make) {
    final id = str('bookId');
    return id == null ? UnknownEvent(event) : make(id);
  }

  LiveEvent needSeries(LiveEvent Function(String) make) {
    final id = str('seriesId');
    return id == null ? UnknownEvent(event) : make(id);
  }

  switch (event) {
    case 'ReadProgressChanged':
      return needBook(ReadProgressChanged.new);
    case 'ReadProgressDeleted':
      return needBook(ReadProgressDeleted.new);
    case 'ReadProgressSeriesChanged':
    case 'ReadProgressSeriesDeleted':
      return needSeries(ReadProgressSeriesChanged.new);
    case 'BookAdded':
    case 'BookChanged':
    case 'BookDeleted':
      return needBook(BookChanged.new);
    case 'SeriesAdded':
    case 'SeriesChanged':
    case 'SeriesDeleted':
      return needSeries(SeriesChanged.new);
    case 'ThumbnailBookAdded':
    case 'ThumbnailBookDeleted':
      return ThumbnailChanged(bookId: str('bookId'), seriesId: str('seriesId'));
    case 'ThumbnailSeriesAdded':
    case 'ThumbnailSeriesDeleted':
      return ThumbnailChanged(seriesId: str('seriesId'));
    case 'LibraryAdded':
    case 'LibraryChanged':
    case 'LibraryDeleted':
      final id = str('libraryId');
      return id == null ? UnknownEvent(event) : LibraryChanged(id);
    case 'SessionExpired':
      return const SessionExpired();
    default:
      return UnknownEvent(event);
  }
}
