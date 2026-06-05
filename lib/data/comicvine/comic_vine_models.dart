/// Comic Vine DTOs, display models, and pure helpers (matching, HTML stripping,
/// cache (de)serialization). No Flutter/Dio imports: unit-testable in isolation.
library;

// --- Wire DTOs (parsed from Comic Vine JSON) -------------------------------

/// A `/search` volume result (summary fields only).
class CvVolumeMatch {
  const CvVolumeMatch({
    required this.id,
    required this.name,
    this.startYear,
    this.countOfIssues,
    this.publisherName,
    this.deck,
  });

  final int id;
  final String name;
  final String? startYear;
  final int? countOfIssues;
  final String? publisherName;
  final String? deck;

  static CvVolumeMatch fromJson(Map<String, Object?> j) => CvVolumeMatch(
    id: (j['id'] as num).toInt(),
    name: (j['name'] as String?) ?? '',
    startYear: j['start_year'] as String?,
    countOfIssues: (j['count_of_issues'] as num?)?.toInt(),
    publisherName: _name(j['publisher']),
    deck: j['deck'] as String?,
  );
}

/// A `/volume/4050-<id>/` detail object.
class CvVolume {
  const CvVolume({
    required this.id,
    required this.name,
    this.deck,
    this.description,
    this.startYear,
    this.countOfIssues,
    this.publisherName,
    this.characters = const [],
    this.people = const [],
    this.siteUrl,
  });

  final int id;
  final String name;
  final String? deck;
  final String? description;
  final String? startYear;
  final int? countOfIssues;
  final String? publisherName;
  final List<String> characters;
  final List<({String name, String role})> people;
  final String? siteUrl;

  static CvVolume fromJson(Map<String, Object?> j) => CvVolume(
    id: (j['id'] as num).toInt(),
    name: (j['name'] as String?) ?? '',
    deck: j['deck'] as String?,
    description: j['description'] as String?,
    startYear: j['start_year'] as String?,
    countOfIssues: (j['count_of_issues'] as num?)?.toInt(),
    publisherName: _name(j['publisher']),
    characters: _names(j['characters']),
    people: _credits(j['people']),
    siteUrl: j['site_detail_url'] as String?,
  );
}

/// A `/issues/` reference (id only).
class CvIssueRef {
  const CvIssueRef(this.id);
  final int id;
}

/// An `/issue/4000-<id>/` detail object.
class CvIssue {
  const CvIssue({
    required this.id,
    required this.name,
    this.deck,
    this.description,
    this.coverDate,
    this.issueNumber,
    this.characters = const [],
    this.people = const [],
    this.storyArcs = const [],
    this.siteUrl,
  });

  final int id;
  final String name;
  final String? deck;
  final String? description;
  final String? coverDate;
  final String? issueNumber;
  final List<String> characters;
  final List<({String name, String role})> people;
  final List<String> storyArcs;
  final String? siteUrl;

  static CvIssue fromJson(Map<String, Object?> j) => CvIssue(
    id: (j['id'] as num).toInt(),
    name: (j['name'] as String?) ?? '',
    deck: j['deck'] as String?,
    description: j['description'] as String?,
    coverDate: j['cover_date'] as String?,
    issueNumber: j['issue_number'] as String?,
    characters: _names(j['character_credits']),
    people: _credits(j['person_credits']),
    storyArcs: _names(j['story_arc_credits']),
    siteUrl: j['site_detail_url'] as String?,
  );
}

String? _name(Object? o) =>
    o is Map ? (o['name'] as String?) : null;

List<String> _names(Object? o) => o is List
    ? [
        for (final e in o)
          if (e is Map && e['name'] is String) e['name'] as String,
      ]
    : const [];

List<({String name, String role})> _credits(Object? o) => o is List
    ? [
        for (final e in o)
          if (e is Map && e['name'] is String)
            (name: e['name'] as String, role: (e['role'] as String?) ?? ''),
      ]
    : const [];

// --- Display models (what the view renders / the cache stores) -------------

class ComicVineVolumeData {
  const ComicVineVolumeData({
    required this.matchedId,
    required this.name,
    this.deck,
    this.description,
    this.publisher,
    this.startYear,
    this.issueCount,
    this.characters = const [],
    this.creators = const [],
    this.siteUrl,
  });

  final int matchedId;
  final String name;
  final String? deck;
  final String? description;
  final String? publisher;
  final String? startYear;
  final int? issueCount;
  final List<String> characters;
  final List<({String name, String role})> creators;
  final String? siteUrl;

