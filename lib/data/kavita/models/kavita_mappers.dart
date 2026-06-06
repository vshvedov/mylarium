import '../../source/models/book_dto.dart';
import '../../source/models/collection_dto.dart';
import '../../source/models/library_dto.dart';
import '../../source/models/page_dto.dart';
import '../../source/models/readlist_dto.dart';
import '../../source/models/series_dto.dart';

/// Maps Kavita JSON into the shared `*Dto` contract (the neutral transfer shape
/// the repositories and reader consume). Kavita's hierarchy is
/// library -> series -> volume -> chapter; the app's flat model is
/// library -> series -> book, so a "book" is a Kavita VOLUME (its number/name
/// drive ordering) and the volume's single sentinel chapter id is used to fetch
/// pages and write progress.

/// Kavita's sentinel chapter number for a whole-volume (non-chapterized) file.
const kavitaLooseLeafSentinel = -100000;

/// Kavita LibraryType.Manga reads right-to-left; everything else left-to-right.
const _kavitaMangaLibraryType = 0;

String? _statusName(Object? raw) {
  final s = (raw as num?)?.toInt();
  return switch (s) {
    0 => 'ONGOING',
    1 => 'HIATUS',
    2 => 'COMPLETED',
    3 => 'ABANDONED',
    4 => 'ENDED',
    _ => null,
  };
}

List<String> _names(Object? raw) {
  if (raw is! List) return const [];
  return raw
      .map((e) => e is Map ? e['name'] as String? : e as String?)
      .whereType<String>()
      .where((s) => s.isNotEmpty)
      .toList(growable: false);
}

LibraryDto kavitaLibraryToDto(Map<String, Object?> json) => LibraryDto(
      id: '${json['id']}',
      name: json['name'] as String? ?? '',
    );

/// Maps a Kavita series object (from `all-v2` / `Series/v2`) plus optional
/// `Series/metadata` into a [SeriesDto]. [libraryType] sets the default reading
/// direction; [booksCount] is supplied by the caller (browse leaves it 0,
/// series detail counts the volumes' chapters).
SeriesDto kavitaSeriesToDto(
  Map<String, Object?> json, {
  Map<String, Object?>? metadata,
  int? libraryType,
  int booksCount = 0,
}) {
  final name = json['name'] as String? ?? '';
  final sortName = json['sortName'] as String?;
  final meta = metadata ?? const {};
  final publishers = _names(meta['publishers']);
  final ageRating = (meta['ageRating'] as num?)?.toInt();
  return SeriesDto(
    id: '${json['id']}',
    libraryId: '${json['libraryId']}',
    name: name,
    title: name,
    titleSort: (sortName == null || sortName.isEmpty) ? name : sortName,
    summary: meta['summary'] as String?,
    status: _statusName(meta['publicationStatus']),
    // Kavita uses 0 for "unset"; keep null so age handling matches Komga.
    ageRating: (ageRating == null || ageRating == 0) ? null : ageRating,
    booksCount: booksCount,
    readingDirection:
        libraryType == _kavitaMangaLibraryType ? 'RIGHT_TO_LEFT' : 'LEFT_TO_RIGHT',
    publisher: publishers.isEmpty ? null : publishers.first,
    genres: _names(meta['genres']),
  );
}

/// Maps a Kavita search hit (`/Search/search` `.series[]`) into a [SeriesDto].
/// Search hits carry `seriesId` (not `id`) and no metadata, so reading direction
/// defaults LTR (the reader re-resolves via `getSeries` on open).
SeriesDto kavitaSearchHitToDto(Map<String, Object?> json) {
  final name = json['name'] as String? ?? '';
  final sortName = json['sortName'] as String?;
  final volumeCount = (json['volumeCount'] as num?)?.toInt() ?? 0;
  final chapterCount = (json['chapterCount'] as num?)?.toInt() ?? 0;
  return SeriesDto(
    id: '${json['seriesId']}',
    libraryId: '${json['libraryId']}',
    name: name,
    title: name,
    titleSort: (sortName == null || sortName.isEmpty) ? name : sortName,
    booksCount: volumeCount + chapterCount,
    readingDirection: 'LEFT_TO_RIGHT',
  );
}

/// Flattens a Kavita `Series/volumes` response (a list of volumes, each with a
/// `chapters` list) into ordered [BookDto]s. [seriesId]/[libraryId] are the
/// owning ids. Whole-volume sentinel chapters take their number/name/sort from
/// the VOLUME; real chapters keep their own.
List<BookDto> kavitaVolumesToBooks(
  List<Object?> volumes, {
  required String seriesId,
  required String libraryId,
}) {
  final books = <_OrderedBook>[];
  for (final v in volumes) {
    if (v is! Map<String, Object?>) continue;
    final volMin = (v['minNumber'] as num?)?.toDouble() ?? 0;
    final chapters = (v['chapters'] as List?) ?? const [];
    for (final c in chapters) {
      if (c is! Map<String, Object?>) continue;
      books.add(_OrderedBook(
        volMin,
        kavitaChapterToBook(c, v, seriesId: seriesId, libraryId: libraryId),
      ));
    }
  }
  books.sort((a, b) {
    final byVol = a.volMin.compareTo(b.volMin);
    if (byVol != 0) return byVol;
    return (a.book.numberSort ?? 0).compareTo(b.book.numberSort ?? 0);
  });
  return books.map((b) => b.book).toList(growable: false);
}

