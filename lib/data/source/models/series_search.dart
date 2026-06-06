/// Filters for series search. Serializes to the `POST /api/v1/series/list`
/// condition body, with full-text carried separately as `?full_text_search=`.
///
/// Each list filter becomes an `anyOf` group of `is` clauses; the groups are
/// combined under a top-level `allOf` (match all categories, any value within).
class SeriesSearch {
  const SeriesSearch({
    this.fullText,
    this.libraryIds,
    this.status,
    this.readStatus,
    this.genres,
    this.tags,
    this.publishers,
    this.ageRatings,
  });

  final String? fullText;
  final List<String>? libraryIds;
  final List<String>? status;
  final List<String>? readStatus;
  final List<String>? genres;
  final List<String>? tags;
  final List<String>? publishers;
  final List<int>? ageRatings;

  /// The full-text term, or null when none is set.
  String? get fullTextSearch =>
      (fullText == null || fullText!.isEmpty) ? null : fullText;

  /// POST `/list` body for Komga. Carries `fullTextSearch` (the Lucene text
  /// query) and a structured `condition`, both in the BODY (Komga ignores a
  /// `full_text_search` query parameter). Returns `{}` when neither is set.
  Map<String, Object?> toRequestBody() {
    final groups = <Map<String, Object?>>[];

    void addStringGroup(String field, List<String>? values) {
      if (values == null || values.isEmpty) return;
      groups.add({
        'anyOf': [
          for (final v in values)
            {
              field: {'operator': 'is', 'value': v}
            },
        ],
      });
    }

    addStringGroup('libraryId', libraryIds);
    addStringGroup('seriesStatus', status);
    addStringGroup('readStatus', readStatus);
    addStringGroup('genre', genres);
    addStringGroup('tag', tags);
    addStringGroup('publisher', publishers);
    if (ageRatings != null && ageRatings!.isNotEmpty) {
      groups.add({
        'anyOf': [
          for (final v in ageRatings!)
            {
              'ageRating': {'operator': 'is', 'value': v}
            },
        ],
      });
    }

    final body = <String, Object?>{};
    if (fullTextSearch != null) body['fullTextSearch'] = fullTextSearch;
    if (groups.isNotEmpty) {
      body['condition'] = {'allOf': groups};
    }
    return body;
  }
}
