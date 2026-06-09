import 'dart:io';

import 'package:archive/archive.dart' hide ArchiveException;
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/core/archive/archive_extractor.dart';

void main() {
  const extractor = ArchiveExtractor();
  late Directory tmp;

  setUp(() async => tmp = await Directory.systemTemp.createTemp('arch_test'));
  tearDown(() async => tmp.existsSync() ? await tmp.delete(recursive: true) : null);

  String writeCbz(Map<String, List<int>> entries) {
    final archive = Archive();
    entries.forEach((name, data) => archive.add(ArchiveFile.bytes(name, data)));
    final bytes = ZipEncoder().encodeBytes(archive);
    final path = '${tmp.path}/book.cbz';
    File(path).writeAsBytesSync(bytes);
    return path;
  }

  test('CBZ: entries are image-only and natural-sorted', () async {
    final path = writeCbz({
      'page10.jpg': [1],
      'page2.jpg': [2],
      'page1.jpg': [3],
      'ComicInfo.xml': [9],
      'cover.png': [4],
    });
    final entries = await extractor.entries(path);
    // cover.png sorts before page1/2/10 (c < p); xml excluded.
    expect(entries, ['cover.png', 'page1.jpg', 'page2.jpg', 'page10.jpg']);
  });

  test('CBZ: extracts a specific entry byte-for-byte', () async {
    final path = writeCbz({
      'a.jpg': [10, 20, 30],
      'b.jpg': [40, 50],
    });
    final bytes = await extractor.page(path, 'b.jpg');
    expect(bytes, [40, 50]);
  });

  test('CBZ: an archive with no images is treated as malformed', () async {
    final path = writeCbz({'notes.txt': [1, 2, 3]});
    expect(() => extractor.entries(path), throwsA(isA<ArchiveException>()));
  });

  test('unknown format throws ArchiveException', () async {
    final path = '${tmp.path}/junk.cbz';
    File(path).writeAsBytesSync([1, 2, 3, 4, 5, 6, 7, 8]);
    expect(() => extractor.entries(path), throwsA(isA<ArchiveException>()));
  });

  test('tryReadEntry: finds ComicInfo.xml case-insensitively at the root',
      () async {
    final path = writeCbz({
      'page1.jpg': [1],
      'comicinfo.XML': [60, 67, 62], // "<C>"
    });
    final bytes = await extractor.tryReadEntry(path, 'ComicInfo.xml');
    expect(bytes, [60, 67, 62]);
  });

  test('tryReadEntry: prefers the shallowest match', () async {
    final path = writeCbz({
      'page1.jpg': [1],
      'sub/ComicInfo.xml': [2],
      'ComicInfo.xml': [1, 1],
    });
    final bytes = await extractor.tryReadEntry(path, 'ComicInfo.xml');
    expect(bytes, [1, 1]);
  });

  test('tryReadEntry: null when the entry is absent', () async {
    final path = writeCbz({'page1.jpg': [1]});
    expect(await extractor.tryReadEntry(path, 'ComicInfo.xml'), isNull);
  });

  // CBR via the unrar FFI library. The native hook does NOT build under
  // `flutter test`, so this skips there; it is verified for real on host via
  // `dart run tool/cbr_check.dart` against the same ArchiveExtractor. The bundled
  // fixture holds .txt entries (no rar CLI here to author an image RAR), so a
  // working decode reaches the image filter and reports "No image entries" -
  // which still proves the sniff -> FFI listFiles -> filter path ran.
  test('CBR: decode path runs (skipped without native lib)', () async {
    const fixture = 'test/core/archive/fixtures/test.rar';
    try {
      await extractor.entries(fixture);
      fail('fixture has no image entries; expected ArchiveException');
    } on ArchiveException catch (e) {
      expect(e.message, contains('No image'),
          reason: 'RAR was decoded; it just has no image entries');
    } on Object catch (e) {
      if (e.toString().toLowerCase().contains('native library')) {
        markTestSkipped('unrar native lib not built under flutter test');
        return;
      }
      rethrow;
    }
  });
}
