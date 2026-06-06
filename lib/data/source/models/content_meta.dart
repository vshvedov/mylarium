/// Small pure value types shared by `BookDto`/`SeriesDto` for the richer T3
/// detail metadata. No Flutter imports so they stay trivially testable.
library;

/// A Komga creator: `metadata.authors[] = {name, role}` (role e.g. "writer",
/// "penciller", "cover").
class ContentAuthor {
  const ContentAuthor({required this.name, required this.role});

  final String name;
  final String role;

  factory ContentAuthor.fromJson(Map<String, Object?> json) => ContentAuthor(
        name: json['name'] as String? ?? '',
        role: json['role'] as String? ?? '',
      );
}

/// A Komga external link: `metadata.links[] = {label, url}`.
class ContentLink {
  const ContentLink({required this.label, required this.url});

  final String label;
  final String url;

  factory ContentLink.fromJson(Map<String, Object?> json) => ContentLink(
        label: json['label'] as String? ?? '',
        url: json['url'] as String? ?? '',
      );
}

/// Parses a Komga `metadata.authors` array into [ContentAuthor]s (empty when
/// absent).
List<ContentAuthor> parseAuthors(Object? raw) => raw is List
    ? [
        for (final e in raw)
          if (e is Map<String, Object?>) ContentAuthor.fromJson(e),
      ]
    : const [];

/// Parses a Komga `metadata.links` array into [ContentLink]s (empty when absent).
List<ContentLink> parseLinks(Object? raw) => raw is List
    ? [
        for (final e in raw)
          if (e is Map<String, Object?>) ContentLink.fromJson(e),
      ]
    : const [];

/// Parses a Komga `metadata.tags` (or genres) array of strings (empty when
/// absent).
List<String> parseStringList(Object? raw) =>
    raw is List ? raw.whereType<String>().toList(growable: false) : const [];
