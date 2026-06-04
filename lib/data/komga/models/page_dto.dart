/// A single page entry of a book. [number] is 1-based (Komga's page addressing).
class PageDto {
  const PageDto({
    required this.number,
    required this.fileName,
    this.mediaType,
    this.width,
    this.height,
    this.sizeBytes,
  });

  final int number;
  final String fileName;
  final String? mediaType;
  final int? width;
  final int? height;
  final int? sizeBytes;

  factory PageDto.fromJson(Map<String, Object?> json) => PageDto(
        number: (json['number'] as num).toInt(),
        fileName: json['fileName'] as String? ?? '',
        mediaType: json['mediaType'] as String?,
        width: (json['width'] as num?)?.toInt(),
        height: (json['height'] as num?)?.toInt(),
        sizeBytes: (json['sizeBytes'] as num?)?.toInt(),
      );
}
