import 'dart:convert';
import 'dart:typed_data';

import 'package:xml/xml.dart';

/// Reading direction declared by ComicInfo's `Manga` element. Only
/// `YesAndRightToLeft` means RTL; `Yes`/`No` carry no direction, so the
/// parser reports null and the importer falls back to LTR.
enum ComicReadingDirection { ltr, rtl }

/// Metadata parsed from a ComicInfo.xml (ComicRack/Anansi schema). All fields
/// are nullable: the schema makes everything optional and real files are
/// frequently partial.
class ComicInfo {
  const ComicInfo({
    this.series,
    this.number,
    this.volume,
    this.title,
    this.summary,
    this.year,
    this.writer,
    this.genre,
    this.languageIso,
    this.ageRating,
    this.pageCount,
    this.direction,
  });

  final String? series;

  /// Issue/chapter number as a display string ("3", "7.5", "Special").
  final String? number;
  final int? volume;
  final String? title;
  final String? summary;
  final int? year;
  final String? writer;
  final String? genre;
  final String? languageIso;

  /// Minimum age in years mapped from the AgeRating string enum, or null when
  /// unrated/unknown. Matches the numeric `ageRating` the rest of the app
  /// gates on.
  final int? ageRating;
  final int? pageCount;
  final ComicReadingDirection? direction;
}

/// Parses [xmlBytes] as ComicInfo.xml. Returns null when the bytes are not
/// well-formed XML or the root element is not `ComicInfo`; individual missing
/// or empty elements simply yield null fields (tolerant by design - the spec
/// makes every element optional and files in the wild are partial).
ComicInfo? parseComicInfo(Uint8List xmlBytes) {
  final XmlDocument doc;
  try {
    doc = XmlDocument.parse(utf8.decode(xmlBytes, allowMalformed: true));
  } on XmlException {
    return null;
  } on FormatException {
    return null;
  }
  final root = doc.rootElement;
  if (root.name.local.toLowerCase() != 'comicinfo') return null;

  String? text(String tag) {
    final lower = tag.toLowerCase();
    for (final el in root.childElements) {
      if (el.name.local.toLowerCase() == lower) {
        final v = el.innerText.trim();
        return v.isEmpty ? null : v;
      }
    }
    return null;
  }

  int? intOf(String tag) => int.tryParse(text(tag) ?? '');

  ComicReadingDirection? direction;
  if ((text('Manga') ?? '').toLowerCase() == 'yesandrighttoleft') {
    direction = ComicReadingDirection.rtl;
  }

  return ComicInfo(
    series: text('Series'),
    number: text('Number'),
    volume: intOf('Volume'),
    title: text('Title'),
    summary: text('Summary'),
    year: intOf('Year'),
    writer: text('Writer'),
    genre: text('Genre'),
    languageIso: text('LanguageISO'),
    ageRating: _ageRatingYears(text('AgeRating')),
    pageCount: intOf('PageCount'),
    direction: direction,
  );
}

/// Maps the ComicInfo AgeRating string enum to a minimum age in years.
/// Unknown/pending and unmapped values return null (unrated), never 0: the
/// app's age-gating distinguishes "unset" from a real rating of 0.
int? _ageRatingYears(String? raw) {
  switch (raw?.toLowerCase()) {
    case 'everyone':
    case 'g':
    case 'early childhood':
    case 'kids to adults':
      return 0;
    case 'pg':
      return 8;
    case 'everyone 10+':
      return 10;
    case 'teen':
      return 13;
    case 'ma15+':
      return 15;
    case 'mature 17+':
    case 'm':
      return 17;
    case 'r18+':
    case 'adults only 18+':
    case 'x18+':
      return 18;
    default:
      return null;
  }
}
