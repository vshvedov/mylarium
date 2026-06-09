import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/data/local/comicinfo_parser.dart';

Uint8List xml(String s) => Uint8List.fromList(utf8.encode(s));

void main() {
  test('parses a full ComicInfo', () {
    final info = parseComicInfo(xml('''
<?xml version="1.0"?>
<ComicInfo xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <Title>The Fall</Title>
  <Series>Berserk</Series>
  <Number>3</Number>
  <Volume>1</Volume>
  <Summary>Dark fantasy.</Summary>
  <Year>1990</Year>
  <Writer>Kentaro Miura</Writer>
  <Genre>Seinen</Genre>
  <LanguageISO>ja</LanguageISO>
  <AgeRating>Mature 17+</AgeRating>
  <PageCount>220</PageCount>
  <Manga>YesAndRightToLeft</Manga>
</ComicInfo>
'''));
    expect(info, isNotNull);
    expect(info!.series, 'Berserk');
    expect(info.number, '3');
    expect(info.volume, 1);
    expect(info.title, 'The Fall');
    expect(info.summary, 'Dark fantasy.');
    expect(info.year, 1990);
    expect(info.writer, 'Kentaro Miura');
    expect(info.genre, 'Seinen');
    expect(info.languageIso, 'ja');
    expect(info.ageRating, 17);
    expect(info.pageCount, 220);
    expect(info.direction, ComicReadingDirection.rtl);
  });

  test('partial ComicInfo: missing fields are null, Manga=Yes is not RTL', () {
    final info = parseComicInfo(xml(
        '<ComicInfo><Series>Akira</Series><Manga>Yes</Manga></ComicInfo>'));
    expect(info!.series, 'Akira');
    expect(info.number, isNull);
    expect(info.ageRating, isNull);
    expect(info.direction, isNull);
  });

  test('empty elements are treated as absent', () {
    final info = parseComicInfo(
        xml('<ComicInfo><Series></Series><Number>  </Number></ComicInfo>'));
    expect(info!.series, isNull);
    expect(info.number, isNull);
  });

  test('age rating strings map to years', () {
    int? rate(String s) => parseComicInfo(
            xml('<ComicInfo><AgeRating>$s</AgeRating></ComicInfo>'))!
        .ageRating;
    expect(rate('Everyone'), 0);
    expect(rate('Everyone 10+'), 10);
    expect(rate('Teen'), 13);
    expect(rate('MA15+'), 15);
    expect(rate('Mature 17+'), 17);
    expect(rate('Adults Only 18+'), 18);
    expect(rate('Unknown'), isNull);
    expect(rate('Rating Pending'), isNull);
  });

  test('malformed XML returns null', () {
    expect(parseComicInfo(xml('<ComicInfo><Series>Oops')), isNull);
    expect(parseComicInfo(xml('not xml at all')), isNull);
  });

  test('wrong root element returns null', () {
    expect(parseComicInfo(xml('<Book><Series>X</Series></Book>')), isNull);
  });
}
