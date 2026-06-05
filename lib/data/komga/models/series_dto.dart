import 'komga_meta.dart';

/// Komga series resource. Title/sort/age/status/summary live under `metadata`.
class SeriesDto {
  const SeriesDto({
    required this.id,
    required this.libraryId,
    required this.name,
    required this.title,
    required this.titleSort,
    this.ageRating,
    this.status,
    this.summary,
    this.readingDirection,
    this.booksCount = 0,
    this.publisher,
    this.genres = const [],
    this.tags = const [],
    this.links = const [],
    this.language,
  });

  final String id;
  final String libraryId;
  final String name;
  final String title;
  final String titleSort;

  /// Null when the server supplies none; never coerced to 0 (T3 age-gating
  /// distinguishes "unset" from a real rating of 0).
  final int? ageRating;
  final String? status;
  final String? summary;

  /// Komga reading direction (LEFT_TO_RIGHT / RIGHT_TO_LEFT / VERTICAL /
  /// WEBTOON), used to seed the reader's default mode. Null when unset.
  final String? readingDirection;
  final int booksCount;

  /// Publisher, for the stats publisher breakdown. Null when unset.
  final String? publisher;

  /// Genres, for the stats genre breakdown (tag-overlap). Empty when unset.
  final List<String> genres;

  /// Richer T3 detail metadata.
  final List<String> tags;
  final List<KomgaLink> links;
  final String? language;

  factory SeriesDto.fromJson(Map<String, Object?> json) {
    final meta = (json['metadata'] as Map<String, Object?>?) ?? const {};
    final name = json['name'] as String? ?? '';
    final publisher = meta['publisher'] as String?;
    final rawGenres = meta['genres'];
    final language = meta['language'] as String?;
    return SeriesDto(
      id: json['id'] as String,
      libraryId: json['libraryId'] as String? ?? '',
      name: name,
      title: meta['title'] as String? ?? name,
      titleSort: meta['titleSort'] as String? ?? name,
      ageRating: (meta['ageRating'] as num?)?.toInt(),
      status: meta['status'] as String?,
      summary: meta['summary'] as String?,
      readingDirection: meta['readingDirection'] as String?,
      booksCount: (json['booksCount'] as num?)?.toInt() ?? 0,
      publisher: (publisher == null || publisher.isEmpty) ? null : publisher,
      genres: rawGenres is List
          ? rawGenres.whereType<String>().toList(growable: false)
          : const [],
      tags: parseStringList(meta['tags']),
      links: parseLinks(meta['links']),
      language: (language == null || language.isEmpty) ? null : language,
    );
  }
}
