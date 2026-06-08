/// A live update pushed by a content server (T1). Source-neutral: today only
/// Komga emits these (over SSE), but the [ContentApi.liveEvents] seam keeps the
/// type free of any transport so a future source can produce the same set.
///
/// Read-progress events deliberately carry only an id (Komga's SSE payload does
/// the same): the live-sync controller re-fetches the authoritative server page
/// and merges it through the reconciler, so an event can never carry a stale
/// page that clobbers local progress.
sealed class LiveEvent {
  const LiveEvent();
}

/// A book's read-progress changed on the server (read on another device or the
/// web reader). Routed through the reconciler's single-book merge.
class ReadProgressChanged extends LiveEvent {
  const ReadProgressChanged(this.bookId);
  final String bookId;

  @override
  bool operator ==(Object other) =>
      other is ReadProgressChanged && other.bookId == bookId;
  @override
  int get hashCode => bookId.hashCode;
  @override
  String toString() => 'ReadProgressChanged($bookId)';
}

/// A book's read-progress was deleted on the server (marked unread elsewhere).
class ReadProgressDeleted extends LiveEvent {
  const ReadProgressDeleted(this.bookId);
  final String bookId;

  @override
  bool operator ==(Object other) =>
      other is ReadProgressDeleted && other.bookId == bookId;
  @override
  int get hashCode => bookId.hashCode;
  @override
  String toString() => 'ReadProgressDeleted($bookId)';
}

/// A whole series' read-progress changed on the server (e.g. marked read).
class ReadProgressSeriesChanged extends LiveEvent {
  const ReadProgressSeriesChanged(this.seriesId);
  final String seriesId;

  @override
  bool operator ==(Object other) =>
      other is ReadProgressSeriesChanged && other.seriesId == seriesId;
  @override
  int get hashCode => seriesId.hashCode;
  @override
  String toString() => 'ReadProgressSeriesChanged($seriesId)';
}

/// A book was added, changed, or removed on the server (metadata/availability).
class BookChanged extends LiveEvent {
  const BookChanged(this.bookId);
  final String bookId;

  @override
  bool operator ==(Object other) =>
      other is BookChanged && other.bookId == bookId;
  @override
  int get hashCode => bookId.hashCode;
  @override
  String toString() => 'BookChanged($bookId)';
}

/// A series was added, changed, or removed on the server.
class SeriesChanged extends LiveEvent {
  const SeriesChanged(this.seriesId);
  final String seriesId;

  @override
  bool operator ==(Object other) =>
      other is SeriesChanged && other.seriesId == seriesId;
  @override
  int get hashCode => seriesId.hashCode;
  @override
  String toString() => 'SeriesChanged($seriesId)';
}

/// A thumbnail changed for a book and/or series (so a cover can refresh).
class ThumbnailChanged extends LiveEvent {
  const ThumbnailChanged({this.bookId, this.seriesId});
  final String? bookId;
  final String? seriesId;

  @override
  bool operator ==(Object other) =>
      other is ThumbnailChanged &&
      other.bookId == bookId &&
      other.seriesId == seriesId;
  @override
  int get hashCode => Object.hash(bookId, seriesId);
  @override
  String toString() => 'ThumbnailChanged(book: $bookId, series: $seriesId)';
}

/// A library was added, changed, or removed on the server.
class LibraryChanged extends LiveEvent {
  const LibraryChanged(this.libraryId);
  final String libraryId;

  @override
  bool operator ==(Object other) =>
      other is LibraryChanged && other.libraryId == libraryId;
  @override
  int get hashCode => libraryId.hashCode;
  @override
  String toString() => 'LibraryChanged($libraryId)';
}

/// The server session/auth expired; the stream is no longer trustworthy. The
/// controller stops reconnecting and surfaces a non-blocking re-auth affordance.
class SessionExpired extends LiveEvent {
  const SessionExpired();

  @override
  bool operator ==(Object other) => other is SessionExpired;
  @override
  int get hashCode => 0x5e55104;
  @override
  String toString() => 'SessionExpired()';
}

/// An event the app does not act on (task-queue status, collection/read-list
/// changes, unrecognised future events). Kept so the decoder is total and
/// forward-compatible; the controller ignores it.
class UnknownEvent extends LiveEvent {
  const UnknownEvent(this.name);
  final String name;

  @override
  bool operator ==(Object other) =>
      other is UnknownEvent && other.name == name;
  @override
  int get hashCode => name.hashCode;
  @override
  String toString() => 'UnknownEvent($name)';
}
