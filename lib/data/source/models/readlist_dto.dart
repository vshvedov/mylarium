/// Komga read list (a curated, ordered set of books). Online-only in T2 (no
/// Drift table yet; persistence lands with the browse UI in T3).
class ReadListDto {
  const ReadListDto({
    required this.id,
    required this.name,
    this.ordered = false,
    this.bookIds = const [],
  });

  final String id;
  final String name;
  final bool ordered;
  final List<String> bookIds;

  factory ReadListDto.fromJson(Map<String, Object?> json) => ReadListDto(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        ordered: json['ordered'] as bool? ?? false,
        bookIds: ((json['bookIds'] as List?) ?? const [])
            .map((e) => e as String)
            .toList(growable: false),
      );
}
