/// Komga library resource (minimal fields used in T2).
class LibraryDto {
  const LibraryDto({required this.id, required this.name});

  final String id;
  final String name;

  factory LibraryDto.fromJson(Map<String, Object?> json) => LibraryDto(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
      );
}
