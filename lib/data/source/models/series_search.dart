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
    final fuzzy = buildFuzzyFullText(fullText);
    if (fuzzy != null) body['fullTextSearch'] = fuzzy;
    if (groups.isNotEmpty) {
      body['condition'] = {'allOf': groups};
    }
    return body;
  }
}

/// Lucene specials that, inside a word token, mean we must not append fuzzy or
/// wildcard operators to it: a trailing `~` on a hyphenated compound (e.g.
/// `spider-man~`) matches nothing on Komga, so such tokens are passed through
/// verbatim instead.
const _luceneSpecials = r'+-&|!(){}[]^"~*?:\/';

/// Builds a typo-tolerant Komga/Lucene `fullTextSearch` string from raw user
/// input, or null when there is no usable query.
///
/// Komga full-text search is exact-token by default: a plain misspelling
/// returns zero results. So each clean word token is expanded to
/// `(token* OR token~)`: the trailing `*` gives instant prefix matching while
/// the user is still typing, and the trailing `~` (fuzzy, edit distance ~2)
/// rescues transposed or wrong letters that a prefix cannot. Tokens that carry
/// Lucene specials (notably hyphenated compounds) are passed through verbatim
/// because operators would break them, and the noisy `~` is skipped on very
/// short (1-2 char) tokens where a prefix alone suffices.
String? buildFuzzyFullText(String? raw) {
  if (raw == null) return null;
  final tokens = raw
      .trim()
      .split(RegExp(r'\s+'))
      .where((t) => t.isNotEmpty)
      .toList();
  if (tokens.isEmpty) return null;

  final clauses = <String>[];
  for (final t in tokens) {
    // Drop punctuation-only tokens; a lone operator would zero the query.
    if (!t.contains(RegExp(r'[A-Za-z0-9]'))) continue;
    final hasSpecial = t.split('').any(_luceneSpecials.contains);
    if (hasSpecial) {
      clauses.add(t);
    } else if (t.length <= 2) {
      clauses.add('$t*');
    } else {
      clauses.add('($t* OR $t~)');
    }
  }
  if (clauses.isEmpty) return null;
  return clauses.join(' ');
}
