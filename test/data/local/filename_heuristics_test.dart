import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/data/local/filename_heuristics.dart';

void main() {
  test('volume and chapter tokens', () {
    final m = deriveFromFilename('One Piece v12 c100.cbz');
    expect(m.series, 'One Piece');
    expect(m.volume, 12);
    expect(m.number, '100');
  });

  test('underscores and zero-padded trailing number', () {
    final m = deriveFromFilename('Berserk_003.cbz');
    expect(m.series, 'Berserk');
    expect(m.number, '3');
    expect(m.volume, isNull);
  });

  test('Vol. token and bracketed groups are stripped', () {
    final m = deriveFromFilename('Akira Vol. 2 (1990) [Dark Horse].cbz');
    expect(m.series, 'Akira');
    expect(m.volume, 2);
    expect(m.number, isNull);
  });

  test('Chapter word and decimal numbers', () {
    final m = deriveFromFilename('Blame! Chapter 7.5.cbr');
    expect(m.series, 'Blame!');
    expect(m.number, '7.5');
  });

  test('hash-number form', () {
    final m = deriveFromFilename('Saga #43.cbz');
    expect(m.series, 'Saga');
    expect(m.number, '43');
  });

  test('no tokens at all: whole name is the series', () {
    final m = deriveFromFilename('random.cbz');
    expect(m.series, 'random');
    expect(m.number, isNull);
    expect(m.volume, isNull);
  });

  test('tokens only: series falls back to the cleaned name', () {
    final m = deriveFromFilename('c003.cbz');
    expect(m.series, 'c003');
    expect(m.number, '3');
  });

  test('sortKey lowercases and strips leading articles', () {
    expect(sortKey('The Walking Dead'), 'walking dead');
    expect(sortKey('A Bride\'s Story'), 'bride\'s story');
    expect(sortKey('Akira'), 'akira');
  });
}
