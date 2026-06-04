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
    );
  }
}