  factory ComicVineVolumeData.fromVolume(CvVolume v) => ComicVineVolumeData(
    matchedId: v.id,
    name: v.name,
    deck: v.deck,
    description: v.description,
    publisher: v.publisherName,
    startYear: v.startYear,
    issueCount: v.countOfIssues,
    characters: v.characters,
    creators: v.people,
    siteUrl: v.siteUrl,
  );
}

class ComicVineIssueData {
  const ComicVineIssueData({
    required this.matchedId,
    required this.name,
    this.deck,
    this.description,
    this.coverDate,
    this.issueNumber,
    this.characters = const [],
    this.creators = const [],
    this.storyArcs = const [],
    this.siteUrl,
  });

  final int matchedId;
  final String name;
  final String? deck;
  final String? description;
  final String? coverDate;
  final String? issueNumber;
  final List<String> characters;
  final List<({String name, String role})> creators;
  final List<String> storyArcs;
  final String? siteUrl;

  factory ComicVineIssueData.fromIssue(CvIssue i) => ComicVineIssueData(
    matchedId: i.id,
    name: i.name,
    deck: i.deck,
    description: i.description,
    coverDate: i.coverDate,
    issueNumber: i.issueNumber,
    characters: i.characters,
    creators: i.people,
    storyArcs: i.storyArcs,
    siteUrl: i.siteUrl,
  );
}

// --- Matching --------------------------------------------------------------

/// Lowercase, strip a trailing year parenthetical like `(2012-)` / `(2012)`,
/// reduce non-alphanumerics to single spaces, trim.
String normalizeTitle(String s) => s
    .toLowerCase()
    .replaceFirst(RegExp(r'\s*\(\d{4}-?\)\s*$'), '')
    .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
    .trim();

/// A readable Comic Vine search query for a Komga [title]: drops a trailing year
/// parenthetical and squeezes whitespace. Comic Vine full-text search does far
/// better on the bare title ("Cruel Universe") than on "Cruel Universe (2025-)".
String comicVineSearchQuery(String title) => title
    .replaceFirst(RegExp(r'\s*\(\d{4}-?\)\s*$'), '')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

/// The publication year embedded in a Komga title like "Title (2025-)", or null
/// when the title carries no `(YYYY)` suffix.
int? komgaTitleYear(String title) {
  final m = RegExp(r'\((\d{4})-?\)\s*$').firstMatch(title);
  return m == null ? null : int.tryParse(m.group(1)!);
}

Set<String> _titleTokens(String s) =>
    normalizeTitle(s).split(' ').where((t) => t.isNotEmpty).toSet();

/// Best Comic Vine volume for a Komga series. Fuzzy: names are rarely identical
/// to the official Comic Vine name (prefixes like "EC ", different punctuation),
/// so candidates are scored by word-token overlap rather than exact/substring
/// match. Keeps any candidate sharing at least half the title's words, then
/// ranks by token coverage, a year match (from the Komga title's `(YYYY)`),
/// tightness of the name (Jaccard), and finally closeness of issue count to
/// [booksCount]. Returns null when nothing overlaps.
CvVolumeMatch? bestVolumeMatch(
  List<CvVolumeMatch> candidates, {
  required String title,
  required int booksCount,
}) {
  final query = _titleTokens(title);
  if (query.isEmpty) return null;
  final wantYear = komgaTitleYear(title);

  final scored =
      <({
        CvVolumeMatch c,
        double coverage,
        double jaccard,
        bool yearMatch,
        int delta,
      })>[];
  for (final c in candidates) {
    final name = _titleTokens(c.name);
    if (name.isEmpty) continue;
    final inter = query.intersection(name).length;
    if (inter == 0) continue;
    final coverage = inter / query.length;
    if (coverage < 0.5) continue;
    final cvYear = int.tryParse(c.startYear ?? '');
    scored.add((
      c: c,
      coverage: coverage,
      jaccard: inter / query.union(name).length,
      yearMatch: wantYear != null && cvYear == wantYear,
      delta: ((c.countOfIssues ?? 100000) - booksCount).abs(),
    ));
  }
  if (scored.isEmpty) return null;

  scored.sort((a, b) {
    final byCoverage = b.coverage.compareTo(a.coverage);
    if (byCoverage != 0) return byCoverage;
    if (a.yearMatch != b.yearMatch) return a.yearMatch ? -1 : 1;
    final byJaccard = b.jaccard.compareTo(a.jaccard);
    if (byJaccard != 0) return byJaccard;
    final byDelta = a.delta.compareTo(b.delta);
    if (byDelta != 0) return byDelta;
    return a.c.id.compareTo(b.c.id);
  });
  return scored.first.c;
}

