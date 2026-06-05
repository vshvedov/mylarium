/// Small pure value types shared by `BookDto`/`SeriesDto` for the richer T3
/// detail metadata. No Flutter imports so they stay trivially testable.
library;

/// A Komga creator: `metadata.authors[] = {name, role}` (role e.g. "writer",
/// "penciller", "cover").
class KomgaAuthor {
  const KomgaAuthor({required this.name, required this.role});

  final String name;
  final String role;

  factory KomgaAuthor.fromJson(Map<String, Object?> json) => KomgaAuthor(
        name: json['name'] as String? ?? '',
        role: json['role'] as String? ?? '',
      );
}

/// A Komga external link: `metadata.links[] = {label, url}`.
class KomgaLink {
  const KomgaLink({required this.label, required this.url});

  final String label;
  final String url;

  factory KomgaLink.fromJson(Map<String, Object?> json) => KomgaLink(
        label: json['label'] as String? ?? '',
        url: json['url'] as String? ?? '',
      );
}

/// Parses a Komga `metadata.authors` array into [KomgaAuthor]s (empty when
/// absent).
List<KomgaAuthor> parseAuthors(Object? raw) => raw is List
    ? [
        for (final e in raw)
          if (e is Map<String, Object?>) KomgaAuthor.fromJson(e),
      ]
    : const [];

/// Parses a Komga `metadata.links` array into [KomgaLink]s (empty when absent).
List<KomgaLink> parseLinks(Object? raw) => raw is List
    ? [
        for (final e in raw)
          if (e is Map<String, Object?>) KomgaLink.fromJson(e),
      ]
    : const [];

/// Parses a Komga `metadata.tags` (or genres) array of strings (empty when
/// absent).
List<String> parseStringList(Object? raw) =>
    raw is List ? raw.whereType<String>().toList(growable: false) : const [];
