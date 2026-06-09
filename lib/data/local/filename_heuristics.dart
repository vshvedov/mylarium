/// Metadata guessed from an archive filename, used when ComicInfo.xml is
/// absent. [series] is never empty (worst case: the cleaned filename).
class FilenameMeta {
  const FilenameMeta({required this.series, this.number, this.volume});
  final String series;

  /// Chapter/issue number as a display string, leading zeros stripped.
  final String? number;
  final int? volume;
}

final _bracketGroups = RegExp(r'[\[({][^\])}]*[\])}]');
final _volumeToken =
    RegExp(r'\bv(?:ol(?:ume)?)?\.?\s*(\d+)\b', caseSensitive: false);
final _chapterToken = RegExp(r'\bc(?:h(?:apter)?)?\.?\s*(\d+(?:\.\d+)?)\b',
    caseSensitive: false);
final _trailingNumber = RegExp(r'(?:#\s*|\s)(\d{1,4}(?:\.\d+)?)\s*$');

/// Guesses series/volume/number from a comic archive [fileName] (with or
/// without extension). Strategy: drop the extension and bracketed release
/// junk, lift out a `v12`/`Vol. 2` volume token and a `c100`/`Chapter 7.5`/
/// trailing-number chapter token, and treat what is left as the series. When
/// nothing is left, the cleaned filename itself is the series and no tokens
/// are claimed (a name like `c003.cbz` is a title, not chapter 3 of nothing).
FilenameMeta deriveFromFilename(String fileName) {
  var s = fileName;
  final dot = s.lastIndexOf('.');
  if (dot > 0) s = s.substring(0, dot);
  final cleanedName = _tidy(s.replaceAll('_', ' '));
  s = s.replaceAll(_bracketGroups, ' ').replaceAll('_', ' ');

  int? volume;
  final v = _volumeToken.firstMatch(s);
  if (v != null) {
    volume = int.parse(v.group(1)!);
    s = s.replaceRange(v.start, v.end, ' ');
  }

  String? number;
  final c = _chapterToken.firstMatch(s);
  if (c != null) {
    number = _stripZeros(c.group(1)!);
    s = s.replaceRange(c.start, c.end, ' ');
  } else {
    final t = _trailingNumber.firstMatch(s);
    if (t != null) {
      number = _stripZeros(t.group(1)!);
      s = s.replaceRange(t.start, t.end, ' ');
    }
  }

  final series = _tidy(s);
  if (series.isEmpty) {
    // The name was nothing but tokens; treat it as an opaque title instead of
    // claiming a series-less chapter.
    return FilenameMeta(series: cleanedName, number: number, volume: volume);
  }
  return FilenameMeta(series: series, number: number, volume: volume);
}

/// Sort key for series grouping: lowercased, leading English articles
/// stripped, whitespace collapsed.
String sortKey(String value) {
  var s = value.toLowerCase().trim();
  s = s.replaceFirst(RegExp(r'^(the|an|a)\s+'), '');
  return s.replaceAll(RegExp(r'\s+'), ' ');
}

String _tidy(String s) =>
    s.replaceAll(RegExp(r'\s+'), ' ').replaceAll(RegExp(r'[\s\-]+$'), '').trim();

String _stripZeros(String n) {
  final stripped = n.replaceFirst(RegExp(r'^0+(?=\d)'), '');
  return stripped;
}
