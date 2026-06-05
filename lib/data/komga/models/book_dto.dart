import 'komga_meta.dart';

/// Komga book resource. `metadata` carries title/number; `media` carries page
/// count and type; `readProgress` (nullable) carries last-known progress.
class BookDto {
  const BookDto({
    required this.id,
    required this.seriesId,
    required this.libraryId,
    required this.name,
    required this.title,
    required this.number,
    this.numberSort,
    this.pagesCount = 0,
    this.mediaType,
    this.sizeBytes,
    this.readPage,
    this.completed = false,
    this.readDate,
    this.readLastModified,
    this.summary,
    this.tags = const [],
    this.authors = const [],
    this.releaseDate,
    this.links = const [],
  });

  final String id;
  final String seriesId;
  final String libraryId;
  final String name;
  final String title;
  final String number;
  final double? numberSort;
  final int pagesCount;
  final String? mediaType;
  final int? sizeBytes;
  final int? readPage;
  final bool completed;

  /// Richer T3 detail metadata. The file name is [name]; file size is
  /// [sizeBytes]; page count is [pagesCount]; read date is [readDate].
  final String? summary;
  final List<String> tags;
  final List<KomgaAuthor> authors;

  /// Release date as epoch ms (parsed from `metadata.releaseDate`, a `YYYY-MM-DD`
  /// string), or null when unset.
  final int? releaseDate;
  final List<KomgaLink> links;

  /// When the server last recorded a read for this book (epoch ms), parsed from
  /// `readProgress.readDate`. Null when never read. Used to time a synthesized
  /// off-device reading session during reconciliation.
  final int? readDate;

  /// When the server's read-progress row was last modified (epoch ms), parsed
  /// from `readProgress.lastModified`. The reconcile baseline (server clock).
  final int? readLastModified;

  factory BookDto.fromJson(Map<String, Object?> json) {
    final meta = (json['metadata'] as Map<String, Object?>?) ?? const {};
    final media = (json['media'] as Map<String, Object?>?) ?? const {};
    final progress = json['readProgress'] as Map<String, Object?>?;
    final name = json['name'] as String? ?? '';
    return BookDto(
      id: json['id'] as String,
      seriesId: json['seriesId'] as String? ?? '',
      libraryId: json['libraryId'] as String? ?? '',
      name: name,
      title: meta['title'] as String? ?? name,
      number: meta['number'] as String? ?? '',
      numberSort: (meta['numberSort'] as num?)?.toDouble(),
      pagesCount: (media['pagesCount'] as num?)?.toInt() ?? 0,
      mediaType: media['mediaType'] as String?,
      sizeBytes: (json['sizeBytes'] as num?)?.toInt(),
      readPage: (progress?['page'] as num?)?.toInt(),
      completed: progress?['completed'] as bool? ?? false,
      readDate: _epochMs(progress?['readDate']),
      readLastModified: _epochMs(progress?['lastModified']),
      summary: () {
        final s = meta['summary'] as String?;
        return (s == null || s.isEmpty) ? null : s;
      }(),
      tags: parseStringList(meta['tags']),
      authors: parseAuthors(meta['authors']),
      releaseDate: _epochMs(meta['releaseDate']),
      links: parseLinks(meta['links']),
    );
  }
}

/// Parses an ISO-8601 timestamp string into epoch milliseconds, or null when
/// absent/unparseable. The value is only ever compared against other values
/// from the same source, so zone handling does not affect correctness.
int? _epochMs(Object? iso) {
  if (iso is! String || iso.isEmpty) return null;
  return DateTime.tryParse(iso)?.millisecondsSinceEpoch;
}
