/// Spring `Page<T>` envelope. The four PRD-contract fields (content,
/// totalElements, number, last) are public; the rest are parsed too so paging
/// can tell an empty result from a final partial page.
class Page<T> {
  const Page({
    required this.content,
    required this.totalElements,
    required this.number,
    required this.last,
    this.totalPages = 0,
    this.size = 0,
    this.numberOfElements = 0,
    this.first = true,
    this.empty = false,
  });

  final List<T> content;
  final int totalElements;
  final int totalPages;
  final int number;
  final int size;
  final int numberOfElements;
  final bool first;
  final bool last;
  final bool empty;

  factory Page.fromJson(
    Map<String, Object?> json,
    T Function(Map<String, Object?>) item,
  ) {
    final raw = (json['content'] as List?) ?? const [];
    final content =
        raw.map((e) => item(e as Map<String, Object?>)).toList(growable: false);
    int asInt(Object? v, int fallback) => (v as num?)?.toInt() ?? fallback;
    return Page(
      content: content,
      totalElements: asInt(json['totalElements'], content.length),
      totalPages: asInt(json['totalPages'], 0),
      number: asInt(json['number'], 0),
      size: asInt(json['size'], content.length),
      numberOfElements: asInt(json['numberOfElements'], content.length),
      first: json['first'] as bool? ?? (asInt(json['number'], 0) == 0),
      last: json['last'] as bool? ?? true,
      empty: json['empty'] as bool? ?? content.isEmpty,
    );
  }
}
