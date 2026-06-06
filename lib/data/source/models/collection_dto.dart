/// Komga collection (a curated, ordered set of series). Online-only in T2 (no
/// Drift table yet; persistence lands with the browse UI in T3).
class CollectionDto {
  const CollectionDto({
    required this.id,
    required this.name,
    this.ordered = false,
    this.seriesIds = const [],
  });

  final String id;
  final String name;
  final bool ordered;
  final List<String> seriesIds;

  factory CollectionDto.fromJson(Map<String, Object?> json) => CollectionDto(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        ordered: json['ordered'] as bool? ?? false,
        seriesIds: ((json['seriesIds'] as List?) ?? const [])
            .map((e) => e as String)
            .toList(growable: false),
      );
}