/// Maps a single Kavita chapter (with its owning [volume] for sentinel naming)
/// into a [BookDto]. [volume] may be null when only the chapter is known
/// (e.g. `getBook` via `Series/chapter`).
BookDto kavitaChapterToBook(
  Map<String, Object?> chapter,
  Map<String, Object?>? volume, {
  required String seriesId,
  required String libraryId,
}) {
  final minNumber = (chapter['minNumber'] as num?)?.toInt() ?? 0;
  final isWholeVolume = minNumber == kavitaLooseLeafSentinel;
  final titleName = chapter['titleName'] as String? ?? '';
  final range = chapter['range'] as String? ?? '';
  final volName = volume?['name'] as String? ?? '';
  final volNumber = (volume?['number'] as num?)?.toDouble();
  final pages = (chapter['pages'] as num?)?.toInt() ?? 0;
  final pagesRead = (chapter['pagesRead'] as num?)?.toInt() ?? 0;
  final hasProgress = pagesRead > 0;
  // Kavita pagesRead is a 0-based current page; the shared contract (Komga's)
  // is a 1-based page that is null when there is no progress.
  final readPage = hasProgress ? pagesRead + 1 : null;
  final progressTs =
      hasProgress ? _kavitaEpochMs(chapter['lastReadingProgressUtc']) : null;

  final String name;
  if (titleName.isNotEmpty) {
    name = titleName;
  } else if (isWholeVolume) {
    name = volName.isEmpty ? 'Volume' : 'Volume $volName';
  } else {
    name = 'Chapter $range';
  }

  return BookDto(
    id: '${chapter['id']}',
    seriesId: seriesId,
    libraryId: libraryId,
    name: name,
    title: name,
    number: isWholeVolume ? (volName.isEmpty ? '' : volName) : range,
    numberSort: isWholeVolume
        ? (volNumber ?? 0)
        : (chapter['sortOrder'] as num?)?.toDouble(),
    pagesCount: pages,
    mediaType: 'application/x-cbz',
    readPage: readPage,
    completed: pages > 0 && pagesRead >= pages,
    readDate: progressTs,
    readLastModified: progressTs,
  );
}

/// Parses a Kavita UTC timestamp into epoch ms, treating Kavita's "unset"
/// sentinel (year 0001) and empty values as null.
int? _kavitaEpochMs(Object? iso) {
  if (iso is! String || iso.isEmpty) return null;
  final dt = DateTime.tryParse(iso);
  if (dt == null || dt.year < 2) return null;
  return dt.millisecondsSinceEpoch;
}

/// Maps a Kavita user collection (`/Collection`) into a [CollectionDto]. Member
/// series are fetched separately via `/Collection/all-series`.
CollectionDto kavitaCollectionToDto(Map<String, Object?> json) => CollectionDto(
      id: '${json['id']}',
      name: json['title'] as String? ?? '',
    );

/// Maps a Kavita reading list (`/ReadingList/lists`) into a [ReadListDto].
/// Reading lists are always ordered.
ReadListDto kavitaReadListToDto(Map<String, Object?> json) => ReadListDto(
      id: '${json['id']}',
      name: json['title'] as String? ?? '',
      ordered: true,
    );

/// Maps a Kavita reading-list item (`/ReadingList/items`) into a [BookDto]. The
/// readable unit is the chapter; numbering prefers the chapter, then the volume.
BookDto kavitaReadListItemToBook(Map<String, Object?> json) {
  final pages = (json['pagesTotal'] as num?)?.toInt() ?? 0;
  final pagesRead = (json['pagesRead'] as num?)?.toInt() ?? 0;
  final number = json['chapterNumber'] ?? json['volumeNumber'];
  final name = json['title'] as String? ?? '';
  return BookDto(
    id: '${json['chapterId']}',
    seriesId: '${json['seriesId']}',
    libraryId: '${json['libraryId']}',
    name: name,
    title: name,
    number: number == null ? '' : '$number',
    pagesCount: pages,
    mediaType: 'application/x-cbz',
    readPage: pagesRead > 0 ? pagesRead + 1 : null,
    completed: pages > 0 && pagesRead >= pages,
  );
}

/// Synthesizes the per-page list for a chapter of [pageCount] pages. Kavita has
/// no per-page metadata endpoint; the page source only needs the 1-based number.
List<PageDto> kavitaPages(int pageCount) => [
      for (var i = 1; i <= pageCount; i++) PageDto(number: i, fileName: ''),
    ];

class _OrderedBook {
  _OrderedBook(this.volMin, this.book);
  final double volMin;
  final BookDto book;
}