// --- HTML stripping --------------------------------------------------------

/// Strips tags and decodes a small fixed set of HTML entities from a Comic Vine
/// description, collapsing whitespace. Not a general HTML parser: per-tag
/// removal handles nesting; the view clamps length via maxLines.
String stripHtml(String s) {
  var out = s.replaceAll(RegExp(r'<[^>]*>'), ' ');
  out = out
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&'); // decode &amp; last
  return out.replaceAll(RegExp(r'\s+'), ' ').trim();
}

// --- Cache (de)serialization ----------------------------------------------

/// Cache payload version. Bump if the stored shape changes.
const int kComicVineCacheVersion = 1;

/// A negative-match cache payload (no Comic Vine match for this owner).
Map<String, Object?> comicVineNoMatchPayload() => {
  'v': kComicVineCacheVersion,
  'noMatch': true,
};

bool comicVineIsNoMatch(Map<String, Object?> json) => json['noMatch'] == true;

Map<String, Object?> volumeToCache(ComicVineVolumeData d) => {
  'v': kComicVineCacheVersion,
  'matchedId': d.matchedId,
  'name': d.name,
  'deck': d.deck,
  'description': d.description,
  'publisher': d.publisher,
  'startYear': d.startYear,
  'issueCount': d.issueCount,
  'characters': d.characters,
  'creators': [
    for (final c in d.creators) {'name': c.name, 'role': c.role},
  ],
  'siteUrl': d.siteUrl,
};

ComicVineVolumeData volumeFromCache(Map<String, Object?> j) =>
    ComicVineVolumeData(
      matchedId: (j['matchedId'] as num).toInt(),
      name: (j['name'] as String?) ?? '',
      deck: j['deck'] as String?,
      description: j['description'] as String?,
      publisher: j['publisher'] as String?,
      startYear: j['startYear'] as String?,
      issueCount: (j['issueCount'] as num?)?.toInt(),
      characters: _cacheNames(j['characters']),
      creators: _cacheCreators(j['creators']),
      siteUrl: j['siteUrl'] as String?,
    );

Map<String, Object?> issueToCache(ComicVineIssueData d) => {
  'v': kComicVineCacheVersion,
  'matchedId': d.matchedId,
  'name': d.name,
  'deck': d.deck,
  'description': d.description,
  'coverDate': d.coverDate,
  'issueNumber': d.issueNumber,
  'characters': d.characters,
  'creators': [
    for (final c in d.creators) {'name': c.name, 'role': c.role},
  ],
  'storyArcs': d.storyArcs,
  'siteUrl': d.siteUrl,
};

ComicVineIssueData issueFromCache(Map<String, Object?> j) => ComicVineIssueData(
  matchedId: (j['matchedId'] as num).toInt(),
  name: (j['name'] as String?) ?? '',
  deck: j['deck'] as String?,
  description: j['description'] as String?,
  coverDate: j['coverDate'] as String?,
  issueNumber: j['issueNumber'] as String?,
  characters: _cacheNames(j['characters']),
  creators: _cacheCreators(j['creators']),
  storyArcs: _cacheNames(j['storyArcs']),
  siteUrl: j['siteUrl'] as String?,
);

List<String> _cacheNames(Object? o) =>
    o is List ? [for (final e in o) e.toString()] : const [];

List<({String name, String role})> _cacheCreators(Object? o) => o is List
    ? [
        for (final e in o)
          if (e is Map)
            (
              name: (e['name'] as String?) ?? '',
              role: (e['role'] as String?) ?? '',
            ),
      ]
    : const [];

/// Groups creators by role in first-seen order; splits comma-joined roles so a
/// person appears under each role. Used by the view ("Writer: a, b").
List<({String role, List<String> names})> groupCreatorsByRole(
  List<({String name, String role})> creators,
) {
  final order = <String>[];
  final byRole = <String, List<String>>{};
  for (final c in creators) {
    final roles = c.role.split(',').map((r) => r.trim()).where((r) => r.isNotEmpty);
    for (final raw in roles) {
      final role = _titleCase(raw);
      if (!byRole.containsKey(role)) {
        byRole[role] = [];
        order.add(role);
      }
      byRole[role]!.add(c.name);
    }
  }
  return [for (final r in order) (role: r, names: byRole[r]!)];
}

String _titleCase(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();
